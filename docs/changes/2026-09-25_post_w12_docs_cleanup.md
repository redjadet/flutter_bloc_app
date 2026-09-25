# Post-W12 docs cleanup

**Date:** 2026-09-25  
**Branch:** `cursor/post-w12-docs-cleanup-d7ce`  
**Base:** `dd0ecec5` (#910 W12)

## Intent

After W12 merge: reduce Render/FastAPI doc overlap, keep unique freezes + evidence,
point ops/hardening/rotation at [`integrations/render_chat_ops.md`](../integrations/render_chat_ops.md).

## Changes

| Action | Detail |
| --- | --- |
| Dedupe | [`render_fastapi_chat_demo.md`](../integrations/render_fastapi_chat_demo.md) MCP/deploy/ops bulk → pointers to ops runbook |
| Preserve | STOP table, contract freeze, Flutter client defines, log correlation, cold-start evidence log |
| Index | This change note + store cleanup report |

## Non-goals

- Renaming `authority_*` filenames (optional; labels already scrubbed)
- Claim-ledger SHA refresh
- Rewriting README (already reference-first from #909)
