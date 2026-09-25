# W12 — Render / FastAPI chat ops hardening

**Date:** 2026-09-25  
**Branch:** `cursor/w12-render-chat-ops-d7ce`  
**Base:** `f5532e22` (#909)

## Scope

Ship deferred Phase 3 **W12**: deployment provenance, threat-model hardening
table, pytest/Pyright smoke path, secret rotation ops, and targeted hardening of
`demos/render_chat_api` (readiness, body/stream guard, correlation bound, async
Firebase verify off the event loop).

## Deliverables

| Item | Path / proof |
| --- | --- |
| Ops runbook | [`docs/integrations/render_chat_ops.md`](../integrations/render_chat_ops.md) |
| `/ready` + provenance fields | `demos/render_chat_api/main.py` |
| Body / header hardening | middleware + `MAX_CORRELATION_ID_LEN` |
| Tests | `demos/render_chat_api/tests/test_api.py` (ready, auth, 413, correlation) |
| Scope / plan ticks | `docs/scope_register.md` + store plan |

## Validation

```bash
cd demos/render_chat_api && python -m pytest
./tool/check_pyright_python.sh
```

## Non-goals

- Flutter transport/DI changes (parity already documented; not required for this slice)
- Redis-backed rate limit / multi-worker
- Trusted-proxy IP rewriting
