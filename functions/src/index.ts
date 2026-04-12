/* eslint-disable require-jsdoc, camelcase */
import * as admin from "firebase-admin";
import { defineSecret } from "firebase-functions/params";
import * as functionsV1 from "firebase-functions/v1";
import { onDocumentCreated, onDocumentWritten } from "firebase-functions/v2/firestore";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { google, type sheets_v4 } from "googleapis";
import twilio from "twilio";

admin.initializeApp();

const staffDemoSheetsSpreadsheetIdSecret = defineSecret("STAFF_DEMO_SHEETS_SPREADSHEET_ID");
const staffDemoSheetsCredentialsJsonSecret = defineSecret("STAFF_DEMO_SHEETS_CREDENTIALS_JSON");

/** Hugging Face read token for Flutter Render orchestration (Callable path). */
const renderChatDemoHfReadTokenSecret = defineSecret("RENDER_CHAT_DEMO_HF_READ_TOKEN");

// Simple callable function returning "Hello World"
export const helloWorld = onCall({region: "us-central1"}, () => ({
  message: "Hello World",
}));

/**
 * Returns the payload expected by Flutter `LayeredRenderOrchestrationHfTokenProvider`:
 * `{ "hf_read_token": "<trimmed>" }` (also accepts legacy `{ "token": "..." }` on client).
 *
 * Auth: Firebase Auth required. Configure secret `RENDER_CHAT_DEMO_HF_READ_TOKEN`
 * (demo-scoped HF read key) or for emulators set env `RENDER_CHAT_DEMO_HF_READ_TOKEN`.
 */
export const issueRenderChatDemoHfReadToken = onCall(
  {
    region: "us-central1",
    secrets: [renderChatDemoHfReadTokenSecret],
  },
  (request: CallableRequest) => {
    if (!request.auth?.uid) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to obtain Render demo HF read token"
      );
    }
    const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";
    const raw = isEmulator ?
      (getOptionalEnv("RENDER_CHAT_DEMO_HF_READ_TOKEN") ??
        getOptionalSecretValue(renderChatDemoHfReadTokenSecret)) :
      (getOptionalSecretValue(renderChatDemoHfReadTokenSecret) ??
        getOptionalEnv("RENDER_CHAT_DEMO_HF_READ_TOKEN"));
    const trimmed = raw?.trim() ?? "";
    if (trimmed.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "RENDER_CHAT_DEMO_HF_READ_TOKEN is not configured for this project"
      );
    }
    return {hf_read_token: trimmed};
  }
);

type ChartPoint = {date_utc: string; value: number};

const CHART_DOC_PATH = "chart_trending/bitcoin_7d";
const COINGECKO_URL =
  "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart" +
  "?vs_currency=usd&days=7&interval=daily";
const FRESH_MS = 15 * 60 * 1000;
const CHART_REFRESH_LEASE_MS = 60 * 1000;
const DELIVERY_LEASE_MS = 2 * 60 * 1000;
const FCM_MULTICAST_BATCH_SIZE = 500;
const STAFF_DEMO_CONTENT_PREFIX = "staff-app-demo/content/";
const STAFF_DEMO_CONTENT_COLLECTION = "staffDemoContent";
const DEFAULT_FIREBASE_STORAGE_BUCKET = "flutter-bloc-app-697e8.firebasestorage.app";

function assertAuth(request: CallableRequest): void {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Must be signed in to call syncChartTrending"
    );
  }
}

function isFresh(updatedAt: unknown, nowMs: number): boolean {
  if (!updatedAt) return false;
  const ts = updatedAt as admin.firestore.Timestamp;
  if (typeof ts?.toMillis !== "function") return false;
  return nowMs - ts.toMillis() <= FRESH_MS;
}

function normalizePoints(raw: unknown): ChartPoint[] {
  if (!Array.isArray(raw)) return [];
  const out: ChartPoint[] = [];
  for (const item of raw) {
    if (!item || typeof item !== "object") continue;
    const map = item as Record<string, unknown>;
    const date_utc = map["date_utc"];
    const value = map["value"];
    if (typeof date_utc !== "string" || date_utc.length === 0) continue;
    if (typeof value !== "number" || !Number.isFinite(value)) continue;
    out.push({date_utc, value});
  }
  out.sort(
    (a, b) => new Date(a.date_utc).getTime() - new Date(b.date_utc).getTime()
  );
  return out;
}

