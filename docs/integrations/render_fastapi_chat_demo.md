# Render + FastAPI + Flutter chat demo — integration freezes

Canonical implementation plan: [`docs/plans/render_fastapi_chat_demo_plan.md`](../plans/render_fastapi_chat_demo_plan.md). This document records **product / ops freezes** so agents do not re-derive policy from the plan alone.

## Cursor agent gate

Before writing code, Cursor agents should confirm:

1. The active slice and write set are recorded in [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md).
2. Any STOP row the slice depends on is either resolved below or explicitly using the plan default.
3. FastAPI contract fields used by Flutter are frozen here before repository/UI work begins.

Do not rely on branch-local assumptions that only live in chat history.

## STOP resolutions (defaults until product overrides)

| # | Topic | Recorded default |
| --- | --- | --- |
| 1 | Caller auth | **Firebase ID token required** on every Render chat request via `Authorization: Bearer <id_token>`. App Check is optional and deferred for v1. |
| 2 | HF delivery by flavor | **dev** = Firebase Remote Config demo-scoped HF read token. **staging/prod** = Callable or equivalent short-lived backend-issued token only. |
| 3 | Anonymous cache policy | If caller identity is not verified, **disable server response cache** for that request. No anonymous shared cache bucket in v1. |
| 4 | Header names | Caller auth = **`Authorization`**. HF token = **`X-HF-Authorization`**. Demo gate = **`X-Render-Demo-Secret`**. Idempotency = **`Idempotency-Key`**. |
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
- Exact header names for HF token, optional demo secret, idempotency, and any caller-auth header.
- Success/error JSON envelope fields and the frozen machine-readable `code` values.
- `model: "auto"` sentinel and allowlisted explicit model ids.
- Shared fixture filenames under `test/fixtures/render_chat_contract/`.
- Complexity-threshold examples in tests matching the frozen heuristic above.

## Expected first PR sequence

1. FastAPI contract + orchestration skeleton + pytest using the shared fixture root.
2. Flutter Render repository + provider/DI wiring against the frozen contract.
3. UI/l10n + auth/session/token surfaced states.
4. Docs / validation cleanup.

## Ops / timeouts

### Cold-start vs Flutter Dio (manual verification)

The Render path uses **dedicated Dio** options from [`render_chat_dio_factory.dart`](../../lib/features/chat/data/render_chat_dio_factory.dart) (`createRenderChatDio`):

| Option | Value |
| --- | --- |
| `connectTimeout` | 30s |
| `sendTimeout` | 60s |
| `receiveTimeout` | 120s |
| `followRedirects` | `false` |

Scale-to-zero or small Render plans can push the **first** `POST /v1/chat/completions` after idle toward **connect** or **receive** limits. When **`CHAT_RENDER_DEMO_STRICT`** is **false**, **retryable** failures (including some timeout-class behavior mapped in [`render_chat_failure_mapper.dart`](../../lib/features/chat/data/render_chat_failure_mapper.dart)) may **fall through** to composite per the plan fallthrough matrix; when **strict** is **true**, the user sees a terminal Render failure without composite fallback.

**Checklist (run after meaningful Render, Dio, or fallthrough policy changes):**

1. **Cold instance:** Idle the service until scale-to-zero (or use a fresh preview deploy).
2. **Measure first POST:** Call `POST /v1/chat/completions` with production-like headers (`Authorization`, `X-HF-Authorization`, `Idempotency-Key`, optional `X-Render-Demo-Secret`) and record wall time to first complete response (e.g. `curl -w '\n%{time_total}\n'` or Render **Metrics / Logs**).
3. **Compare to Dio:** Confirm typical cold path stays **under** `receiveTimeout` (120s) for success, or explicitly document product choice to rely on **fallthrough** / user-visible timeout when stricter budgets are set later.
4. **Client path:** Repeat once on **emulator or device** on a representative network; watch for **connect** stalls approaching **30s**.
5. **Append one evidence row** to the table below.

**Evidence log (append rows; keep history)**

Do not append numeric **Cold POST wall (s)** values without a primary measurement (for example `curl -w '%{time_total}\n'`, Render request metrics, or instrumented client timestamps). Keep the template row until a real cold run is recorded.

| Date (UTC) | Environment | Cold POST wall (s) | Strict (`CHAT_RENDER_DEMO_STRICT`) | Fallthrough observed | Notes |
| --- | --- | --- | --- | --- | --- |
| *— add row per run —* | e.g. prod Render + `main_dev` iOS | *measure* | Y/N | Y/N / n/a | PR, ticket, or build id optional |

## Flutter client (`SecretConfig` compile-time defines)

