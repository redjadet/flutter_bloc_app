# Context loading ladder

**Canonical** progressive load order. Read core files first; add only task-matched
owners. Other agent docs link here; do not duplicate this list.

## Ladder

1. [`AGENTS.md`](../../AGENTS.md) — repo map and invariants.
2. [`skill_routing.md`](skill_routing.md) — use `agents-skill-routing`; select one
   task skill and its owner docs.
3. Task evidence — targeted code/tests plus [`CODEMAP.md`](../../CODEMAP.md) or
   [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) when structure is unclear.

## Conditional owners

| Trigger | Load |
| --- | --- |
| Non-trivial work | [`ai_failure_risks.md`](ai_failure_risks.md) Pre-Flight + `agents-common-pitfalls` |
| T1/T2 coding | [`agent_operating_manual.md`](agent_operating_manual.md) |
| Feature semantics | [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md) + [`architecture/reference_features.md`](../architecture/reference_features.md) |
| Commands / validation choice | [`agents_quick_reference.md`](../agents_quick_reference.md) |
| PR / CI evidence | [`github_mcp_guide.md`](github_mcp_guide.md) |
| Code review | [`../review/code_review_playbook.md`](../review/code_review_playbook.md); AI-authored change: also [`../ai_code_review_protocol.md`](../ai_code_review_protocol.md) |
| Git, branch, PR, merge, or worktree task | [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) |
| Harness doctrine / agent policy | [`agent_knowledge_base.md`](../agent_knowledge_base.md) |
| Topic owner unknown | [`docs/README.md`](../README.md) |
| AI engineering plan | [`PLAN.md`](../../PLAN.md) |
| Debt claim only | `ai/reports/`, `docs/audits/` (`git add -f`) |

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