async function fetchCoinGeckoPoints(): Promise<ChartPoint[]> {
  const res = await fetch(COINGECKO_URL, {
    method: "GET",
    headers: {Accept: "application/json"},
  });
  if (!res.ok) {
    throw new HttpsError(
      "unavailable",
      `CoinGecko request failed (${res.status})`
    );
  }
  const json = (await res.json()) as unknown;
  const prices = (json as Record<string, unknown> | null)?.["prices"];
  if (!Array.isArray(prices)) {
    throw new HttpsError(
      "data-loss",
      "CoinGecko payload missing prices"
    );
  }
  const out: ChartPoint[] = [];
  for (const entry of prices) {
    if (!Array.isArray(entry) || entry.length < 2) continue;
    const ts = entry[0];
    const val = entry[1];
    if (typeof ts !== "number" || typeof val !== "number") continue;
    const date_utc = new Date(ts).toISOString();
    out.push({date_utc, value: val});
  }
  out.sort(
    (a, b) => new Date(a.date_utc).getTime() - new Date(b.date_utc).getTime()
  );
  return out;
}

function hasRecentLease(
  startedAt: unknown,
  nowMs: number,
  leaseMs: number
): boolean {
  const ts = startedAt as admin.firestore.Timestamp | null;
  if (!ts || typeof ts.toMillis !== "function") {
    return false;
  }
  return nowMs - ts.toMillis() <= leaseMs;
}

export function chunkArray<T>(items: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    out.push(items.slice(i, i + size));
  }
  return out;
}

export function shouldRefreshChartTrending(params: {
  cachedPoints: ChartPoint[];
  updatedAt: unknown;
  refreshInProgress?: boolean;
  refreshStartedAt?: unknown;
  nowMs: number;
}) {
  const cachedPoints = params.cachedPoints;
  const isCacheFresh =
    cachedPoints.length > 0 && isFresh(params.updatedAt, params.nowMs);
  const refreshInProgress =
    params.refreshInProgress === true &&
    hasRecentLease(
      params.refreshStartedAt,
      params.nowMs,
      CHART_REFRESH_LEASE_MS
    );

  return {
    cachedPoints,
    shouldRefresh: !isCacheFresh && !refreshInProgress,
    shouldServeCache: isCacheFresh || refreshInProgress,
  };
}

export function isStaffDemoTimeEntryExportClaimable(
  entry: StaffDemoTimeEntryDoc
): boolean {
  const status = entry.exportStatus ?? "none";
  return (
    entry.entryState === "closed" &&
    status !== "exported" &&
    status !== "in_progress" &&
    status !== "rate_limited"
  );
}

export function shouldClaimStaffDemoMessageDelivery(
  recipient: StaffDemoMessageRecipientDoc,
  nowMs: number
): boolean {
  if (recipient.deliveredAt) return false;
  if (
    recipient.deliveryStatus === "in_progress" &&
    hasRecentLease(recipient.deliveryLeaseStartedAt, nowMs, DELIVERY_LEASE_MS)
  ) {
    return false;
  }
  return true;
}

export function collectWeeklyReminderTokens(
  profiles: StaffDemoProfileDoc[]
): string[] {
  const tokens = new Set<string>();
  for (const profile of profiles) {
    if (profile.isActive === false) continue;
    const role = (profile.role ?? "").trim();
    if (role.length === 0) continue;
    const token = (profile.fcmToken ?? "").trim();
    if (token.length === 0) continue;
    tokens.add(token);
  }
  return Array.from(tokens);
}

export function hasStaffDemoSheetsConfig(params: {
  spreadsheetId?: string | null;
  credentialsJson?: string | null;
}): boolean {
  return Boolean(params.spreadsheetId && params.credentialsJson);
}

export function hasStaffDemoTwilioConfig(params: {
  accountSid?: string | null;
  authToken?: string | null;
  fromNumber?: string | null;
}): boolean {
  return Boolean(params.accountSid && params.authToken && params.fromNumber);
}