- **direnv / local env:** Export the `CHAT_RENDER_*` variables (and secrets like `HUGGINGFACE_API_KEY`) from `.envrc` as in [`docs/envrc.example`](../envrc.example). The repo `flutter` wrapper (see [Security and Secrets](../security_and_secrets.md) Option B) reads only keys emitted by [`tool/flutter_dart_defines_from_env.sh`](../../tool/flutter_dart_defines_from_env.sh); add new `fromEnvironment` keys there if you introduce more compile-time toggles.
- `CHAT_RENDER_DEMO_ENABLED` — when `true`, the orchestration **runnable** gate in [`register_chat_services.dart`](../../lib/core/di/register_chat_services.dart) (`_chatRenderOrchestrationRunnable`) requires a non-empty base URL, a signed-in **Firebase** user, **`https`** origin in release builds, and registered `FirebaseAuth`. **HF read token** presence is enforced in [`render_fastapi_chat_repository.dart`](../../lib/features/chat/data/render_fastapi_chat_repository.dart) at send time (empty → client `token_missing`), not inside that gate. **DemoFirstChatRepository** still orders Render before composite when the gate passes.
- `CHAT_RENDER_DEMO_BASE_URL` — Render service origin (no trailing slash); release builds require `https`.
- `CHAT_RENDER_DEMO_STRICT` — when `true`, no fallthrough to composite after a retryable Render failure.
- `CHAT_RENDER_DEMO_SECRET` — optional `X-Render-Demo-Secret` (dev / non-web smoke only; do not ship in web release per plan).
- Hugging Face read token for `X-HF-Authorization`: see [`render_orchestration_hf_token_provider.dart`](../../lib/features/chat/data/render_orchestration_hf_token_provider.dart) — **dev:** Remote Config **`RENDER_CHAT_DEMO_HF_READ_TOKEN`**, optional one-shot `forceFetch` when Firebase is up, cache key **`render_chat_orchestration_hf_token_v1`** (migrates legacy `render_chat_demo_rc_hf_read_token_v1` on read). **Non-dev:** when **`CHAT_RENDER_HF_READ_TOKEN_CALLABLE`** is non-empty, calls that HTTPS Callable in **`CHAT_RENDER_HF_READ_TOKEN_CALLABLE_REGION`** (default `us-central1`), expects JSON with **`hf_read_token`** or **`token`**, caches the trimmed value, then falls back to **`SecretConfig.huggingfaceApiKey`**. Single-flight reads; **`ChatCubit`** clears both cache keys on Firebase sign-out when the provider is registered.
- **Firebase Callable (this repo):** `functions` exports **`issueRenderChatDemoHfReadToken`** (v2 `onCall`, region **`us-central1`**, requires signed-in user). Set secret **`RENDER_CHAT_DEMO_HF_READ_TOKEN`** to the Hugging Face read token (`firebase functions:secrets:set RENDER_CHAT_DEMO_HF_READ_TOKEN`), deploy **`firebase deploy --only functions:issueRenderChatDemoHfReadToken`**, then build the app with e.g. `--dart-define=CHAT_RENDER_HF_READ_TOKEN_CALLABLE=issueRenderChatDemoHfReadToken` (add `--dart-define=CHAT_RENDER_HF_READ_TOKEN_CALLABLE_REGION=...` only if you change the function region away from `us-central1`). Emulator: set env **`RENDER_CHAT_DEMO_HF_READ_TOKEN`** on the Functions emulator for local token issuance without the secret.
- **Offline dequeue dead-letter:** non-retryable remote failures during `processOperation` mark the user bubble with `terminalSyncFailureCode` (same string as `ChatRemoteFailureException.code`), complete the pending op, and show plan ARB copy under the bubble (no infinite retry).
- **Live send errors:** `ChatCubit` keeps `remoteFailureL10nCode` alongside `error` for `ChatRemoteFailureException`; the chat screen snackbar uses the same ARB mapping as terminal dequeue (`terminalSyncFailureMessage`) instead of raw upstream text when a code is present.
- **Client-only machine code:** **`token_missing`** — HF read token is absent before the outbound Render request (Flutter preflight in [`render_fastapi_chat_repository.dart`](../../lib/features/chat/data/render_fastapi_chat_repository.dart)); maps to ARB **`chatTokenMissing`**. Distinct from server JSON **`auth_required`** (Firebase / caller auth).
- **Logout vs queue:** Clearing orchestration token cache on Firebase sign-out does not delete pending chat sync operations; the next dequeue may hit Render without a valid HF token and surface a non-retryable remote failure until the user re-authenticates or the row is cleared per existing offline-first chat UX.

## Security notes

- **Caller auth header** on the client: owned by a dedicated DI provider (see plan **Caller auth implementation contract**), separate from HF token provider.
- **FastAPI:** per-uid/IP limits, max body/header sizes, auth-failure telemetry; v1 **no** user-controlled upstream hosts (HF base fixed; future tools need allowlists).

## Links

- [`AGENTS.md`](../../AGENTS.md) — delivery and validation routing.
- Codex plan review: `./tool/run_codex_plan_review.sh docs/plans/render_fastapi_chat_demo_plan.md`.
