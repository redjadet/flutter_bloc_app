# Supabase migrations

Apply IoT demo migrations to your Supabase project in one of these ways.

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

The migration is idempotent (safe to run multiple times).

## Option B: Dashboard SQL editor

1. Open [Supabase Dashboard](https://app.supabase.com) → your project → **SQL Editor**.
2. Copy the contents of `docs/offline_first/supabase_iot_demo_user_id_migration.sql` (or the file in `migrations/`).
3. Run the script. The migration is idempotent (safe to run multiple times).

## Prerequisites

- The `public.iot_devices` table must already exist (create it in Dashboard or via an earlier migration if needed).
- If you have existing shared rows without `user_id`, run `DELETE FROM public.iot_devices WHERE user_id IS NULL;` and optionally set the column NOT NULL before or after applying this migration.

## Advisors

Run security and performance advisors (e.g. via MCP `user-supabase` → `get_advisors` with type `security` or `performance`) after schema changes. Remaining advisories you may see:

- **Leaked password protection disabled** (security): enable in Dashboard → Authentication → Providers → Email → "Enable leaked password protection". See [docs](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection).
- **Unused index** `iot_devices_user_id_idx` (info): kept for per-user queries; safe to ignore at low row counts or remove later if linter persists.
