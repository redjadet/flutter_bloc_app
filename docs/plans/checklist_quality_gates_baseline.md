# Checklist quality gates — baseline (2026-05-20)

MVP wiring for fourteen quality themes via new gates in `tool/delivery_checklist.sh`.
Recorded before fail gates were appended to `CHECK_SCRIPTS` (draft runs) and after
wiring (clean-tree counts).

## Draft gate runs (unwired → wired)

| Script | Severity | violation_count | sample_paths | Notes |
| --- | --- | --- | --- | --- |
| `tool/check_navigation_outside_presentation.sh` | fail | 0 | — | Repo clean after presentation fixes |
| `tool/check_sync_io_in_presentation.sh` | fail | 0 | — | Presentation-only; data-layer `existsSync` allowed |
| `tool/check_remote_image_cache_hints.sh` | warn | 0 | — | Always exit 0 until promotion |
| `tool/check_cubit_subscription_cancel.sh` | warn | 0 | — | Always exit 0 until promotion |

**Pre-wire fixes (presentation):**

- `lib/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit.dart` — `existsSync()` → async `File.exists()`; `isClosed` after awaits; `_submitInFlight` duplicate-submit guard; parallel photo existence checks; `avoid_slow_async_io` ignores
- `lib/features/case_study_demo/presentation/utils/case_study_local_video_exists.dart` — `check-ignore` on compute-worker `existsSync()` (same line as violation)

## Fixture matrix (M2 fail + M3 warn)

| Gate | good | bad (exit 1) | suppressed (exit 0) |
| --- | --- | --- | --- |
| navigation | `presentation/good.dart` | `domain/bad.dart` | `domain/suppressed.dart` |
| sync-io presentation | `presentation/good.dart` | `presentation/bad.dart` | `presentation/suppressed.dart` |
| image cache hints | `remote_image_cache_hints/presentation/good.dart` | `presentation/bad.dart` | `presentation/suppressed.dart` |
| cubit subscription | `presentation/good_cubit.dart` | `presentation/bad_cubit.dart` | `presentation/suppressed_cubit.dart` |

## Router path trigger

`./bin/router_feature_validate` runs from checklist when changed files match globs in
`.cursor/rules/router-feature-validation.mdc` (not on every full checklist run).
Set `CHECKLIST_SKIP_ROUTER_VALIDATE=1` to skip. See
[`docs/validation_scripts/catalog.md`](../validation_scripts/catalog.md) (Quality theme gates).

## Deferred route manifest (M0 appendix)

Deferred imports / `DeferredPage` builders:

| Library | Deferred page |
| --- | --- |
| `lib/app/router/route_groups.dart` | `google_maps_page`, `realtime_market_page`, `websocket_page` |
| `lib/app/router/routes_core.dart` | `chart_page`, `markdown_editor_page` |

Heuristic `check_deferred_heavy_routes` remains **deferred** until allowlist strategy exists.

## Regression guard

- `test/shared/sync/background_sync_coordinator_test.dart` in `tool/check_regression_guards.sh` `ALL_TESTS`
- Path-auto: `lib/shared/sync/**`, `test/shared/sync/**` (and related shared/test paths)

## Checklist metadata

- `CHECK_SCRIPT_THEMES` (59 entries) aligned with `CHECK_SCRIPTS` / `CHECK_MESSAGES`
- Validated in `validate_checklist_configuration()` at checklist start
- `CHECKLIST_EXPLAIN_THEMES=1` prints `explain|theme|…` per script

## M4 proof (2026-05-20)

```bash
bash tool/fix_validation_docs.sh
bash tool/validate_validation_docs.sh
CHECKLIST_RUN_COVERAGE=0 CHECKLIST_SKIP_ROUTER_VALIDATE=1 ./bin/checklist
```

Result: checklist **passed** (~62s with coverage skipped). Use default `./bin/checklist` before merge for CI-equivalent coverage.

Follow-up review proof also ran default `CHECKLIST_ALLOW_REUSE=0 ./bin/checklist`
with coverage; coverage summary stayed at **71.22%**.

`./bin/checklist-fast` applies only to **docs/tooling-only** diffs; not re-run here because this change set includes `lib/` and `tool/` gates.

**Post-review hardening (same day):** router auto trigger parses multiline
`.cursor/rules/router-feature-validation.mdc` globs and expands router
`**/*.dart` patterns to include direct `lib/**/router/*.dart` files;
`CHECKLIST_EXPLAIN_THEMES=1` prints after checklist metadata exists; warn gates
emit line-scoped fixture samples.

## Explicitly deferred (not in MVP)

Full backlog (IDs, unblock criteria, reject vs defer):
[`checklist_quality_gates_deferred.md`](checklist_quality_gates_deferred.md).

Summary:

- **Defer:** `bloc_lint`, `file_length_lint`, `check_bloc_rebuild_scoping`,
  `check_context_read_watch`, `check_deferred_heavy_routes`,
  `check_startup_work_in_build`, `check_lifecycle_observer_dispose`,
  `CHECK_THEME` filter, warn→fail promotion
- **Cancelled (optional M3):** `check_presentation_build_method_size.sh`
- **Reject:** `check_sync_io_in_lib` (data-layer `existsSync` in Hive/file stores is valid;
  use presentation-only `check_sync_io_in_presentation.sh` instead)
