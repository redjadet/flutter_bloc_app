# PLAN — AI-first engineering (index)

Operator entry point. **Full plan:** [`docs/plans/2026-05-21_ai_first_engineering_plan.md`](docs/plans/2026-05-21_ai_first_engineering_plan.md).  
**Summary:** [`docs/plans/ai_first_engineering_executive_summary.md`](docs/plans/ai_first_engineering_executive_summary.md).  
**Changelog:** [`docs/plans/ai_first_engineering_plan_changelog.md`](docs/plans/ai_first_engineering_plan_changelog.md).

## Philosophy

1. **`docs/`** is behavior and engineering canon; agents follow links, not copies.
2. **`ai/reports/`** holds dated evidence; refresh after structural changes.
3. **AI multiplies** clear architecture—weak boundaries get worse with agents.
4. **Smallest reversible change**; no `lib/` edits in documentation waves.
5. **Feature Brief** before non-trivial feature work ([`docs/plans/FEATURE_TEMPLATE.md`](docs/plans/FEATURE_TEMPLATE.md)).

## Doc authority

```text
docs/           canon (architecture, testing, features, validation)
docs/plans/     long plans, template, changelog
docs/audits/    ranked audits (gitignored — git add -f when committing)
docs/ai/        governance, prompts, context loading
ai/reports/     discovery snapshots
CODEMAP.md      task → path router (root)
PLAN.md         this index (root)
CONTRACTS.md    API/feature contract rules (root)
```

## Phases

| Phase | Goal | Exit |
| --- | --- | --- |
| 1 | Stabilisation | Reports + audits + feature map 16+15 |
| 2 | Workflow | Template, glossary, testing router, 5 contract pilots |
| 3 | Velocity | CONTEXT_MAP ≤8 files for pilots |
| 4 | Scalability | One `ARCH-###` merge with tests |
| 5 | Continuous | Refresh policy + optional CI hooks |

## Shipped waves (documentation)

| Wave | Contents |
| --- | --- |
| 1A | Changelog, `ai/` scaffold, core reports, `CODEMAP.md` |
| 1B | Feature map, hotspots, recommendations, audits, `CONTEXT_MAP.md` |
| 1C | This index, executive summary, plan mirror |
| 2 | Template, glossary, contracts, `docs/ai/*`, AGENTS pointers |

## Key links

| Need | Path |
| --- | --- |
| Task router | [`CODEMAP.md`](CODEMAP.md) |
| Agent map | [`AGENTS.md`](AGENTS.md) |
| Feature map | [`ai/reports/feature_map.md`](ai/reports/feature_map.md) |
| Minimal context | [`ai/CONTEXT_MAP.md`](ai/CONTEXT_MAP.md) |
| Architecture audit | [`docs/audits/ai_architecture_audit.md`](docs/audits/ai_architecture_audit.md) |
| Governance | [`docs/ai/governance.md`](docs/ai/governance.md) |
| Contracts | [`CONTRACTS.md`](CONTRACTS.md) |

## Not enforced yet

- Mechanical Feature Brief on every PR (Phase 5).
- Full 31-feature contract bodies (pilots only in Wave 2).
- Automatic report regeneration in CI.

## Validation

```bash
npx markdownlint-cli2 "PLAN.md" "CODEMAP.md" "CONTRACTS.md" "docs/plans/**/*.md" "docs/audits/ai_*.md" "docs/ai/**/*.md" "ai/**/*.md"
git diff --check
./tool/check_agent_knowledge_base.sh
```

Refresh evidence:

```bash
bash tool/modular_metrics.sh
bash tool/modular_metrics.sh --cross-feature-only
```
