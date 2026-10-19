# Supabase Flutter security handoff

Actionable security contract for agents changing auth, PostgREST, Edge Functions,
Storage, or Realtime in this portfolio monorepo.

**Related owners:** [`security_and_secrets.md`](../security_and_secrets.md),
[`authentication.md`](../authentication.md), [`supabase/README.md`](../../supabase/README.md),
[`offline_first/supabase_migrations.md`](../offline_first/supabase_migrations.md),
skill `ai-safe-supabase-workflow`.

---

## Hard rules (do not violate)

1. **Never put the service-role key in Flutter** (Dart, assets, `--dart-define`,
   Remote Config, secure storage used by the app). Service role bypasses RLS.
   It belongs only in Edge Function / server env (`SUPABASE_SERVICE_ROLE_KEY`).
2. **Treat the anon / publishable key as public client config.** Shipping it in
   the app is expected. It is not a secret. Authorization is RLS + JWT + Edge
   auth — not key obscurity.
3. **Never disable RLS** on user or demo tables to “make it work.” Never add
   permissive `anon` `SELECT *` / write policies as a shortcut.
4. **Client-only checks are UX, not security.** `if (user == null)` in Dart does
   not protect data. Policies / Edge JWT verification do.
5. **Do not trust client-supplied ownership fields alone.** Prefer
   `auth.uid()` in policies. App may set `user_id` on insert for clarity; RLS
   `WITH CHECK` must still enforce it.
6. **Do not invent backend surfaces this repo does not use.** Fact-check against
   the map below before assuming Storage policies, App Check, or shared Firebase
   ↔ Supabase identity.

---

## How this repo actually uses Supabase

| Surface | In this repo? | Notes |
| --- | --- | --- |
| Client bootstrap | Yes | `SupabaseBootstrapService` → `Supabase.initialize(url:, publishableKey: anonKey)` when `SUPABASE_URL` + `SUPABASE_ANON_KEY` present |
| Anon / publishable key | Yes | From `--dart-define`, direnv/`.env`, secure storage, optional Firebase Remote Config. Public config. |
| Service-role key in Flutter | **No** | Grep-clean under `apps/mobile`. Correct. |
| Primary app auth / GoRouter | **Firebase** | `AuthRepository` only. Supabase does **not** guard app-wide routes. |
| Supabase Auth | Optional page | Email/password on `/supabase-auth`. Separate session from Firebase. |
| Cross-feature Supabase session | Yes | `SupabaseAuthRepository` / `RemoteBackendAuthPort`; chat/case-study/GraphQL seams |
| IoT demo table + RLS + Realtime | Yes | `public.iot_devices`; own-row RLS; publication `supabase_realtime` |
| GraphQL / chart demo tables | Yes | Authenticated `SELECT` only; writes via Edge + service role |
| Chat Edge proxy | Yes | `chat-complete` with `verify_jwt = true`; HF key server-side only |
| Sync Edge functions | Yes | `sync-graphql-countries`, `sync-chart-trending`: `verify_jwt: false`; service role for upserts |
| Case study Storage + `case_studies` | App yes | Bucket `case_study_videos`, path `user/{uid}/…`, signed URLs. **No SQL migration in repo** for table/bucket/RLS — gap |
| Supabase Storage (general) | Case study only | Do not assume other buckets |
| Shared Firebase↔Supabase login | **No** | Two identity systems; demos that need Supabase require Supabase sign-in |

---

## Keys and configuration

| Key / env | Where | Trust |
| --- | --- | --- |
| `SUPABASE_URL` | Client | Public |
| `SUPABASE_ANON_KEY` (publishable) | Client | Public; RLS is the boundary |
| `SUPABASE_SERVICE_ROLE_KEY` | Edge / server only | **Secret**; never ship to clients |
| `HUGGINGFACE_API_KEY` | Edge secrets for `chat-complete` | **Secret**; release builds must not rely on client HF keys |

Remote Config keys `SUPABASE_URL` / `SUPABASE_ANON_KEY` are **not** a secret store
(see [`security_and_secrets.md`](../security_and_secrets.md)).

Missing client config → skip Supabase init; IoT (and similar) fall back to
local-only where documented.

---

## Auth model agents must not confuse

- **Firebase** = router, Settings account, most “signed in” app UX.
- **Supabase** = data demos and Edge calls that need a Supabase JWT.
- Chat routes redirect to `/supabase-auth` when Supabase is configured but there
  is no Supabase session ([`offline_first/chat.md`](../offline_first/chat.md)).
- Session refresh for Supabase HTTP/Edge: `SupabaseSessionManager` (single-flight).
- `JwtClaimsReader` is **diagnostics only** — not authorization.

Do not wire GoRouter guards to `SupabaseAuthRepository`. Do not assume Firebase
UID equals Supabase `auth.uid()`.

---

## RLS and tables (versioned)

Migrations live in `supabase/migrations/`; log in
[`offline_first/supabase_migrations.md`](../offline_first/supabase_migrations.md).
Apply via CLI (`supabase db push`) or MCP; never “fix” access by broadening
policies.

### `iot_devices`

- RLS enabled; policies: select/insert/update/delete where
  `user_id = (SELECT auth.uid())`.
