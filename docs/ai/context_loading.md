# Context loading ladder

**Canonical** minimum load order (other agent docs link here; do not duplicate this list).

## Ladder

1. [`AGENTS.md`](../../AGENTS.md)
2. [`CODEMAP.md`](../../CODEMAP.md) or [`PLAN.md`](../../PLAN.md) (AI engineering)
3. [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md)
4. [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) for the feature/task
5. Canon from [`docs/README.md`](../README.md)
6. Debt claims only: `ai/reports/`, `docs/audits/` (`git add -f`)
7. **Skill routing** (before implementation): [`skill_routing.md`](skill_routing.md) — shim `agents-skill-routing`; session list → routing table → `./bin/agent-maintain find QUERY` or `bash tool/find_global_agent_skills.sh QUERY`

## Avoid loading early

- Entire `lib/features/<large>/` trees before `CONTEXT_MAP`
- Duplicate testing prose: use [`docs/testing/testing_strategy.md`](../testing/testing_strategy.md), then [`testing_overview.md`](../testing_overview.md)
- Cursor plan files outside `docs/plans/` unless updating the plan

## Refresh triggers

See [`ai/README.md`](../../ai/README.md) `refresh_when` frontmatter.

## Multitask sessions

Declare role from [`governance.md`](governance.md). Compact evidence; reset plan when state corrupts.