export const syncChartTrending = onCall(
  {region: "us-central1"},
  async (_request: CallableRequest) => {
    assertAuth(_request);

    const docRef = admin.firestore().doc(CHART_DOC_PATH);
    const nowMs = Date.now();
    const lease = await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(docRef);
      const data = snap.exists ? snap.data() : undefined;
      const cachedPoints = normalizePoints(data?.points);

      if (cachedPoints.length > 0 && isFresh(data?.updatedAt, nowMs)) {
        return {points: cachedPoints, shouldRefresh: false};
      }

      if (
        data?.refreshInProgress === true &&
        hasRecentLease(data?.refreshStartedAt, nowMs, CHART_REFRESH_LEASE_MS)
      ) {
        return {points: cachedPoints, shouldRefresh: false};
      }

      tx.set(
        docRef,
        {
          refreshInProgress: true,
          refreshStartedAt: admin.firestore.FieldValue.serverTimestamp(),
          refreshError: admin.firestore.FieldValue.delete(),
        },
        {merge: true}
      );

      return {points: cachedPoints, shouldRefresh: true};
    });

    if (!lease.shouldRefresh) {
      if (lease.points.length > 0) {
        return {points: lease.points};
      }
      throw new HttpsError(
        "unavailable",
        "Chart refresh already in progress. Please retry shortly."
      );
    }

    try {
      const points = await fetchCoinGeckoPoints();
      if (points.length === 0) {
        throw new HttpsError("data-loss", "CoinGecko returned no points");
      }

      await docRef.set(
        {
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          points,
          refreshInProgress: false,
          refreshStartedAt: admin.firestore.FieldValue.delete(),
          refreshError: admin.firestore.FieldValue.delete(),
        },
        {merge: true}
      );

      return {points};
    } catch (error) {
      await docRef.set(
        {
          refreshInProgress: false,
          refreshStartedAt: admin.firestore.FieldValue.delete(),
          refreshError: String(
            (error as {message?: unknown} | null)?.message ?? error
          ),
        },
        {merge: true}
      );
      throw error;
    }
  }
);

type StaffDemoTimeEntryFlags = {
  outsideGeofence?: boolean;
  earlyClockIn?: boolean;
  locationInsufficient?: boolean;
  missingScheduledShift?: boolean;
  duplicatePunchAttempt?: boolean;
  deviceClockSkewSuspected?: boolean;
};

type StaffDemoTimeEntryDoc = {
  entryId?: string;
  userId?: string;
  shiftId?: string | null;
  siteId?: string | null;
  timezoneName?: string;
  clockInAtClientMs?: number;
  clockOutAtClientMs?: number;
  clockInAccuracyMeters?: number | null;
  clockOutAccuracyMeters?: number | null;
  distanceMeters?: number | null;
  radiusMeters?: number | null;
  flags?: StaffDemoTimeEntryFlags;
  entryState?: "open" | "closed" | "flagged";
  exportStatus?:
    | "none"
    | "in_progress"
    | "exported"
    | "failed"
    | "rate_limited"
    | "skipped_missing_config";
  exportAttemptCount?: number;
  exportRetryAt?: admin.firestore.Timestamp | null;
  exportAttemptedAt?: admin.firestore.Timestamp | null;
  exportedAt?: admin.firestore.Timestamp | null;
  exportSkippedAt?: admin.firestore.Timestamp | null;
  exportError?: string | null;
};

function getOptionalEnv(name: string): string | null {
  const value = process.env[name];
  if (!value || value.trim().length === 0) {
    return null;
  }
  return value;
}

function getOptionalSecretValue(
  secret: ReturnType<typeof defineSecret>
): string | null {
  try {
    const value = secret.value();
    if (!value || value.trim().length === 0) return null;
    return value.trim();
  } catch {
    return null;
  }
}

function staffDemoContentIdFromObjectName(objectName: string): string | null {
  if (!objectName.startsWith(STAFF_DEMO_CONTENT_PREFIX)) return null;
  const fileName = objectName.substring(STAFF_DEMO_CONTENT_PREFIX.length);
  if (fileName.length === 0) return null;
  if (fileName.endsWith("/")) return null;
  const lastDot = fileName.lastIndexOf(".");
  const base = lastDot > 0 ? fileName.substring(0, lastDot) : fileName;
  const normalized = base.trim();
  return normalized.length === 0 ? null : normalized;
}

