/* eslint-disable require-jsdoc, camelcase */
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {onDocumentCreated, onDocumentWritten} from "firebase-functions/v2/firestore";
import {google} from "googleapis";
import twilio from "twilio";

admin.initializeApp();

// Simple callable function returning "Hello World"
export const helloWorld = onCall({region: "us-central1"}, () => ({
  message: "Hello World",
}));

type ChartPoint = {date_utc: string; value: number};

const CHART_DOC_PATH = "chart_trending/bitcoin_7d";
const COINGECKO_URL =
  "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart" +
  "?vs_currency=usd&days=7&interval=daily";
const FRESH_MS = 15 * 60 * 1000;

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

export const syncChartTrending = onCall(
  {region: "us-central1"},
  async (_request: CallableRequest) => {
    assertAuth(_request);

    const docRef = admin.firestore().doc(CHART_DOC_PATH);
    const nowMs = Date.now();

    const snap = await docRef.get();
    const data = snap.exists ? snap.data() : undefined;
    const cachedPoints = normalizePoints(data?.points);
    if (cachedPoints.length > 0 && isFresh(data?.updatedAt, nowMs)) {
      return {points: cachedPoints};
    }

    const points = await fetchCoinGeckoPoints();
    if (points.length === 0) {
      throw new HttpsError("data-loss", "CoinGecko returned no points");
    }

    await docRef.set(
      {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        points,
      },
      {merge: true}
    );

    return {points};
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
  exportStatus?: "none" | "in_progress" | "exported" | "failed";
};

function getRequiredEnv(name: string): string {
  const value = process.env[name];
  if (!value || value.trim().length === 0) {
    throw new HttpsError("failed-precondition", `Missing env var: ${name}`);
  }
  return value;
}

async function appendStaffDemoTimeEntryRow(entry: StaffDemoTimeEntryDoc) {
  const spreadsheetId = getRequiredEnv("STAFF_DEMO_SHEETS_SPREADSHEET_ID");
  const credentialsJson = getRequiredEnv("STAFF_DEMO_SHEETS_CREDENTIALS_JSON");

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

  const flags = entry.flags ?? {};
  const row = [
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

  await sheets.spreadsheets.values.append({
    spreadsheetId,
    range: "time_entries!A1",
    valueInputOption: "RAW",
    insertDataOption: "INSERT_ROWS",
    requestBody: {values: [row]},
  });
}

export const staffDemoExportTimeEntryToSheets = onDocumentWritten(
  {region: "us-central1", document: "staffDemoTimeEntries/{entryId}"},
  async (event) => {
    const afterSnap = event.data?.after;
    if (!afterSnap || !afterSnap.exists) return;
    const after = afterSnap.data() as StaffDemoTimeEntryDoc;

    if (after.entryState !== "closed") return;

    const ref = afterSnap.ref;
    const claimed = await admin.firestore().runTransaction(async (tx) => {
      const fresh = await tx.get(ref);
      if (!fresh.exists) return false;
      const data = fresh.data() as StaffDemoTimeEntryDoc;
      const status = data.exportStatus ?? "none";
      if (status === "exported" || status === "in_progress") return false;
      tx.set(
        ref,
        {
          exportStatus: "in_progress",
          exportAttemptedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      return true;
    });
    if (!claimed) return;

    try {
      await appendStaffDemoTimeEntryRow(after);
      await ref.set(
        {
          exportStatus: "exported",
          exportedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
    } catch (error: unknown) {
      await ref.set(
        {
          exportStatus: "failed",
          exportError: String((error as {message?: unknown} | null)?.message ?? error),
        },
        {merge: true}
      );
      throw error;
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
  smsDeliveredAt?: admin.firestore.Timestamp | null;
  smsSkippedMissingPhone?: boolean;
};

type StaffDemoProfileDoc = {
  fcmToken?: string;
  phoneE164?: string;
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
}): Promise<void> {
  const cfg = twilioConfigOrNull();
  if (!cfg) {
    throw new HttpsError(
      "failed-precondition",
      "Twilio is not configured (missing TWILIO_* env vars)"
    );
  }
  await cfg.client.messages.create({
    to,
    from: cfg.from,
    body,
  });
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

    const [messageSnap, profileSnap] = await Promise.all([
      admin.firestore().collection("staffDemoMessages").doc(messageId).get(),
      admin.firestore().collection("staffDemoProfiles").doc(userId).get(),
    ]);
    if (!messageSnap.exists) return;

    const message = messageSnap.data() as StaffDemoMessageDoc;
    const profile = profileSnap.exists ? (profileSnap.data() as StaffDemoProfileDoc) : ({} as StaffDemoProfileDoc);

    const body = (message.body ?? "").trim();
    const title = message.type === "shift_assignment" ? "Shift update" : "Message";

    const token = (profile.fcmToken ?? "").trim();
    if (token.length > 0 && body.length > 0) {
      await admin.messaging().send({
        token,
        notification: {title, body},
        data: {
          kind: "staff_demo_message",
          messageId,
        },
      });
    }

    const phone = (profile.phoneE164 ?? "").trim();
    let smsSkippedMissingPhone = false;
    let smsDeliveredAt: admin.firestore.FieldValue | null = null;
    if (phone.length === 0) {
      smsSkippedMissingPhone = true;
    } else if (body.length > 0) {
      // v1 policy: one-way outbound SMS (confirmation happens in-app).
      await sendSmsIfConfigured({to: phone, body});
      smsDeliveredAt = admin.firestore.FieldValue.serverTimestamp();
    }

    await snap.ref.set(
      {
        deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
        smsDeliveredAt,
        smsSkippedMissingPhone,
      },
      {merge: true}
    );
  }
);

