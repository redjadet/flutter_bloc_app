import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { normalizePriceRows, type PriceEntry } from "./chart_trending_sync.ts";

const COINGECKO_URL =
  "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=7&interval=daily";
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(
  body: unknown,
  status = 200,
  headers: HeadersInit = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
      Connection: "keep-alive",
      ...CORS_HEADERS,
      ...headers,
    },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        ...CORS_HEADERS,
        "Cache-Control": "no-store",
      },
    });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405, {
      Allow: "POST, OPTIONS",
    });
  }

  const url = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceRoleKey) {
    return jsonResponse(
      { error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" },
      500,
    );
  }

  const supabase = createClient(url, serviceRoleKey);

  try {
    const res = await fetch(COINGECKO_URL, {
      headers: { Accept: "application/json" },
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      throw new Error(`Upstream error: ${res.status} ${text}`);
    }

    const json = (await res.json()) as { prices?: PriceEntry[] };
    const prices = json.prices;
    if (!Array.isArray(prices) || prices.length === 0) {
      throw new Error("Upstream chart payload missing or empty prices");
    }

    const rows = normalizePriceRows(prices);
    if (rows.length === 0) {
      throw new Error("No valid price entries");
    }

    const { error } = await supabase
      .from("chart_trending_points")
      .upsert(rows, { onConflict: "date_utc" });
    if (error) throw error;

    const points = rows.map((r) => ({
      date_utc: r.date_utc,
      value: r.value,
    }));
    return jsonResponse({ points, synced: rows.length });
  } catch (e) {
    // Supabase PostgrestError is a plain object - extract .message for readable response
    const message =
      e instanceof Error
        ? e.message
        : typeof (e as { message?: string })?.message === "string"
          ? (e as { message: string }).message
          : String(e);
    return jsonResponse({ error: message }, 502);
  }
});
