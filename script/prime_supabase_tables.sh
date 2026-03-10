#!/usr/bin/env bash
# Invokes sync-graphql-countries and sync-chart-trending once to prime the tables.
# Run from repo root. Requires SUPABASE_URL and SUPABASE_ANON_KEY in the
# environment or in assets/config/secrets.json.
# Exit 1 if either function returns non-2xx (e.g. 502 from CoinGecko upstream).
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  if [ -f "assets/config/secrets.json" ]; then
    SUPABASE_URL="$(python3 -c "
import json
with open('assets/config/secrets.json') as f:
    d = json.load(f)
print(d.get('SUPABASE_URL', '') or '')
" 2>/dev/null)"
    SUPABASE_ANON_KEY="$(python3 -c "
import json
with open('assets/config/secrets.json') as f:
    d = json.load(f)
print(d.get('SUPABASE_ANON_KEY', '') or '')
" 2>/dev/null)"
    export SUPABASE_URL SUPABASE_ANON_KEY
  fi
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "Set SUPABASE_URL and SUPABASE_ANON_KEY (env or assets/config/secrets.json)." >&2
  exit 1
fi

BASE="${SUPABASE_URL%/}"
AUTH="Authorization: Bearer $SUPABASE_ANON_KEY"

echo "Priming sync-graphql-countries..."
HTTP="$(curl -s -w '%{http_code}' -o /tmp/supabase_graphql_out.txt -X POST \
  "$BASE/functions/v1/sync-graphql-countries" \
  -H "$AUTH" \
  -H "Content-Type: application/json" \
  -d '{"type":"all"}')"
if [ "$HTTP" -ge 200 ] && [ "$HTTP" -lt 300 ]; then
  echo "  OK ($HTTP)"
else
  echo "  Failed ($HTTP): $(cat /tmp/supabase_graphql_out.txt 2>/dev/null | head -c 200)" >&2
  exit 1
fi

echo "Priming sync-chart-trending..."
HTTP="$(curl -s -w '%{http_code}' -o /tmp/supabase_chart_out.txt -X POST \
  "$BASE/functions/v1/sync-chart-trending" \
  -H "$AUTH" \
  -H "Content-Type: application/json" \
  -d '{}')"
if [ "$HTTP" -ge 200 ] && [ "$HTTP" -lt 300 ]; then
  echo "  OK ($HTTP)"
else
  echo "  Failed ($HTTP): $(cat /tmp/supabase_chart_out.txt 2>/dev/null | head -c 200)" >&2
  exit 1
fi

echo "Done. Tables primed."
