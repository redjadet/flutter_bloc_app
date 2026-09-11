# Senior engineering judgment guidance review (2026-09)

Documentation-only disposition for repairing live ownership and decision gaps
in the reduce-surprise / senior-judgment guidance set.

**June scorecard unchanged:**
[`senior_patterns_review_2026-06.md`](senior_patterns_review_2026-06.md) remains
historical evidence and was not rewritten.

## Freeze snapshot

| Field | Value |
| --- | --- |
| Branch | `codex/senior-judgment-guidance` (from `origin/main`) |
| Baseline HEAD | `0c6c708117df902a4f4998fee019d05b7f6f6e5d` |
| Worktree | `../flutter_bloc_app-senior-judgment-guidance` |
| Scope | Documentation owners listed below; no Dart/tools/CI |

## Before → after (P1–P7)

| Pattern | Before gap | After disposition | Owner | Enforcement honesty |
| --- | --- | --- | --- | --- |
| P1 Guard clauses | Spine linked [`bloc_standards.md`](../bloc_standards.md) with no early-return rule | Explicit § Control Flow + decision table | [`bloc_standards.md`](../bloc_standards.md) | Review-only |
| P2 Domain naming | Slogan-only spine row; checklist silent | Decision table + architecture checklist semantic naming | Spine + [`review/architecture_checklist.md`](../review/architecture_checklist.md) | Review-only |
| P3 Boundaries | Strong policy; some docs overclaimed warn scans as coverage | Linked DTO policy; AP-11 labeled warn/historical; gold pairs updated | [`architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md) | Import fail gates + tests; AP-11/AP-18 warn-only |
| P4 Invalid states | Soft dual guidance; checklist blanket “prefer sealed” | State Shape decision table; checklist uses same rule | [`bloc_standards.md`](../bloc_standards.md) | Review + Freezed convention |
| P5 Decisions | Strong; gold included weak calculator exemplar | Policy purity + enforcement-radius checklist; gold → merge/parser + staff `validateDraft` only (`messageFor` excluded) | [`architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md) | Review + pure unit tests |
| P6 Errors | Strong chain; template used `error.toString()`; profile failure not gold l10n | Linked reliability/observability/logging; template typed failure; gold → auth/chat code→l10n + counter known types only (IoT detail/`toString` and counter unknown raw message excluded as gold) | Reliability + observability + logging | Mixed review/contracts |
| P7 Reviewable diffs | Wrong owner (testing matrix); ≤400 LOC mandate; June scorecard update instruction | Playbook + git owners; coherence/reversibility; size as non-blocking prompt | [`review/code_review_playbook.md`](../review/code_review_playbook.md), [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) | Review-only |

## Evidence paths (living)

- [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md) — decision table, mapping, gold, P7
- [`bloc_standards.md`](../bloc_standards.md) — Control Flow, State Shape
- [`review/architecture_checklist.md`](../review/architecture_checklist.md) — Semantic Judgment
- [`review/bloc_checklist.md`](../review/bloc_checklist.md) — reachable-state + useful-failure checks
- [`review/code_review_playbook.md`](../review/code_review_playbook.md) — coherent diff / rollback / size prompt
- [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) — PR contract aligned
- [`bloc/cubit_file_template.md`](../bloc/cubit_file_template.md) — state-shape trigger + typed failure example
- [`README.md`](../README.md) — P1–P7 blurb

## Deferred items

| Item | Owner | Revisit trigger |
| --- | --- | --- |
| Repair `tool/check_domain_wire_leaks.sh` app root + fixtures | Tooling / harness | Wire-leak noise repeats or someone proposes promoting AP-11 to fail gate |
| Mobile–backend boundaries evidence cell citing stale warn scan | Docs / architecture | Next edit of [`architecture/MOBILE_BACKEND_BOUNDARIES.md`](../architecture/MOBILE_BACKEND_BOUNDARIES.md); link import gates + architecture review instead |
| Live two-reviewer walkthrough of plan scenarios 1–7 | Human reviewers | After this docs PR is ready for review |
| Promote warn-only AP-18 / AP-11 to fail gates | Engineering | Repeatable defect class + good/bad fixtures exist |

## Rejected in this pass

- New top-level senior-patterns doc
- Universal early-return / sealed / mapper / LOC mandates
- Rewriting June audit
- AGENTS.md prose expansion
- Bundling tool script repairs into this documentation change
