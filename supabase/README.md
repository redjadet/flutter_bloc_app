# Supabase (migrations and Edge Functions)

## Edge Functions

- **sync-graphql-countries** — Syncs continents/countries from the public GraphQL API into `graphql_continents` and `graphql_countries`. Source: `supabase/functions/sync-graphql-countries/`. Deployed with **verify_jwt: false** (RLS on tables enforces access). App flow: [GraphQL demo](../docs/offline_first/graphql_demo.md). Redeploy: MCP `user-supabase` → `deploy_edge_function` with `name: "sync-graphql-countries"`, `files` from `index.ts`, and `verify_jwt: false`; or CLI: `supabase functions deploy sync-graphql-countries --no-verify-jwt`.
- **sync-chart-trending** — Syncs Bitcoin 7-day market chart from CoinGecko into `chart_trending_points`. Source: `supabase/functions/sync-chart-trending/`. Deployed with **verify_jwt: false**. App flow: [Chart demo](../docs/offline_first/chart_demo.md). Redeploy: MCP `user-supabase` → `deploy_edge_function` with `name: "sync-chart-trending"`, `files` including **both** `index.ts` and `chart_trending_sync.ts` (index imports the helper), and `verify_jwt: false`; or CLI: `supabase functions deploy sync-chart-trending --no-verify-jwt` (CLI bundles the whole folder).
- **chat-complete** — Proxies chat completions to Hugging Face (`router.huggingface.co/v1/chat/completions`) with the user JWT verified first. Source: `supabase/functions/chat-complete/`. Deployed with **`verify_jwt: true`** (see [`config.toml`](config.toml)). App flow: [`docs/plans/supabase_proxy_huggingface_chat_plan.md`](../docs/plans/supabase_proxy_huggingface_chat_plan.md). CLI: `npx supabase functions deploy chat-complete` (default JWT verification on). In the Supabase Dashboard, keep **Verify JWT with legacy secret** disabled for this function when your project uses the newer signing-key path; enabling that toggle can reject otherwise valid user sessions with false `401 auth_required` responses.

### Chat → Hugging Face proxy (`chat-complete`)

Implementation: [`functions/chat-complete/index.ts`](functions/chat-complete/index.ts).
Policy and matrix: [`docs/plans/supabase_proxy_huggingface_chat_plan.md`](../docs/plans/supabase_proxy_huggingface_chat_plan.md)
and [`docs/ai_integration.md`](../docs/ai_integration.md).

Required secrets/env:

| Secret / env | Purpose |
| --- | --- |
| `HUGGINGFACE_API_KEY` | Hugging Face Inference API token |
| `HUGGINGFACE_MODEL` | Default model id when the client omits `model` or when no allowlist is set |
| `HUGGINGFACE_MODEL_ALLOWLIST` | Optional comma-separated list. If set, client `model` must be one of these; if unset, client `model` must match `HUGGINGFACE_MODEL` or be omitted |

Also required in the Edge runtime: `SUPABASE_URL`, `SUPABASE_ANON_KEY` (Supabase injects these for deployed functions).

Configure HF secrets in Dashboard (**Edge Functions → Secrets**) or `supabase secrets set`.

JWT settings:

- [`config.toml`](config.toml): `[functions.chat-complete]` must keep `verify_jwt = true`.
- Dashboard → **Edge Functions** → `chat-complete`: keep **Verify JWT with legacy secret** disabled unless the project intentionally uses the legacy JWT-secret path.
- Function code should not add a second `auth.getUser()` round-trip after the platform has already accepted the JWT.

#### Deploy `chat-complete` to your hosted project

From the repo root (after `npx supabase link --project-ref <your-ref>` if needed):

```bash
npx supabase functions deploy chat-complete
```

Set function secrets in the Dashboard (**Edge Functions → Secrets**) or via `supabase secrets set`, at minimum `HUGGINGFACE_API_KEY` and `HUGGINGFACE_MODEL` (see table above). Optionally set `HUGGINGFACE_MODEL_ALLOWLIST` if multiple models are allowed.

Deploy checklist:

1. Confirm [`config.toml`](config.toml) still has `[functions.chat-complete]` with `verify_jwt = true`.
2. Deploy from the repo root with `npx supabase functions deploy chat-complete`.
3. In Supabase Dashboard, open **Edge Functions** → `chat-complete` and verify:
   - JWT verification is enabled for the function.
   - **Verify JWT with legacy secret** is disabled.
4. Re-confirm function secrets: `HUGGINGFACE_API_KEY`, `HUGGINGFACE_MODEL`, and optional `HUGGINGFACE_MODEL_ALLOWLIST`.
5. Run the hosted curl smoke check below with a fresh user access token before testing in Flutter.

Avoid `--no-verify-jwt` for `chat-complete`. That would bypass the intended auth boundary and diverge from the client/runtime contract.

If the app or logs show **Requested function was not found**, the `chat-complete` function is not deployed on the Supabase project your app is using (wrong project, or deploy was never run). The Flutter client treats that as `missing_configuration` and, when a device Hugging Face key is allowed, **falls back to direct** chat until the function exists.

