# Context loading ladder

Order for agents to minimize tokens and wrong assumptions.

## Ladder

1. [`AGENTS.md`](../../AGENTS.md) — map and loop
2. [`PLAN.md`](../../PLAN.md) or task-specific row in [`CODEMAP.md`](../../CODEMAP.md)
3. [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md) — harness + operator prefs
4. Feature-specific: [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md)
5. Canon depth: linked doc from `docs/README.md` (architecture, testing, feature guide)
6. Evidence only if claiming debt: `ai/reports/`, `docs/audits/`

## Avoid loading early

- Entire `lib/features/<large>/` trees (chat, todo_list) without CONTEXT_MAP
- Duplicate testing prose — use [`docs/testing/testing_strategy.md`](../testing/testing_strategy.md) then [`testing_overview.md`](../testing_overview.md)
- Cursor plan files outside `docs/plans/` unless updating the plan

## Refresh triggers

See [`ai/README.md`](../../ai/README.md) `refresh_when` frontmatter.

## Multitask sessions

Declare role from [`governance.md`](governance.md). Compact evidence; reset plan when state corrupts per AGENTS loop.
