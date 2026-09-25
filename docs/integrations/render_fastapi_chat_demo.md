# Render + FastAPI + Flutter chat demo — integration freezes

Canonical **product / ops freezes** for the Render + FastAPI chat demo. Historical build plan removed 2026-07-17 — use this file + `demos/render_chat_api/`.

**Ops / W12 runbook** (provenance, readiness, threat-model table, secret rotation, smoke/rollback): [`render_chat_ops.md`](render_chat_ops.md).

## FastAPI Cloud deployment (current)

- **Live URL**: `https://render-chat-api.fastapicloud.dev`
- **Docs**: `https://render-chat-api.fastapicloud.dev/docs`
- **Health**: `https://render-chat-api.fastapicloud.dev/health`

### Quick deploy (FastAPI Cloud)

From the repo root:

```bash
./tool/deploy_fastapi_cloud_chat_api.sh
```

### FastAPI Cloud required environment

The deployed service validates Firebase ID tokens when `CALLER_AUTH_MODE=firebase`
and calls Hugging Face with a server-held credential. Set these in the FastAPI
Cloud app's environment:

- `CALLER_AUTH_MODE=firebase`
- `FIREBASE_PROJECT_ID=<your firebase project id>` (for this repo’s app, typically `flutter-bloc-app-697e8`)
- `HUGGINGFACE_API_KEY=<server-side provider token>`

Missing Firebase project configuration returns **401** `auth_required`; a
missing Hugging Face credential returns **503** `server_misconfigured`. Neither
credential is returned to Flutter.

## Cursor agent gate

Before writing code, Cursor agents should confirm:

1. The active slice and write set are recorded in [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md).
2. Any STOP row the slice depends on is either resolved below or explicitly using the plan default.
3. FastAPI contract fields used by Flutter are frozen here before repository/UI work begins.
4. After Python changes under `demos/render_chat_api` or repo `tool/`, run **`./tool/check_pyright_python.sh`** before merge (or rely on **`./bin/checklist`**, which includes it).

Do not rely on branch-local assumptions that only live in chat history.

## STOP resolutions (defaults until product overrides)

| # | Topic | Recorded default |
| --- | --- | --- |
| 1 | Caller auth | **Firebase ID token required** on every Render chat request via `Authorization: Bearer <id_token>`. App Check is optional and deferred for v1. |
| 2 | HF credential ownership | The FastAPI service reads `HUGGINGFACE_API_KEY` from its server environment in every flavor. Flutter never receives or forwards the provider credential. |
| 3 | Anonymous cache policy | If caller identity is not verified, **disable server response cache** for that request. No anonymous shared cache bucket in v1. |
| 4 | Header names | Caller auth = **`Authorization`**. Demo gate = **`X-Render-Demo-Secret`**. Idempotency = **`Idempotency-Key`**. Optional client correlation = **`X-Client-Correlation-Id`** (server logs + success **`_render_meta`**). No Hugging Face credential header is accepted. |
| 6 | Overload vs rate limit | Semaphore saturation → **503** + `upstream_unavailable`, `retryable: true`. **429** + `rate_limited` reserved for upstream HF only. |
| 7 | Complexity thresholds | **Complex** if any: latest user message `> 400` chars; total normalized chars `> 1200`; message count `> 8`; fenced code block present; or latest user message contains `2+` markers from bullet/numbered-list items, `compare`, `analyze`, `design`, `architecture`, `refactor`, `debug`, `step-by-step`. Otherwise **simple**. |
| 8 | Permanent `auth_required` on replay | **Dead-letter** after one dequeue attempt; terminal failed state + `chatAuthRefreshRequired` / `chatSessionEnded` UX; no infinite retry. |
| 10 | Transport + l10n | `ChatInferenceTransport.renderOrchestration`; ARB keys listed in plan STOP #10 (`chatModelAuto`, `chatTransportRenderOrchestration`, …). |
| 11 | Workers | Single **uvicorn** process (no `--workers > 1`) while using in-process cache + semaphore without Redis. |
| 12 | Fixtures | **`test/fixtures/render_chat_contract/`** only; Dart + pytest updated **same PR** when envelope fields change. |

These defaults make the v1 plan autonomous for Cursor agents. Product overrides must update this table and the plan in the same PR.

## Contract freeze checklist

Record these before broad Flutter integration starts:

- Caller-auth mode for Render (`Authorization` with Firebase ID token vs alternate JWT).
- Exact header names for optional demo secret, idempotency, optional client **`X-Client-Correlation-Id`**, and caller auth; confirm no upstream credential header exists.
- Success/error JSON envelope fields and the frozen machine-readable `code` values; success payloads include **`_render_meta`** (`server_request_id`, optional `client_correlation_id`) for client log correlation when CDN/proxies omit custom response headers.
- `model: "auto"` sentinel and allowlisted explicit model ids.
- Shared fixture filenames under `test/fixtures/render_chat_contract/`.
- Complexity-threshold examples in tests matching the frozen heuristic above.

## Expected first PR sequence

Historical v1 sequence (contract → Flutter wiring → UI/l10n → docs) is complete; new work follows STOP table + [`render_chat_ops.md`](render_chat_ops.md).

## Python validation (FastAPI + repo `tool/`)

- **`./tool/check_pyright_python.sh`** — Pyright on `demos/render_chat_api` and `tool/`; rejects invalid repo-root `pyrightconfig.json` (e.g. `venvPath` nested under `executionEnvironments`); creates `demos/render_chat_api/.venv` and installs `requirements.txt` when missing. Runs as part of **`./bin/checklist`** / **`./tool/delivery_checklist.sh`** (see [`docs/validation_scripts.md`](../validation_scripts.md)).
- **pytest** — From `demos/render_chat_api`: `python -m pytest` (shared fixtures under [`test/fixtures/render_chat_contract/`](../../apps/mobile/test/fixtures/render_chat_contract)).
- **Editor** — Basedpyright/Pyright: [`demos/render_chat_api/README.md`](../../demos/render_chat_api/README.md) (IDE section).

## Render MCP / deploy trigger

Workspace Render MCP can list services, env, logs, and metrics after a service exists.
**Blueprint provision**, deploy trigger, `RENDER_API_KEY` handling, provenance, readiness,
rollback, and secret rotation live in [`render_chat_ops.md`](render_chat_ops.md).

Quick pointers:

- Validate blueprint: `render blueprints validate demos/render_chat_api/render.yaml`
- Trigger deploy: [`tool/trigger_render_chat_api_deploy.sh`](../../tool/trigger_render_chat_api_deploy.sh)
- Typical Render origin: `https://flutter-bloc-render-chat-api.onrender.com` (set Flutter base URL; never paste Render API keys into the app)

## Ops / timeouts (cold start)

Cold-start measurement checklist and Dio timeouts: keep the evidence log here; full
ops (health vs ready, smoke, rollback) → [`render_chat_ops.md`](render_chat_ops.md).

### Cold-start vs Flutter Dio (manual verification)

The Render path uses **dedicated Dio** options from [`render_chat_dio_factory.dart`](../../apps/mobile/lib/features/chat/data/render_chat_dio_factory.dart) (`createRenderChatDio`):

| Option | Value |
| --- | --- |
| `connectTimeout` | 30s |
| `sendTimeout` | 60s |
| `receiveTimeout` | 120s |
| `followRedirects` | `false` |

Scale-to-zero or small Render plans can push the **first** `POST /v1/chat/completions` after idle toward **connect** or **receive** limits. When **`CHAT_RENDER_DEMO_STRICT`** is **false**, **retryable** failures may **fall through** to composite; when **strict** is **true**, the user sees a terminal Render failure without composite fallback.

Append measured cold-start rows only (no invented wall times):

| Date (UTC) | Environment | Cold POST wall (s) | Strict (`CHAT_RENDER_DEMO_STRICT`) | Fallthrough observed | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-04-12 | Render free web `flutter-bloc-render-chat-api` (Oregon) + `curl /health` | ~57 | n/a | n/a | First successful `GET …/health` after cold start (~56.7s). |
| *— add row per run —* | e.g. prod Render + `main_dev` iOS | *measure* | Y/N | Y/N / n/a | PR, ticket, or build id optional |

## Flutter client (`SecretConfig` compile-time defines)

