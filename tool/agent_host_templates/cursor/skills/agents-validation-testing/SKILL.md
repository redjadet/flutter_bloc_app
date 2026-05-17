---
name: agents-validation-testing
description: Validation scripts, regression guards, and testing requirements for this repo. Use when running checks, adding regression tests, or touching Mix/lifecycle/offline-first.
---

# Validation and testing

**Routing:** `agents-delivery-workflow`, `docs/agents_quick_reference.md`, `docs/engineering/validation_routing_fast_vs_full.md`.

**Script catalog:** `docs/validation_scripts.md` (lifecycle scripts marked **C** = in `./bin/checklist`).

## Repo-specific (not fully indexed elsewhere)

**Mix:** `app_styles.dart` / `mix_app_theme.dart` changes → `./tool/run_mix_lint.sh`. Tests → `pumpWithMixTheme` (`test/helpers/pump_with_mix_theme.dart`).

**Lifecycle regressions:** register in `tool/check_regression_guards.sh`. Manual scripts when touching area: `check_side_effects_build.sh`, `check_todo_keyboard_layout.sh`, `check_perf_shrinkwrap_lists.sh`, `check_missing_const.sh`.

**Regression test anchors** (add/extend when fixing same class of bug):

| Area | Test path(s) |
| ------ | ---------------- |
| Background sync races | `test/shared/sync/background_sync_coordinator_test.dart` |
| Repo in-flight coalesce | `test/features/search/data/offline_first_search_repository_test.dart`, `.../profile/...`, `.../remote_config/...` |
| Don't-overwrite local | `test/features/counter/data/offline_first_counter_repository_test.dart` (+ `tool/check_offline_first_remote_merge.sh`) |
| HTTP error mapping | 401/429/503, unmapped fallback, `Retry-After` parsing |
| Auth refresh single-flight | one forced refresh on 401 retry with new bearer |

**Test conventions:** mirror `lib/` under `test/`; descriptive `group`/`test`; AAA; fakes from `test/test_helpers.dart` / `test/helpers/`; `blocTest` for cubits; Hive temp dir + `HiveService` setup; Supabase → `test/helpers/supabase_test_setup.dart`.

**Goldens:** `test/goldens/`; `flutter test --update-goldens` after SDK bump; phone + tablet; `pumpWithMixTheme` for Mix screens.

**Coverage:** `./tool/test_coverage.sh`; `dart run tool/update_coverage_summary.dart`; align `coverage/coverage_summary.md`.
