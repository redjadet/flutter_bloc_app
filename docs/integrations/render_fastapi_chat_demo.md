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
| 6 | Overload vs rate limit | Semaphore saturation → **503** + `upstream_unavailable`, `retryable: true`. **429** + `rate_limited` reserved for upstream HF only. |
| 8 | Permanent `auth_required` on replay | **Dead-letter** after one dequeue attempt; terminal failed state + `chatAuthRefreshRequired` / `chatSessionEnded` UX; no infinite retry. |
| 10 | Transport + l10n | `ChatInferenceTransport.renderOrchestration`; ARB keys listed in plan STOP #10 (`chatModelAuto`, `chatTransportRenderOrchestration`, …). |
| 11 | Workers | Single **uvicorn** process (no `--workers > 1`) while using in-process cache + semaphore without Redis. |
| 12 | Fixtures | **`test/fixtures/render_chat_contract/`** only; Dart + pytest updated **same PR** when envelope fields change. |

**Still human-owned (fill before prod):** STOP **#1** caller-auth mode (Firebase vs Callable vs public lab), **#2** HF delivery by flavor, **#3** anonymous cache policy, **#4** exact header spellings, **#7** complexity scorer numbers.

## Contract freeze checklist

Record these before broad Flutter integration starts:

- Caller-auth mode for Render (`Authorization` with Firebase ID token vs alternate JWT).
- Exact header names for HF token, optional demo secret, idempotency, and any caller-auth header.
- Success/error JSON envelope fields and the frozen machine-readable `code` values.
- `model: "auto"` sentinel and allowlisted explicit model ids.
- Shared fixture filenames under `test/fixtures/render_chat_contract/`.

## Expected first PR sequence

1. FastAPI contract + orchestration skeleton + pytest using the shared fixture root.
2. Flutter Render repository + provider/DI wiring against the frozen contract.
3. UI/l10n + auth/session/token surfaced states.
4. Docs / validation cleanup.

## Ops / timeouts

- Validate **cold-start** first `POST` latency vs Flutter **Dio** timeouts; document chosen timeout floor or intentional fallthrough on first cold hit.

## Security notes

- **Caller auth header** on the client: owned by a dedicated DI provider (see plan **Caller auth implementation contract**), separate from HF token provider.
- **FastAPI:** per-uid/IP limits, max body/header sizes, auth-failure telemetry; v1 **no** user-controlled upstream hosts (HF base fixed; future tools need allowlists).

## Links

- [`AGENTS.md`](../../AGENTS.md) — delivery and validation routing.
- Codex plan review: `./tool/run_codex_plan_review.sh docs/plans/render_fastapi_chat_demo_plan.md`.
