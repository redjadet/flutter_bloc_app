import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type GraphqlResponse<T> = { data?: T; errors?: unknown };

type ContinentsData = {
  continents: Array<{ code: string; name: string }>;
};

type CountriesData = {
  countries: Array<{
    code: string;
    name: string;
    capital?: string | null;
    currency?: string | null;
    emoji?: string | null;
    continent: { code: string; name: string };
  }>;
};

type CountriesByContinentData = {
  continent: {
    countries: CountriesData["countries"];
  } | null;
};

const CONTINENTS_QUERY = `
  query Continents {
    continents {
      code
      name
    }
  }
`;

const ALL_COUNTRIES_QUERY = `
  query AllCountries {
    countries {
      code
      name
      capital
      currency
      emoji
      continent {
        code
        name
      }
    }
  }
`;

const COUNTRIES_BY_CONTINENT_QUERY = `
  query CountriesByContinent($continent: ID!) {
    continent(code: $continent) {
      countries {
        code
        name
        capital
        currency
        emoji
        continent {
          code
          name
        }
      }
    }
  }
`;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

async function postGraphql<T>(
  payload: Record<string, unknown>,
): Promise<T> {
  const res = await fetch("https://countries.trevorblades.com/", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Upstream error: ${res.status} ${text}`);
  }

  const json = (await res.json()) as GraphqlResponse<T>;
  if (json.errors) {
    throw new Error("Upstream GraphQL errors");
  }
  if (!json.data) {
    throw new Error("Upstream missing data");
  }
  return json.data;
}

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

  let body: unknown = null;
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: "Invalid JSON" }, 400);
  }

  const rawType =
    typeof (body as Record<string, unknown>)?.type === "string"
      ? ((body as Record<string, unknown>).type as string)
      : "all";
  const type = rawType.trim().toLowerCase();
  if (type !== "all" && type !== "continents" && type !== "countries") {
    return jsonResponse({ error: "Invalid type" }, 400);
  }

  const continentCodeRaw =
    typeof (body as Record<string, unknown>)?.continentCode === "string"
      ? ((body as Record<string, unknown>).continentCode as string)
      : null;
  const continentCode =
    continentCodeRaw?.trim()?.toUpperCase() || null;
  if (continentCode !== null && !/^[A-Z]{2}$/.test(continentCode)) {
    return jsonResponse({ error: "Invalid continentCode" }, 400);
  }

  const supabase = createClient(url, serviceRoleKey);

  try {
    const continentsData = await postGraphql<ContinentsData>({
      query: CONTINENTS_QUERY.trim(),
      operationName: "Continents",
    });
    const continents = continentsData.continents;
    const continentsRows = continents.map((c) => ({
      code: c.code,
      name: c.name,
    }));
    const { error: continentsError } = await supabase
      .from("graphql_continents")
      .upsert(continentsRows, { onConflict: "code" });
    if (continentsError) throw continentsError;

    if (type === "continents") {
      return jsonResponse({ continents });
    }

    let countries: CountriesData["countries"] = [];
    if (continentCode) {
      const data = await postGraphql<CountriesByContinentData>({
        query: COUNTRIES_BY_CONTINENT_QUERY.trim(),
        variables: { continent: continentCode },
        operationName: "CountriesByContinent",
      });
      countries = data.continent?.countries ?? [];
    } else {
      const data = await postGraphql<CountriesData>({
        query: ALL_COUNTRIES_QUERY.trim(),
        operationName: "AllCountries",
      });
      countries = data.countries;
    }

    const countriesRows = countries.map((c) => ({
      code: c.code,
      name: c.name,
      continent_code: c.continent.code,
      capital: c.capital ?? null,
      currency: c.currency ?? null,
      emoji: c.emoji ?? null,
    }));

    const { error: countriesError } = await supabase
      .from("graphql_countries")
      .upsert(countriesRows, { onConflict: "code" });
    if (countriesError) throw countriesError;

    if (type === "countries") {
      return jsonResponse({ countries });
    }
    return jsonResponse({
      synced_continents: continentsRows.length,
      synced_countries: countriesRows.length,
    });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return jsonResponse({ error: message }, 502);
  }
});
