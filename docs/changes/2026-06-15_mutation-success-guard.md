# Mutation success after RequestIdGuard supersession — early detection

**Date:** 2026-06-15

## Summary

- **`tool/check_mutation_success_after_guard.sh`**: Static guard flags cubits that `return false` shortly after `!_isRequestStillActive` / `Guard.isCurrent` — the bug class fixed in therapy booking (PR #328 write path, PR #330 reload path).
- **`tool/check_regression_guards.sh`**: Filtered therapy edge-case tests (`::reports success when superseded`) run on online-therapy / `request_id_guard.dart` / static-guard script changes — **before** the broad `apps/mobile/lib/shared/*` → full-suite mapping.
- **`--paths`**: In `CHECK_REGRESSION_GUARDS_MODE=auto`, pass changed paths explicitly for local repro (skips git diff).
- **CI / local checklist**: Static guard runs via `tool/delivery_checklist.sh` → `./bin/checklist`.
- **Pre-commit (optional, local)**: `./bin/install-git-hooks` sets `core.hooksPath=githooks`; `githooks/pre-commit` runs `tool/check_mutation_success_after_guard.sh --staged` on relevant staged paths.
- Checklist, validation catalog, reliability doc, and BLoC review checklist updated.

## Bug class

Mutation succeeds → concurrent refresh bumps request id → stale completion does `if (!_isRequestStillActive(...)) return false` → user sees failure despite persisted write.

**Fix:** return success (`true` for `Future<bool>`, bare `return` for `Future<void>`) when guard inactive after successful mutation.

## Verification

```bash
bash tool/check_mutation_success_after_guard.sh --paths tool/fixtures/mutation_success_after_guard/bad_cubit.dart   # expect fail
bash tool/check_mutation_success_after_guard.sh --paths tool/fixtures/mutation_success_after_guard/good_cubit.dart  # expect pass
bash tool/check_mutation_success_after_guard.sh --paths tool/fixtures/mutation_success_after_guard/suppressed_cubit.dart  # expect pass

flutter test test/features/online_therapy_demo/edge_cases_test.dart --name "reports success when superseded"

# Narrow auto lane (therapy tests only, not full ALL_TESTS):
CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths apps/mobile/lib/shared/utils/request_id_guard.dart

bash tool/fix_validation_docs.sh && bash tool/validate_validation_docs.sh
```
