# Context loading ladder

**Canonical** minimum load order (other agent docs link here; do not duplicate this list).

## Ladder

1. [`AGENTS.md`](../../AGENTS.md)
2. Non-trivial implementation: [`ai_failure_risks.md`](ai_failure_risks.md) Pre-Flight; invoke `agents-common-pitfalls`
2b. Non-trivial coding discipline: [`agent_operating_manual.md`](agent_operating_manual.md) (after Pre-Flight; mission, pre-coding checklist, routing)
3. [`CODEMAP.md`](../../CODEMAP.md) or [`PLAN.md`](../../PLAN.md) (AI engineering)
4. [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md)
5. [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) for the feature/task
5b. Feature implementation semantics: [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md) + [`architecture/reference_features.md`](../architecture/reference_features.md) semantic grades
6. Canon from [`docs/README.md`](../README.md)
7. Debt claims only: `ai/reports/`, `docs/audits/` (`git add -f`)
8. **Skill routing** (before implementation): [`skill_routing.md`](skill_routing.md) — shim `agents-skill-routing`; session list → routing table → `./bin/agent-maintain find QUERY` or `bash tool/find_global_agent_skills.sh QUERY`

## Quality claim rule

When claiming “top-tier engineering quality”, read:

- Harness: [`harness_scorecard.md`](harness_scorecard.md) (agent tooling)
- Engineering: [`../engineering/engineering_quality_scorecard.md`](../engineering/engineering_quality_scorecard.md) (app/portfolio proof)

## Avoid loading early

- Entire `apps/mobile/lib/features/<large>/` trees before `CONTEXT_MAP`
- Duplicate testing prose: use [`docs/testing/testing_strategy.md`](../testing/testing_strategy.md), then [`testing_overview.md`](../testing_overview.md)
- Cursor plan files outside `docs/plans/` unless updating the plan

## Refresh triggers

See [`ai/README.md`](../../ai/README.md) `refresh_when` frontmatter.

## Multitask sessions

Declare role from [`governance.md`](governance.md). Compact evidence; reset plan when state corrupts.