#### Troubleshooting `401 auth_required` vs `Requested function was not found`

- `401 auth_required`: function exists, but the request failed the auth gate.
  Check:
  1. app session is present and fresh
  2. [`config.toml`](config.toml) still has `verify_jwt = true`
  3. **Verify JWT with legacy secret** is disabled
  4. app and function point to the same Supabase project
- `Requested function was not found`: deployment/targeting problem, not auth.
  Check:
  1. `chat-complete` is actually deployed
  2. `npx supabase link --project-ref ...` points to the correct hosted project
  3. function name is exactly `chat-complete`
  4. request URL hits the intended Supabase project
- Fast rule: `401` = auth/JWT/project alignment, `not found` = deploy/target mismatch

#### Verify app and function use the same Supabase project

Dashboard checks:

- **Project Settings** → **API**
  - verify **Project URL**
  - verify **Project API keys** → `anon public`
- **Edge Functions** → `chat-complete`
  - verify the function exists in that same project

Repo / CLI checks:

1. Check the app-configured project in [`secrets.json`](/Users/ilkersevim/Flutter_SDK/projects/bloc_test_app/flutter_bloc_app/assets/config/secrets.json):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
2. Check which hosted project the local CLI is linked to:

```bash
npx supabase status
```

   or, if needed:

```bash
npx supabase link --project-ref <your-project-ref>
```

1. Deploy only after confirming the linked project matches the app `SUPABASE_URL` host.
2. If there is any doubt, compare:
   - app host from `SUPABASE_URL`
   - dashboard project URL
   - CLI linked project ref / target

Mismatch signals:

- App hits one project but Dashboard `chat-complete` exists in another.
- `Requested function was not found` even though the function is visible in Dashboard.
- Auth works in the app, but the function behaves like the user/session does not exist for that project.

#### Frozen contract for implementation handoff

Use this contract unless the plan and `docs/ai_integration.md` are updated in
the same change set.

| Topic | Contract |
| --- | --- |
| Function name | `chat-complete` |
| Auth | `Authorization: Bearer <supabase_user_jwt>`; invalid/missing session returns `401` + `code: auth_required` before HF |
| Request body | JSON: `schemaVersion` (number, must be `1`), `messages` (non-empty array of `{ role, content }` with `role` in `user` \| `assistant` \| `system`), optional `model`, optional `clientMessageId` (non-empty string if present) |
| Request limits | Max body **512 KiB**; larger bodies → `413` + `invalid_request` |
| Upstream | `POST https://router.huggingface.co/v1/chat/completions` with `stream: false`; upstream fetch timeout **120s** (maps to `upstream_timeout` / `upstream_unavailable` as documented below) |
| Model policy | Effective model = client `model` when allowed by allowlist / pinned rules; otherwise `400` + `invalid_request` (see env table above) |
| Success response | `200` JSON: `schemaVersion` (`1`), `assistantMessage` (`{ role: "assistant", content: string }`), `metadata` (optional `clientMessageId`, `model`) — no secrets |
| Error response | JSON body: `code`, `retryable`, `message`, optional `details` (stable, machine-readable; no secrets) |
| Error vocabulary | `auth_required` (401), `forbidden` (403), `rate_limited` (429), `invalid_request` (400/413/405), `upstream_timeout` (504, `retryable: true`), `upstream_unavailable` (502, `retryable: true`), `missing_configuration` (500, `retryable: false`) |
| Idempotency | `clientMessageId` echoed in `metadata` / error `details` for correlation with queued replay; no persistent dedupe store in Edge |
| Timeout budget | **120s** upstream budget; Flutter client should use a shorter budget than this plus network margin to avoid false direct fallback |

#### Local invoke / curl (after `supabase start` or against hosted project)

1. Obtain a valid **user** `access_token` (Supabase Auth).
2. `curl -i -X POST "$SUPABASE_URL/functions/v1/chat-complete" -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"schemaVersion":1,"messages":[{"role":"user","content":"Hello"}],"clientMessageId":"test-1"}'`
3. Negative check: same request with `Authorization: Bearer invalid` → `401` + `auth_required`.

#### Baseline transport policy

- Retryable Edge failures are limited to **timeout**, **transport/network
  failure**, and **5xx**.
- **401/403**, **429**, invalid payload, and missing config are terminal at the
  request level and must not trigger direct fallback from the client.
- Direct fallback is allowed only when the app is online, a client HF key
  exists, and build policy permits direct transport.
- If Supabase is configured but the user has no valid session, the client may
  use direct HF only when build policy allows it; otherwise it must surface
  auth-required UX and skip the proxy call.

**Prime tables (one-off sync):** From repo root, run `./script/prime_supabase_tables.sh`. Requires `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the process environment (for example from **`direnv`** / `.envrc`—see [`docs/envrc.example`](../docs/envrc.example)) or in a local `assets/config/secrets.json` file if you keep one for scripts only (it is **not** bundled in the app by default). Invokes both functions once so the app can read from tables on first load.

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
