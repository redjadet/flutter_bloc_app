---
owner: platform-docs
refresh_when:
  - After modular_metrics or major feature add/remove
  - Before Phase 4 architecture refactors
  - Quarterly or when CONTEXT_MAP drifts
last_refreshed: 2026-05-21
---

# AI operability layer (`/ai`)

Agent-facing **evidence and routing** for this repo. Engineering canon stays under [`docs/`](../docs/README.md).

## Authority

| Need | Read first |
| --- | --- |
| Task → files | [`CODEMAP.md`](../CODEMAP.md) |
| Plan / phases | [`PLAN.md`](../PLAN.md) → [`docs/plans/2026-05-21_ai_first_engineering_plan.md`](../docs/plans/2026-05-21_ai_first_engineering_plan.md) |
| Agent loop / validation | [`AGENTS.md`](../AGENTS.md), [`docs/agent_knowledge_base.md`](../docs/agent_knowledge_base.md) |
| Architecture canon | [`docs/architecture_details.md`](../docs/architecture_details.md) |
| Governance & roles | [`docs/ai/governance.md`](../docs/ai/governance.md) |
| Discovery snapshots | [`ai/reports/README.md`](reports/README.md) |

## Layout

```text
ai/
  README.md           ← this file
  CONTEXT_MAP.md      ← minimal file sets per pilot feature (Wave 1B)
  reports/            ← dated metrics and maps (not behavior canon)
docs/ai/              ← prompts, governance (Wave 2)
docs/audits/          ← ranked audits (gitignored; force-add when committing)
```

## Refresh workflow

1. Run `bash tool/modular_metrics.sh` and `--cross-feature-only`.
2. Update affected reports under `ai/reports/`.
3. If rankings change, update [`docs/audits/`](../docs/audits/) audit files (`git add -f`).
4. Bump `last_refreshed` in this file.

Do **not** paste long canon here—link to `docs/` instead.
