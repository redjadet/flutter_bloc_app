# PLAN — AI-first engineering (index)

Index only. Working detail may live in **local** (gitignored)
`docs/plans/2026-05-21_ai_first_engineering_plan.md`; shared status and routing
live here and in the tracked owners below.

| Need | Path |
| --- | --- |
| Plans policy / redirects | [`plans/README.md`](docs/plans/README.md) |
| Agent knowledge + operator prefs | [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md) |
| Task router | [`CODEMAP.md`](CODEMAP.md) |
| Minimal context | [`ai/CONTEXT_MAP.md`](ai/CONTEXT_MAP.md) |
| Governance / roles | [`docs/ai/governance.md`](docs/ai/governance.md) |
| Ship/land PR | [`docs/changes/2026-05-21_agent_automated_delivery_loop.md`](docs/changes/2026-05-21_agent_automated_delivery_loop.md) |
| Feature brief template | [`docs/engineering/FEATURE_TEMPLATE.md`](docs/engineering/FEATURE_TEMPLATE.md) |
| Engineering quality proof | [`docs/engineering/engineering_quality_scorecard.md`](docs/engineering/engineering_quality_scorecard.md) |

## Principles

[`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md) (canon + operator prefs). `docs/` = behavior; `ai/reports/` = dated evidence.

## Not enforced yet

- Feature Brief in full `./bin/checklist` (use `check_feature_brief_linked.sh`; strict optional).
- Full 31-feature contract bodies (5 pilots today).
- Automatic `ai/reports/` regeneration in CI.

## Validation

Commands: [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md). Doc edits: `bash tool/check_docs_gardening.sh` and `bash tool/check_agent_knowledge_base.sh`.