function staffDemoContentTypeFromObjectName(objectName: string): "pdf" | "video" | null {
  const lower = objectName.toLowerCase();
  if (lower.endsWith(".pdf")) return "pdf";
  if (lower.endsWith(".mp4") || lower.endsWith(".mov")) return "video";
  return null;
}

function staffDemoTitleFromContentId(contentId: string): string {
  const cleaned = contentId
    .replace(/_/g, " ")
    .replace(/-/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  return cleaned.length === 0 ? contentId : cleaned;
}

export const staffDemoIndexContentFromStorage = functionsV1
  .region("us-east1")
  .storage.bucket(DEFAULT_FIREBASE_STORAGE_BUCKET)
  .object()
  .onFinalize(async (object: functionsV1.storage.ObjectMetadata) => {
    const name = object.name ?? "";
    if (!name.startsWith(STAFF_DEMO_CONTENT_PREFIX)) return;

    const contentId = staffDemoContentIdFromObjectName(name);
    if (!contentId) return;

    const type = staffDemoContentTypeFromObjectName(name);
    if (!type) return;

    const title = staffDemoTitleFromContentId(contentId);
    await admin
      .firestore()
      .collection(STAFF_DEMO_CONTENT_COLLECTION)
      .doc(contentId)
      .set(
        {
          title,
          type,
          storagePath: name,
          isPublished: true,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
  });

export function isSheetsQuotaExceeded(err: unknown): boolean {
  const anyErr = err as {code?: unknown; message?: unknown} | null;
  const code = typeof anyErr?.code === "number" ? anyErr?.code : null;
  const message = String(anyErr?.message ?? err ?? "");
  return (
    code === 429 ||
    message.includes("Quota exceeded") ||
    message.includes("quotaExceeded")
  );
}

export function isSheetsRetryableError(err: unknown): boolean {
  const anyErr = err as {code?: unknown; message?: unknown} | null;
  const code = typeof anyErr?.code === "number" ? anyErr?.code : null;
  const message = String(anyErr?.message ?? err ?? "");

  if (code === 408) return true;
  if (code != null && code >= 500 && code <= 599) return true;
  if (code === 429) return true;

  // Node/network/transient HTTP client failures (best-effort).
  return (
    message.includes("ECONNRESET") ||
    message.includes("ETIMEDOUT") ||
    message.includes("EAI_AGAIN") ||
    message.includes("ENOTFOUND") ||
    message.includes("socket hang up") ||
    message.includes("The service is currently unavailable")
  );
}

export function backoffMsForAttempt(attempt: number): number {
  const clamped = Math.min(Math.max(attempt, 0), 8);
  const base = 1000 * Math.pow(2, clamped); // 1s..256s
  const jitter = Math.floor(Math.random() * 750); // <= 750ms
  return base + jitter;
}

function staffDemoTimeEntryToRow(entry: StaffDemoTimeEntryDoc): (string | number)[] {
  const flags = entry.flags ?? {};
  return [
    entry.entryId ?? "",
    entry.userId ?? "",
    entry.shiftId ?? "",
    entry.siteId ?? "",
    entry.timezoneName ?? "UTC",
    entry.clockInAtClientMs ?? "",
    entry.clockOutAtClientMs ?? "",
    entry.clockInAccuracyMeters ?? "",
    entry.clockOutAccuracyMeters ?? "",
    entry.distanceMeters ?? "",
    entry.radiusMeters ?? "",
    flags.outsideGeofence ? "TRUE" : "FALSE",
    flags.earlyClockIn ? "TRUE" : "FALSE",
    flags.locationInsufficient ? "TRUE" : "FALSE",
    flags.missingScheduledShift ? "TRUE" : "FALSE",
    flags.duplicatePunchAttempt ? "TRUE" : "FALSE",
    flags.deviceClockSkewSuspected ? "TRUE" : "FALSE",
  ];
}

async function createSheetsClient() {
  const spreadsheetId =
    getOptionalSecretValue(staffDemoSheetsSpreadsheetIdSecret) ||
    getOptionalEnv("STAFF_DEMO_SHEETS_SPREADSHEET_ID");
  const credentialsJson =
    getOptionalSecretValue(staffDemoSheetsCredentialsJsonSecret) ||
    getOptionalEnv("STAFF_DEMO_SHEETS_CREDENTIALS_JSON");

  if (!spreadsheetId || !credentialsJson) {
    throw new HttpsError(
      "failed-precondition",
      "Sheets export is not configured (missing spreadsheet id and/or credentials JSON)"
    );
  }

  let creds: Record<string, unknown>;
  try {
    creds = JSON.parse(credentialsJson) as Record<string, unknown>;
  } catch {
    throw new HttpsError(
      "failed-precondition",
      "STAFF_DEMO_SHEETS_CREDENTIALS_JSON must be valid JSON"
    );
  }

  const auth = new google.auth.GoogleAuth({
    credentials: creds,
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
  const sheets = google.sheets({version: "v4", auth});
  await ensureSheetTabExists({
    sheets,
    spreadsheetId,
    title: "time_entries",
  });
  return {sheets, spreadsheetId};
}

async function ensureSheetTabExists(params: {
  sheets: sheets_v4.Sheets;
  spreadsheetId: string;
  title: string;
}) {
  const {sheets, spreadsheetId, title} = params;

  const meta = await sheets.spreadsheets.get({
    spreadsheetId,
    fields: "sheets(properties(title))",
  });

  const existingTitles =
    meta.data.sheets
      ?.map((s: sheets_v4.Schema$Sheet) => s.properties?.title)
      .filter(Boolean) ?? [];
  if (existingTitles.includes(title)) {
    return;
  }

  await sheets.spreadsheets.batchUpdate({
    spreadsheetId,
    requestBody: {
      requests: [{addSheet: {properties: {title}}}],
    },
  });
}

async function appendStaffDemoTimeEntryRows(entries: StaffDemoTimeEntryDoc[]) {
  if (entries.length === 0) return;
  const {sheets, spreadsheetId} = await createSheetsClient();
  const values = entries.map(staffDemoTimeEntryToRow);
  await sheets.spreadsheets.values.append({
    spreadsheetId,
    range: "time_entries!A1",
    valueInputOption: "RAW",
    insertDataOption: "INSERT_ROWS",
    requestBody: {values},
  });
}

export const staffDemoExportTimeEntryToSheets = onDocumentWritten(
  {
    region: "us-central1",
    document: "staffDemoTimeEntries/{entryId}",
    secrets: [
      staffDemoSheetsSpreadsheetIdSecret,
      staffDemoSheetsCredentialsJsonSecret,
    ],
  },
  async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    if (!afterSnap || !afterSnap.exists) return;
    const after = afterSnap.data() as StaffDemoTimeEntryDoc;

    if (after.entryState !== "closed") return;

    // Avoid infinite loops: do not re-export when this trigger was caused only
    // by export bookkeeping fields changing.
    if (beforeSnap && beforeSnap.exists) {
      const before = beforeSnap.data() as StaffDemoTimeEntryDoc;
      if (before.entryState === "closed" && after.entryState === "closed") {
        const beforeStatus = before.exportStatus ?? "none";
        const afterStatus = after.exportStatus ?? "none";
        if (beforeStatus !== afterStatus) {
          return;
        }
      }
    }

    const ref = afterSnap.ref;

    const spreadsheetId =
      getOptionalSecretValue(staffDemoSheetsSpreadsheetIdSecret) ||
      getOptionalEnv("STAFF_DEMO_SHEETS_SPREADSHEET_ID");
    const credentialsJson =
      getOptionalSecretValue(staffDemoSheetsCredentialsJsonSecret) ||
      getOptionalEnv("STAFF_DEMO_SHEETS_CREDENTIALS_JSON");
    if (
      !hasStaffDemoSheetsConfig({
        spreadsheetId,
        credentialsJson,
      })
    ) {
      await ref.set(
        {
          exportStatus: "skipped_missing_config",
          exportSkippedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      return;
    }

    const claimResult = await admin.firestore().runTransaction(async (tx) => {
      const fresh = await tx.get(ref);
      if (!fresh.exists) return {claimed: false, attempt: 0};
      const data = fresh.data() as StaffDemoTimeEntryDoc;
      const status = data.exportStatus ?? "none";
      if (
        status === "exported" ||
        status === "in_progress" ||
        status === "rate_limited"
      ) {
        return {claimed: false, attempt: data.exportAttemptCount ?? 0};
      }
      const attempt = (data.exportAttemptCount ?? 0) + 1;
      tx.set(
        ref,
        {
          exportStatus: "in_progress",
          exportAttemptedAt: admin.firestore.FieldValue.serverTimestamp(),
          exportAttemptCount: attempt,
        },
        {merge: true}
      );
      return {claimed: true, attempt};
    });
    if (!claimResult.claimed) return;

    try {
      await appendStaffDemoTimeEntryRows([after]);
      await ref.set(
        {
          exportStatus: "exported",
          exportedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
    } catch (error: unknown) {
      const attempt = claimResult.attempt;
      if (isSheetsQuotaExceeded(error) || isSheetsRetryableError(error)) {
        const retryMs = backoffMsForAttempt(attempt);
        await ref.set(
          {
            exportStatus: "rate_limited",
            exportRetryAt: admin.firestore.Timestamp.fromMillis(
              Date.now() + retryMs
            ),
            exportError: String(
              (error as {message?: unknown} | null)?.message ?? error
            ),
          },
          {merge: true}
        );
        return;
      }
      await ref.set(
        {
          exportStatus: "failed",
          exportFailedAt: admin.firestore.FieldValue.serverTimestamp(),
          exportError: String((error as {message?: unknown} | null)?.message ?? error),
        },
        {merge: true}
      );
      return;
    }
  }
);

export const staffDemoRetryTimeEntrySheetsExports = onSchedule(
  {
    region: "us-central1",
    schedule: "*/1 * * * *",
    timeZone: "UTC",
    secrets: [
      staffDemoSheetsSpreadsheetIdSecret,
      staffDemoSheetsCredentialsJsonSecret,
    ],
  },
  async () => {
    const spreadsheetId =
      getOptionalSecretValue(staffDemoSheetsSpreadsheetIdSecret) ||
      getOptionalEnv("STAFF_DEMO_SHEETS_SPREADSHEET_ID");
    const credentialsJson =
      getOptionalSecretValue(staffDemoSheetsCredentialsJsonSecret) ||
      getOptionalEnv("STAFF_DEMO_SHEETS_CREDENTIALS_JSON");
    if (!spreadsheetId || !credentialsJson) return;

    const now = admin.firestore.Timestamp.fromMillis(Date.now());
    const snap = await admin
      .firestore()
      .collection("staffDemoTimeEntries")
      .where("exportStatus", "==", "rate_limited")
      .where("exportRetryAt", "<=", now)
      .limit(25)
      .get();
    if (snap.empty) return;

    // Claim and append in a single Sheets request (multiple rows per append).
    const claimedEntries: Array<{
      ref: admin.firestore.DocumentReference;
      entry: StaffDemoTimeEntryDoc;
    }> = [];
    const refs = snap.docs.map((d) => d.ref);
    await admin.firestore().runTransaction(async (tx) => {
      for (const ref of refs) {
        const doc = await tx.get(ref);
        if (!doc.exists) continue;
        const data = doc.data() as StaffDemoTimeEntryDoc;
        if (data.entryState !== "closed") continue;
        if ((data.exportStatus ?? "none") !== "rate_limited") continue;
        tx.set(
          ref,
          {
            exportStatus: "in_progress",
            exportAttemptedAt: admin.firestore.FieldValue.serverTimestamp(),
            exportAttemptCount: (data.exportAttemptCount ?? 0) + 1,
          },
          {merge: true}
        );
        claimedEntries.push({
          ref,
          entry: {...data, entryId: data.entryId ?? doc.id},
        });
      }
    });
    if (claimedEntries.length === 0) return;

    try {
      await appendStaffDemoTimeEntryRows(
        claimedEntries.map((claimed) => claimed.entry)
      );
      const batch = admin.firestore().batch();
      for (const claimed of claimedEntries) {
        batch.set(
          claimed.ref,
          {
            exportStatus: "exported",
            exportedAt: admin.firestore.FieldValue.serverTimestamp(),
            exportRetryAt: null,
          },
          {merge: true}
        );
      }
      await batch.commit();
    } catch (error: unknown) {
      // If quota still exceeded, push retry out (keep rate_limited).
      const attempt = Math.max(
        ...claimedEntries.map((claimed) => claimed.entry.exportAttemptCount ?? 0),
        0
      );
      const retryMs = isSheetsQuotaExceeded(error) ?
        backoffMsForAttempt(attempt) :
        60_000;
      const batch = admin.firestore().batch();
      for (const claimed of claimedEntries) {
        batch.set(
          claimed.ref,
          {
            exportStatus: "rate_limited",
            exportRetryAt: admin.firestore.Timestamp.fromMillis(
              Date.now() + retryMs
            ),
            exportError: String(
              (error as {message?: unknown} | null)?.message ?? error
            ),
          },
          {merge: true}
        );
      }
      await batch.commit();
    }
  }
);

type StaffDemoMessageDoc = {
  body?: string;
  type?: string;
  createdAt?: admin.firestore.Timestamp;
  shiftId?: string | null;
};

type StaffDemoMessageRecipientDoc = {
  messageId?: string;
  userId?: string;
  deliveredAt?: admin.firestore.Timestamp | null;
  fcmDeliveredAt?: admin.firestore.Timestamp | null;
  fcmSkippedMissingToken?: boolean;
  smsDeliveredAt?: admin.firestore.Timestamp | null;
  smsSkippedMissingPhone?: boolean;
  smsSkippedNotConfigured?: boolean;
  deliveryStatus?: "in_progress" | "delivered" | "failed";
  deliveryLeaseStartedAt?: admin.firestore.Timestamp | null;
  deliveryAttemptedAt?: admin.firestore.Timestamp | null;
  deliveryAttemptCount?: number;
  deliveryError?: string | null;
};

type StaffDemoProfileDoc = {
  fcmToken?: string;
  phoneE164?: string;
  isActive?: boolean;
  role?: string;
};

function twilioConfigOrNull(): {
  client: ReturnType<typeof twilio>;
  from: string;
} | null {
  const sid = process.env.TWILIO_ACCOUNT_SID;
  const token = process.env.TWILIO_AUTH_TOKEN;
  const from = process.env.TWILIO_FROM_NUMBER;
  if (!sid || !token || !from) return null;
  return {client: twilio(sid, token), from};
}

async function sendSmsIfConfigured({
  to,
  body,
}: {
  to: string;
  body: string;
}): Promise<"sent" | "skipped_not_configured"> {
  const cfg = twilioConfigOrNull();
  if (!cfg) {
    return "skipped_not_configured";
  }
  await cfg.client.messages.create({
    to,
    from: cfg.from,
    body,
  });
  return "sent";
}

export const staffDemoSendMessageDeliveries = onDocumentCreated(
  {region: "us-central1", document: "staffDemoMessageRecipients/{docId}"},
  async (event) => {
    const snap = event.data;
    if (!snap || !snap.exists) return;
    const recipient = snap.data() as StaffDemoMessageRecipientDoc;
    const userId = recipient.userId;
    const messageId = recipient.messageId;
    if (!userId || !messageId) return;

    const nowMs = Date.now();
    const claimed = await admin.firestore().runTransaction(async (tx) => {
      const fresh = await tx.get(snap.ref);
      if (!fresh.exists) return false;
      const data = fresh.data() as StaffDemoMessageRecipientDoc;
      if (data.deliveredAt) return false;

      if (
        data.deliveryStatus === "in_progress" &&
        hasRecentLease(data.deliveryLeaseStartedAt, nowMs, DELIVERY_LEASE_MS)
      ) {
        return false;
      }

      tx.set(
        snap.ref,
        {
          deliveryStatus: "in_progress",
          deliveryLeaseStartedAt: admin.firestore.FieldValue.serverTimestamp(),
          deliveryAttemptedAt: admin.firestore.FieldValue.serverTimestamp(),
          deliveryAttemptCount: (data.deliveryAttemptCount ?? 0) + 1,
          deliveryError: admin.firestore.FieldValue.delete(),
        },
        {merge: true}
      );
      return true;
    });
    if (!claimed) return;

    const [messageSnap, profileSnap] = await Promise.all([
      admin.firestore().collection("staffDemoMessages").doc(messageId).get(),
      admin.firestore().collection("staffDemoProfiles").doc(userId).get(),
    ]);
    if (!messageSnap.exists) {
      await snap.ref.set(
        {
          deliveryStatus: "failed",
          deliveryLeaseStartedAt: admin.firestore.FieldValue.delete(),
          deliveryError: "Message document missing.",
        },
        {merge: true}
      );
      return;
    }

    const message = messageSnap.data() as StaffDemoMessageDoc;
    const profile = profileSnap.exists ? (profileSnap.data() as StaffDemoProfileDoc) : ({} as StaffDemoProfileDoc);

    const body = (message.body ?? "").trim();
    const title = message.type === "shift_assignment" ? "Shift update" : "Message";

    try {
      const freshRecipientSnap = await snap.ref.get();
      const recipientState = freshRecipientSnap.exists ?
        (freshRecipientSnap.data() as StaffDemoMessageRecipientDoc) :
        recipient;

      const token = (profile.fcmToken ?? "").trim();
      if (
        token.length > 0 &&
        body.length > 0 &&
        !recipientState.fcmDeliveredAt
      ) {
        await admin.messaging().send({
          token,
          notification: {title, body},
          data: {
            kind: "staff_demo_message",
            messageId,
          },
        });
        await snap.ref.set(
          {
            fcmDeliveredAt: admin.firestore.FieldValue.serverTimestamp(),
            fcmSkippedMissingToken: false,
          },
          {merge: true}
        );
      } else if (token.length === 0) {
        await snap.ref.set(
          {
            fcmSkippedMissingToken: true,
          },
          {merge: true}
        );
      }

      const phone = (profile.phoneE164 ?? "").trim();
      let smsSkippedMissingPhone = false;
      let smsSkippedNotConfigured = false;
      let smsDeliveredAt: admin.firestore.FieldValue | null = null;
      if (phone.length === 0) {
        smsSkippedMissingPhone = true;
      } else if (body.length > 0 && !recipientState.smsDeliveredAt) {
        // v1 policy: one-way outbound SMS (confirmation happens in-app).
        const smsResult = await sendSmsIfConfigured({to: phone, body});
        if (smsResult === "sent") {
          smsDeliveredAt = admin.firestore.FieldValue.serverTimestamp();
        } else {
          smsSkippedNotConfigured = true;
        }
      }

      await snap.ref.set(
        {
          deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
          smsDeliveredAt,
          smsSkippedMissingPhone,
          smsSkippedNotConfigured,
          deliveryStatus: "delivered",
          deliveryLeaseStartedAt: admin.firestore.FieldValue.delete(),
          deliveryError: admin.firestore.FieldValue.delete(),
        },
        {merge: true}
      );
    } catch (error) {
      await snap.ref.set(
        {
          deliveryStatus: "failed",
          deliveryLeaseStartedAt: admin.firestore.FieldValue.delete(),
          deliveryError: String(
            (error as {message?: unknown} | null)?.message ?? error
          ),
        },
        {merge: true}
      );
      throw error;
    }
  }
);

export const staffDemoWeeklyAvailabilityReminder = onSchedule(
  {
    region: "us-central1",
    // Monday 14:00 UTC. Keep deterministic for demo; adjust later if needed.
    schedule: "0 14 * * 1",
    timeZone: "UTC",
  },
  async () => {
    // Guardrails: do nothing unless explicitly enabled.
    if ((process.env.STAFF_DEMO_REMINDERS_ENABLED ?? "").trim() !== "true") {
      return;
    }

    const now = new Date();
    const weekLabel = now.toISOString().slice(0, 10);
    const title = "Availability reminder";
    const body = `Please submit your availability for the week (${weekLabel}).`;

    const snap = await admin.firestore().collection("staffDemoProfiles").get();
    const tokens = new Set<string>();

    for (const doc of snap.docs) {
      const profile = doc.data() as StaffDemoProfileDoc;
      if (profile.isActive === false) continue;
      const role = (profile.role ?? "").trim();
      if (role.length === 0) continue;

      const token = (profile.fcmToken ?? "").trim();
      if (token.length === 0) continue;
      tokens.add(token);
    }

    const batches = chunkArray(
      Array.from(tokens),
      FCM_MULTICAST_BATCH_SIZE
    );

    for (const batchTokens of batches) {
      await admin.messaging().sendEachForMulticast({
        tokens: batchTokens,
        notification: {title, body},
        data: {kind: "staff_demo_availability_reminder"},
      });
    }
  }
);
