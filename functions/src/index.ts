/* eslint-disable require-jsdoc, camelcase */
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";

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

