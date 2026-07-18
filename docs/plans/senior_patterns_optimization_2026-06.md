# Senior Patterns Optimization — Program Index (June 2026)

Repo-local index for the reduce-surprise program. Full build-ready spec lived in
Cursor plan `senior_patterns_optimization_e62df207` (not duplicated here).

## Goal

Close semantic-quality gaps (patterns 3–6) and wire agent docs so future work
copies gold exemplars. Pattern 7 (reviewable diffs) applies to every PR.

## Canonical docs

| Doc | Role |
| --- | --- |
| [`../architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md) | Agent guide — read first for feature work |
| [`../audits/senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md) | Scorecard + grep appendix |
| [`../architecture/reference_features.md`](../architecture/reference_features.md) | Folder + semantic grades |
| [`../flutter-anti-patterns.md`](../engineering/flutter-anti-patterns.md) | AP-11…AP-17 |

## PR order

| PR | Scope | Status |
| --- | --- | --- |
| PR-0 | Audit + agent spine (docs only) | Done |
| PR-1A | `todo_list` sync DTO boundary | Done |
| PR-1B | `ai_decision_demo` + `graphql_demo` DTOs | Done |
| PR-1C | `chat` domain boundary | Done |
| PR-2A | `profile` sealed state + ProfileFailure | Done |
| PR-2B | `chat` sealed state | Done |
| PR-2C-i | `iot_ble` connection lifecycle phase 1 | Done |
| PR-3 | `todo_list` merge policy + AppError | Done |
| PR-3B | `scapes` + `staff_app_demo` errors/validator | Done |
| PR-closeout | Final scorecard + harness verification | Done |

**Dependencies:** PR-0 blocks all code. PR-1C → PR-2B. PR-1A → PR-3.

## Per-PR doc checklist

- [x] Update scorecard row in audit doc
- [x] Update reduce_surprise_patterns exemplars if gold path moves
- [x] Mark AP-11…17 Fixed when remediated
- [x] No new prose in AGENTS.md

## Proof (minimum)

| Slice | Command |
| --- | --- |
| Docs | `bash tool/check_agent_knowledge_base.sh`; `./bin/checklist-fast` |
| Dart feature PR | `flutter test test/features/<feature>/`; `./tool/analyze.sh`; import scripts |
| Freezed PRs | `dart run build_runner build --delete-conflicting-outputs` |
| Closeout | `./bin/checklist`; `check_agent_knowledge_base.sh` |
