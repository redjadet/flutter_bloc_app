# Live chat `/ready` surface honesty + verify script

**Date:** 2026-09-28  
**Baseline:** `b986516c` (#919)  
**Branch:** `cursor/live-ready-surface-honesty-6560`

## Intent

Visitor-facing FastAPI Cloud docs advertised `GET /ready` for readiness /
provenance, but the **canonical live origin** OpenAPI only exposed `/health`
and `/v1/chat/completions` (`/ready` → 404). That is deploy drift vs W12 tip
code in `demos/render_chat_api`, not a missing route in tree.

## Changes

| Artifact | Change |
| --- | --- |
| `tool/render_chat_live_surface.py` | Pure OpenAPI path contract (`/health`, `/ready`, `/v1/chat/completions`) |
| `tool/check_render_chat_live_surface.sh` | Operator / post-deploy smoke with cold-start retries |
| `tool/check_render_chat_live_surface_test.py` | Offline unit tests |
| [`demos/render_chat_api/README.md`](../../demos/render_chat_api/README.md) | Ready URL requires W12+ deploy + verify script |
| [`integrations/render_fastapi_chat_demo.md`](../integrations/render_fastapi_chat_demo.md) | Ready + verify pointer |
| [`integrations/render_chat_ops.md`](../integrations/render_chat_ops.md) | § Live surface verify + measured 2026-09-28 probe |

## Non-goals

- Redeploy FastAPI Cloud from this agent (no `.fastapicloud` link / deploy secrets).
- Wire the live check into `./bin/checklist` (network + deploy ownership).
- Renovate / Object soft-fail / claim-ledger SHA-only PR.

## Proof

```bash
python3 -m unittest tool/check_render_chat_live_surface_test.py
./tool/check_render_chat_live_surface.sh  # expect fail until FastAPI Cloud redeploy
ORIGIN=https://flutter-bloc-render-chat-api.onrender.com \
  ./tool/check_render_chat_live_surface.sh  # expect pass (paths present; /ready may be 503)
CHECKLIST_RUN_COVERAGE=0 ./bin/checklist
```
