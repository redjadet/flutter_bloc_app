# Senior patterns — reduce-surprise program

**Date:** 2026-06-19
**Plan:** [`docs/plans/senior_patterns_optimization_2026-06.md`](../plans/senior_patterns_optimization_2026-06.md)

## Summary

Closed semantic-quality gaps (patterns 3–6) across Tier A/B features: DTO/sync
boundaries, sealed cubit states, domain merge/eligibility rules, and typed errors.
Published agent spine ([`reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md), AP-11…17, scorecard).

## Features touched

| Feature | Change |
| --- | --- |
| `todo_list` | Sync payload via `TodoItemDto`; `TodoMergePolicy` in domain; `AppError` in state |
| `ai_decision_demo` | Wire DTOs in `data/`; domain models JSON-free |
| `graphql_demo` | `GraphqlCountryDto`; domain Freezed-only |
| `chat` | `ChatRemotePath` domain boundary; sealed loading channel (no `ViewStatus`) |
| `profile` | Sealed `ProfileState` + `ProfileFailure`; error UI shows typed message |
| `iot` | `IotBleConnectionLifecycle` sealed slice |
| `scapes` | `NetworkErrorMapper.getAppError` in cubit state |
| `staff_app_demo` | `StaffDemoProofSubmitEligibility` domain validator |

## Tests

- `test/features/todo_list/domain/todo_merge_policy_test.dart`
- `test/features/ai_decision_demo/data/ai_decision_dto_test.dart`
- `test/features/graphql_demo/data/graphql_country_dto_test.dart`
- `test/features/staff_app_demo/domain/staff_demo_proof_submit_eligibility_test.dart`
- Updated chat, profile, scapes, iot widget/cubit tests

## Verification

```bash
dart run build_runner build --delete-conflicting-outputs
./tool/analyze.sh
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/check_agent_knowledge_base.sh
flutter test test/features/todo_list/ test/features/chat/ test/features/profile/ \
  test/features/iot/ test/features/scapes/ test/features/staff_app_demo/ \
  test/features/ai_decision_demo/ test/features/graphql_demo/
./bin/checklist
```

## Deferred (documented)

- `staff_app_demo` Firestore `Map<String,dynamic>?` contract
- `ai_decision_demo` Equatable bag state migration
- Legacy domain `fromJson`/`toJson` in unrelated features (warn-only script)
