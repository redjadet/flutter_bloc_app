# Docs dedupe pass (2026-08-25)

## Intent

Reduce duplicate and redundant prose in living docs without dropping
important information or weakening gate anchors.

Worktree: `.worktrees/docs/dedupe-redundancy-2026-08-25` on branch
`docs/dedupe-redundancy-2026-08-25`.

## Canonical ownership after this pass

| Topic | Canonical | Thinned / demoted |
| --- | --- | --- |
| Feature folder skeleton | [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md) | [`clean_architecture.md`](../clean_architecture.md) § Architecture skeleton |
| Docs index navigation | [`README.md`](../README.md) Core docs + Browse by folder | Start here → short onboarding table |
| Need→source routing | [`agent_project_context.md`](../agent_project_context.md) § High-Value Sources | [`agent_knowledge_base_details.md`](../agent_knowledge_base_details.md) SoR table |
| Multi-agent mechanics | [`agent_kb/multi_agent_hub.md`](../agent_kb/multi_agent_hub.md) | Details hub section → pointer; AKM keeps gate anchors |
| SOLID/DRY summaries | [`architecture/solid_principles.md`](../architecture/solid_principles.md), [`dry_principles.md`](../architecture/dry_principles.md) | [`CODE_QUALITY.md`](../CODE_QUALITY.md) architecture/SOLID sections |
| Coverage thresholds | [`engineering/engineering_quality_scorecard.md`](../engineering/engineering_quality_scorecard.md) | [`CODE_QUALITY.md`](../CODE_QUALITY.md), [`testing_overview.md`](../testing_overview.md) |
| Logging API/redaction | [`engineering/logging.md`](../engineering/logging.md) | [`observability.md`](../observability.md) § Logging |
| AppErrorCode enum list | [`observability.md`](../observability.md) | [`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md) structured-codes row |
| Feature delivery steps | Definition of done + workflow table | Removed duplicate numbered “Adding a new feature” list |
| SoC layer restatement | CA + modularity | [`separation_of_concerns.md`](../architecture/separation_of_concerns.md) keeps unique examples only |
| Validation script intro | [`validation_scripts/overview.md`](../validation_scripts/overview.md) | [`validation_scripts.md`](../validation_scripts.md) TOC-focused |
| DTO step in surprise tree | [`use_case_dto_policy.md`](../architecture/use_case_dto_policy.md) | [`reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md) step 1 |

## Left intentional

- Thin hubs ([`architecture.md`](../architecture.md), [`testing.md`](../testing.md), …)
- [`SECURITY.md`](../../SECURITY.md) vs [`security_and_secrets.md`](../security_and_secrets.md) split
- AGENTS / AKM / quick-ref mechanical gate anchors
- Dart 3.13 primary-constructor discovery echoes (canonical still [`CODE_QUALITY.md`](../CODE_QUALITY.md))

## Verification

- `./tool/check_agent_knowledge_base.sh`
- Docs/tooling: `./bin/checklist-fast --no-reuse` (or closeout docs-sync preset)

## Codex review follow-up (2026-08-25)

- Fixed non-portable program-index href in
  [`reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md)
  (normalize had rewritten `../plans/...` into a path that escapes the checkout
  via worktree symlink resolution). Destination is again
  [`../plans/senior_patterns_optimization_2026-06.md`](../plans/senior_patterns_optimization_2026-06.md).
- Restored agent scorecard summaries after worktree rebuild collapsed events
  (local event archives incomplete in worktree).
- Trimmed extra blank line at EOF in `agent_knowledge_base_details.md`.
