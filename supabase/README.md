# Supabase (migrations and Edge Functions)

## Edge Functions

- **sync-graphql-countries** — Syncs continents/countries from the public GraphQL API into `graphql_continents` and `graphql_countries`. Source: `supabase/functions/sync-graphql-countries/`. Deployed with **verify_jwt: false** (RLS on tables enforces access). App flow: [GraphQL demo](../docs/offline_first/graphql_demo.md). Redeploy: MCP `user-supabase` → `deploy_edge_function` with `name: "sync-graphql-countries"`, `files` from `index.ts`, and `verify_jwt: false`; or CLI: `supabase functions deploy sync-graphql-countries --no-verify-jwt`.
- **sync-chart-trending** — Syncs Bitcoin 7-day market chart from CoinGecko into `chart_trending_points`. Source: `supabase/functions/sync-chart-trending/`. Deployed with **verify_jwt: false**. App flow: [Chart demo](../docs/offline_first/chart_demo.md). Redeploy: MCP `user-supabase` → `deploy_edge_function` with `name: "sync-chart-trending"`, `files` including **both** `index.ts` and `chart_trending_sync.ts` (index imports the helper), and `verify_jwt: false`; or CLI: `supabase functions deploy sync-chart-trending --no-verify-jwt` (CLI bundles the whole folder).

**Prime tables (one-off sync):** From repo root, run `./script/prime_supabase_tables.sh`. Requires `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the environment or in `assets/config/secrets.json`. Invokes both functions once so the app can read from tables on first load.

## Migrations

Migrations in `supabase/migrations/` cover the **IoT demo** (e.g. `iot_devices`), **GraphQL demo** (`graphql_continents`, `graphql_countries`), and **Chart demo** (`chart_trending_points`). For the full list and MCP names, see [Supabase migrations log](../docs/offline_first/supabase_migrations.md).

Apply migrations in one of these ways.

## Option A: Supabase CLI (recommended)

1. Install [Supabase CLI](https://supabase.com/docs/guides/cli) and log in:

   ```bash
   npx supabase login
   ```

2. Link this project to your remote project (use the project ref from Dashboard → Settings → General):

   ```bash
   npx supabase link --project-ref YOUR_PROJECT_REF
   ```

3. Push migrations to the linked remote database:

   ```bash
   npx supabase db push
   ```

Migrations are idempotent (safe to run multiple times).

## Option B: Dashboard SQL editor or MCP

- **Dashboard:** Open [Supabase Dashboard](https://app.supabase.com) → your project → **SQL Editor**. Copy the contents of the desired file from `supabase/migrations/` and run the script.
- **MCP:** Use `user-supabase` → `apply_migration` with the migration name and full SQL (see [supabase_migrations.md](../docs/offline_first/supabase_migrations.md)). Call `list_migrations` first to avoid applying the same migration twice.

## Prerequisites

- For IoT demo migrations: the `public.iot_devices` table must already exist (create it in Dashboard or via an earlier migration if needed).
- If you have existing `iot_devices` rows without `user_id`, run `DELETE FROM public.iot_devices WHERE user_id IS NULL;` and optionally set the column NOT NULL before or after applying the user_id migration.

## Advisors

Run security and performance advisors (e.g. via MCP `user-supabase` → `get_advisors` with type `security` or `performance`) after schema changes. Remaining advisories you may see:

- **Leaked password protection disabled** (security): enable in Dashboard → Authentication → Providers → Email → "Enable leaked password protection". See [docs](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection).
- **Unused index** `iot_devices_user_id_idx` (info): kept for per-user queries; safe to ignore at low row counts or remove later if linter persists.