- **Client configuration:** Export only non-secret `CHAT_FASTAPICLOUD_*` routing values (preferred; legacy `CHAT_RENDER_*` still supported) from `.envrc` or `.env`. The mobile app sends Firebase identity and payload; the FastAPI service owns `HUGGINGFACE_API_KEY`.
- **Store release (Fastlane):** Android and iOS release/profile paths reject provider keys and demo shared secrets in Dart defines. Keep `HUGGINGFACE_API_KEY`, Gemini/Google keys, and `CHAT_*_DEMO_SECRET` out of mobile release environments. See [Security and Secrets](../security_and_secrets.md).
- `CHAT_FASTAPICLOUD_DEMO_ENABLED` / `CHAT_RENDER_DEMO_ENABLED` — when `true`, the orchestration **runnable** gate in [`register_chat_services.dart`](../../apps/mobile/lib/app/composition/features/register_chat_services.dart) (`_chatRenderOrchestrationRunnable`) requires a non-empty base URL, a signed-in **Firebase** user, **`https`** origin in release builds, and registered `FirebaseAuth`. The Render repository sends Firebase identity and request data only; provider-key availability is a server-side readiness concern. **DemoFirstChatRepository** still orders orchestration before composite when the gate passes.
- `CHAT_FASTAPICLOUD_DEMO_BASE_URL` / `CHAT_RENDER_DEMO_BASE_URL` — service origin (no trailing slash); release builds require `https`.
- `CHAT_FASTAPICLOUD_DEMO_STRICT` / `CHAT_RENDER_DEMO_STRICT` — when `true`, no fallthrough to composite after a retryable orchestration failure.
- `CHAT_FASTAPICLOUD_DEMO_SECRET` / `CHAT_RENDER_DEMO_SECRET` — dev-only compatibility headers. Never ship either value in a mobile artifact.
- The former `issueRenderChatDemoHfReadToken` Callable is retired and fails closed. Configure `HUGGINGFACE_API_KEY` only in the FastAPI service’s secret manager; the client never receives or forwards this upstream credential.
- **Offline dequeue dead-letter:** non-retryable remote failures during `processOperation` mark the user bubble with `terminalSyncFailureCode` (same string as `ChatRemoteFailureException.code`), complete the pending op, and show plan ARB copy under the bubble (no infinite retry).
- **Live send errors:** `ChatCubit` keeps `remoteFailureL10nCode` alongside `error` for `ChatRemoteFailureException`; the chat screen snackbar uses the same ARB mapping as terminal dequeue (`terminalSyncFailureMessage`) instead of raw upstream text when a code is present.
- **Legacy compatibility:** `token_missing` localization and token-provider types may remain for older/direct chat paths, but the current Render repository does not resolve or send an HF token. Render authentication failures use server JSON `auth_required`; missing server provider configuration uses `server_misconfigured`.
- **Logout vs queue:** Pending chat sync operations survive Firebase sign-out. A later dequeue without a valid Firebase session reaches the Render caller-auth boundary and fails with non-retryable `auth_required` until the user re-authenticates or existing offline-first UX clears the row.

## Log correlation (Flutter ↔ Render)

On each `POST /v1/chat/completions`, the Flutter client sends **`X-Client-Correlation-Id`** (a unique value per request; see [`render_fastapi_chat_repository.dart`](../../apps/mobile/lib/features/chat/data/render_fastapi_chat_repository.dart)). In **debug**, the client logs that id before the POST and, after a 2xx response, logs **`server_request_id`** preferring the JSON field **`_render_meta.server_request_id`** (so correlation still works if a proxy strips custom response headers), then falling back to **`X-Server-Request-Id`**.

The FastAPI service logs **`chat_completions_begin`** and **`chat_completions_ok`** with **`server_request_id`** (UUID) and the same **`client_correlation_id`** when the header was present. Success JSON includes **`_render_meta`** with **`server_request_id`** and **`client_correlation_id`** (when sent), and the same values are repeated on response headers **`X-Server-Request-Id`** and **`X-Client-Correlation-Id`** when intermediaries pass them through. Grep Render logs for the UUID or the client correlation id and match the Flutter line for the same send.

CORS allowlist for browser clients includes **`x-client-correlation-id`** (see [`demos/render_chat_api/settings.py`](../../demos/render_chat_api/settings.py) `FROZEN_ALLOW_HEADERS`).

**Debug-only client diagnostics** (kDebug / `AppLogger`): the repository also logs Render’s **`rndr-id`** response header when present. If logs show **`_render_meta=false`** on a 2xx body while **`completion_id`** looks valid, the **running service** is behind the commit that adds `_render_meta`—confirm the git branch Render builds, push, then redeploy (script above or Dashboard).

## Security notes

- **Caller auth** on the client: dedicated DI provider; Render path sends no HF credential header.
- Hardening table, secret rotation, and accepted residual risks: [`render_chat_ops.md`](render_chat_ops.md).

## Links

- Ops runbook: [`render_chat_ops.md`](render_chat_ops.md).
- [`AGENTS.md`](../../AGENTS.md) — delivery and validation routing.
- Codex plan review: `./tool/run_codex_plan_review.sh docs/integrations/render_fastapi_chat_demo.md`.
