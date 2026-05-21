# PLAN — AI-first engineering (index)

Operator entry point. Keep this file as index, not plan body.

| Need | Path |
| --- | --- |
| Full plan | [`docs/plans/2026-05-21_ai_first_engineering_plan.md`](docs/plans/2026-05-21_ai_first_engineering_plan.md) |
| Executive summary | [`docs/plans/ai_first_engineering_executive_summary.md`](docs/plans/ai_first_engineering_executive_summary.md) |
| Changelog | [`docs/plans/ai_first_engineering_plan_changelog.md`](docs/plans/ai_first_engineering_plan_changelog.md) |
| Task router | [`CODEMAP.md`](CODEMAP.md) |
| Minimal context | [`ai/CONTEXT_MAP.md`](ai/CONTEXT_MAP.md) |
| Governance | [`docs/ai/governance.md`](docs/ai/governance.md) |

## Status (2026-05-21)

| Item | State |
| --- | --- |
| Waves 1A-2 | Done: AI operability docs, reports, audits, template, glossary, contracts |
| Phase 4 / ARCH-003 | Done: four feature barrels + import tests |
| Phase 5 baseline | Done: governance and refresh policy documented |
| Merge | Pending operator: PR [#239](https://github.com/redjadet/flutter_bloc_app/pull/239) |
| Backlog | ARCH-001, ARCH-002, mechanical Feature Brief CI, full contract expansion |

## Philosophy

1. `docs/` is behavior canon; agents follow links, not copies.
2. `ai/reports/` is dated evidence; refresh after structural changes.
3. AI multiplies architecture quality: weak boundaries amplify debt.
4. Smallest reversible change; Feature Brief before non-trivial feature work.

## Doc authority

| Surface | Authority |
| --- | --- |
| `docs/` | Architecture, testing, features, validation |
| `docs/plans/` | Long plans, template, changelog |
| `docs/audits/` | Ranked audits; gitignored, use `git add -f` |
| `docs/ai/` | Governance, prompts, context loading |
| `ai/reports/` | Discovery snapshots |
| `CODEMAP.md` | Task to path router |
| `CONTRACTS.md` | API and feature contract rules |

## Phases

| Phase | Goal | Exit |
| --- | --- | --- |
| 1 | Stabilisation | Reports, audits, feature map 16+15 |
| 2 | Workflow | Template, glossary, testing router, 5 contract pilots |
| 3 | Velocity | CONTEXT_MAP ≤8 files for pilots |
| 4 | Scalability | ARCH-003 barrels + tests (**complete** on branch) |
| 5 | Continuous | Refresh policy documented; mechanical CI out of scope |

Details live in the full plan and changelog. Do not restate them here.

## Merge gate

Plan work on branch is **complete** except merge. Run when ready:

```bash
bash tool/commit_push_pr_watch_merge_cleanup.sh 239
```

**Not in this plan pass:** ARCH-001/002 code refactors, `FINAL_OPTIMIZATION_REPORT.md`, mechanical Feature Brief CI.

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