- Migration `20260309170000_iot_devices_rls_fixes.sql` **dropped** permissive
  anon read (`Allow anon read iot_devices`). Do not reintroduce it.
- App inserts set `user_id` from `auth.currentUser`; RLS enforces ownership.
- Realtime: `IotDemoRealtimeSubscription` listens to `iot_devices` changes;
  table is in `supabase_realtime`. Rely on RLS for event visibility; do not
  treat the client subscription filter as the sole ACL.

### `graphql_continents` / `graphql_countries` / `chart_trending_points`

- RLS on; `SELECT` to `authenticated` only.
- Mutations expected from Edge with service role (bypasses RLS by design).

### `case_studies` + bucket `case_study_videos`

- Flutter assumes per-user rows and private object keys under `user/{uid}/…`.
- **Gap:** no checked-in migration defining table, storage policies, or RLS.
  Before changing case-study remote paths, confirm hosted project policies exist
  and mirror them into `supabase/migrations/` + the migrations log.

---

## Edge Functions

| Function | JWT | Secrets | Role |
| --- | --- | --- | --- |
| `chat-complete` | **Required** (`verify_jwt = true` in `supabase/config.toml`) | `HUGGINGFACE_*` | User JWT; never HF key in release client |
| `sync-graphql-countries` | Off (`--no-verify-jwt`) | Service role | Public trigger → upsert with service role |
| `sync-chart-trending` | Off | Service role | Same pattern |

Agent rules:

- Keep platform JWT verification on for `chat-complete`:
  `verify_jwt = true` in [`supabase/config.toml`](../../supabase/config.toml).
  Do **not** deploy with `--no-verify-jwt`, and do **not** turn off JWT
  verification in the Dashboard. The handler’s `Authorization: Bearer …`
  prefix check is only a secondary guard; the platform gate is the auth
  boundary that keeps invalid tokens from reaching paid Hugging Face calls.
- Dashboard **Verify JWT with legacy secret** is a *signing-key path* toggle,
  not “disable JWT verification.” Keep it **disabled** when the project uses
  the newer signing-key / JWKS path (enabling it can cause false
  `401 auth_required`). Enable only if the project intentionally uses the
  legacy JWT secret. See [`supabase/README.md`](../../supabase/README.md).
- Sync functions are intentionally unauthenticated call surfaces; rate/abuse
  hardening is a product decision — do not “fix” by adding anon table writes.
- Service role usage in Edge is correct; logging must not print keys or JWTs.

Contract detail: [`supabase/README.md`](../../supabase/README.md),
[`ai_integration.md`](ai_integration.md).

---

## Common mistakes (corrected)

| Wrong guidance | Correct for this repo |
| --- | --- |
| “Put service role in the app for admin features” | Never. Use Edge + service role or Dashboard/SQL with audit. |
| “Hide the anon key / treat it as secret” | Anon is public. Secure with RLS and JWT. |
| “Disable RLS in staging” | Keep RLS; use test users and policies. |
| “Filter by `user_id` in Dart instead of RLS” | Client filter is optional UX; RLS is mandatory. |
| “Firebase login is enough for Supabase tables” | Need Supabase session for RLS/`auth.uid()`. |
| “All Edge functions need verify_jwt” | Only `chat-complete` in this repo; syncs are JWT-off by design. |
| “Case study Storage RLS is in migrations” | Not in repo today — verify remote and add migrations. |

---

## Gaps vs a production-hardened template

These are **honest gaps**, not invention targets for drive-by changes:

1. Case study schema/Storage RLS not versioned in `supabase/migrations/`.
2. Sync Edge functions callable without JWT (demo tradeoff).
3. Dual Firebase / Supabase identity (portfolio demo surface).
4. No App Check / device attestation binding for Supabase calls documented here.
5. Realtime channel has no client-side `user_id` filter (depends on RLS).

Do not “close” these by widening access. Prefer migrations, policies, and
documented Edge contracts.

---

## Pre-change checklist (auth / data paths)

Before editing Flutter Supabase clients, migrations, or Edge code:

1. Identify data owner: anon vs authenticated vs service role.
2. Confirm RLS enabled and policies match the intended who/row/action.
3. Confirm no new secret enters `--dart-define`, assets, or Remote Config.
4. If touching Edge: preserve `verify_jwt` intent; validate inputs; no secret logs.
5. If touching IoT offline queue: respect per-user queue isolation
   ([`offline_first/iot_demo.md`](../offline_first/iot_demo.md)).
6. Prefer git-tracked SQL; update
   [`offline_first/supabase_migrations.md`](../offline_first/supabase_migrations.md).
7. Verify: signed-in user sees only own rows; signed-out cannot read protected
   tables; `chat-complete` rejects bad JWT with `401` + `auth_required`.
8. Run focused tests under `apps/mobile/test/` for touched features; follow
   `ai-safe-supabase-workflow`.

---

## Critical finding status (audit)

Repo scan for this handoff: **no Flutter service-role leak** and **no
checked-in disabled-RLS migration** for the versioned IoT/GraphQL/chart tables.
No app-code security fix PR required from this pass.

Highest follow-up: version case-study table + Storage RLS in migrations if the
hosted project already relies on them.
