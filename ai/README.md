---
owner: platform-docs
refresh_when:
  - After modular_metrics or major feature add/remove
  - Before Phase 4 architecture refactors
  - Quarterly or when CONTEXT_MAP drifts
last_refreshed: 2026-07-15
---

# AI operability layer (`/ai`)

Evidence and routing for agents. Engineering canon stays under [`docs/`](../docs/README.md).

## Authority

| Need | Source |
| --- | --- |
| Task → files | [`CODEMAP.md`](../CODEMAP.md) |
| Plan | [`PLAN.md`](../PLAN.md) |
| Agent loop | [`AGENTS.md`](../AGENTS.md), [`docs/agent_knowledge_base.md`](../docs/agent_knowledge_base.md) |
| Architecture canon | [`docs/architecture_details.md`](../docs/architecture_details.md) |
| Governance | [`docs/ai/governance.md`](../docs/ai/governance.md) |
| Discovery snapshots | [`ai/reports/README.md`](reports/README.md) |

## Layout

```text
ai/
  README.md       <- this file
  CONTEXT_MAP.md  <- minimal file sets per pilot feature
  reports/        <- dated metrics and maps, not behavior canon
docs/ai/          <- prompts, governance, context loading
docs/audits/      <- ranked audits; gitignored, force-add when committing
```

## Refresh workflow

1. Run `bash tool/refresh_ai_reports.sh` (includes `tool/modular_metrics.sh` and regenerates bounded metric blocks).
2. Update affected narrative sections under `ai/reports/` when product paths or guidance change.
3. If rankings change, update [`docs/audits/`](../docs/audits/) audit files (`git add -f`).
4. The script bumps `last_refreshed` in this file.

Do **not** paste long canon here—link to `docs/` instead.
