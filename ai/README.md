---
owner: platform-docs
refresh_when:
  - After modular_metrics or major feature add/remove
  - Before Phase 4 architecture refactors
  - Quarterly or when CONTEXT_MAP drifts
last_refreshed: 2026-05-21
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

1. Run `bash tool/modular_metrics.sh` and `bash tool/modular_metrics.sh --cross-feature-only`.
2. Update affected reports under `ai/reports/`.
3. If rankings change, update [`docs/audits/`](../docs/audits/) audit files (`git add -f`).
4. Bump `last_refreshed` in this file.

Do **not** paste long canon here—link to `docs/` instead.
