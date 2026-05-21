# Context loading ladder

Minimum context order for agents.

## Ladder

1. [`AGENTS.md`](../../AGENTS.md)
2. [`CODEMAP.md`](../../CODEMAP.md) or [`PLAN.md`](../../PLAN.md)
3. [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md)
4. Feature rows in [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md)
5. Canon docs linked from [`docs/README.md`](../README.md)
6. Evidence only when claiming debt: `ai/reports/`, `docs/audits/`

## Avoid loading early

- Entire `lib/features/<large>/` trees before `CONTEXT_MAP`
- Duplicate testing prose: use [`docs/testing/testing_strategy.md`](../testing/testing_strategy.md), then [`testing_overview.md`](../testing_overview.md)
- Cursor plan files outside `docs/plans/` unless updating the plan

## Refresh triggers

See [`ai/README.md`](../../ai/README.md) `refresh_when` frontmatter.

## Multitask sessions

Declare role from [`governance.md`](governance.md). Compact evidence; reset plan when state corrupts.
