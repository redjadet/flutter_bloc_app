# Code Quality & Resilience Report

## Current Snapshot (Repo Inspection)

This section reflects the current repo state and supersedes older metrics.

### Metrics

- **Test coverage**: 82.50% (9091/11020 lines) per `coverage/coverage_summary.md`
- **File length lint**: `max_lines` is 250 in `analysis_options.yaml` (default is 250 in the plugin)
- **Largest handwritten files (>= 220 LOC)**:
  - `lib/features/counter/data/hive_counter_repository_watch_helper.dart` (243)
  - `lib/features/counter/presentation/pages/counter_page.dart` (241)
  - `lib/features/settings/presentation/widgets/remote_config_diagnostics_section.dart` (238)
  - `lib/features/auth/presentation/cubit/register/register_state.dart` (238)
  - `lib/main_bootstrap.dart` (236)
  - `lib/features/auth/presentation/widgets/register_phone_field.dart` (233)
  - `lib/features/chat/data/offline_first_chat_repository.dart` (227)
  - `lib/shared/sync/background_sync_coordinator.dart` (224)
  - `lib/features/counter/presentation/widgets/counter_page_app_bar.dart` (223)
  - `lib/features/graphql_demo/data/countries_graphql_repository.dart` (221)

### Areas to Improve (Actionable)

1. **Custom lint tool reliability**
   - `custom_lint.log` shows repeated plugin startup failures (non-Mach-O shared object / AOT snapshot errors).
   - Action: verify lint tooling is aligned with the analyzer plugin setup or remove stale custom_lint usage to avoid silent lint gaps.

2. **Low coverage in critical non-UI utilities**
   - Added tests for retry/backoff rules, auth token refresh, error mapping, repository watch flows, stream lifecycle guards, and HTTP extension mapping.
   - Remaining gaps: `lib/main_bootstrap.dart` and any residual uncovered paths in the HTTP/bootstrapping layer.
   - Action: run coverage to confirm deltas, then target remaining bootstrap paths.

3. **Initialization and infrastructure gaps**
   - `lib/main_bootstrap.dart` is large (236 LOC) with 1.08% coverage.
   - Action: extract bootstrap steps into smaller testable units (e.g., initialization coordinator, environment/config loader) and add integration tests to cover the happy path and failure recovery.

4. **Skeleton widget coverage**
   - Baseline widget tests added in `test/shared/widgets/skeletons_test.dart`.
   - Action: re-run coverage to confirm the new tests lift skeleton widget coverage.

## Architecture Compliance (Merged)

**Status:** 6 findings resolved; 0 open. Composition-root `getIt` usage in `app_scope.dart` remains intentional.

### Resolved Findings

- **Presentation depended on data implementation** (`lib/features/remote_config/presentation/cubit/remote_config_cubit.dart`) now uses a domain contract.
- **Domain leaked Flutter UI types** (`Locale`, `ThemeMode`) replaced with `AppLocale` and `ThemePreference` value objects.
- **Domain coupled to routing** (`deep_link_target.dart`) now maps in presentation via an extension.
- **Domain imported Flutter Foundation** (`chat_conversation.dart`) removed.
- **Duplicate Hive initialization in DI** consolidated into a single bootstrap path.
- **Widget-level `getIt` lookups** removed for feature widgets; composition root remains the exception.

## Runtime Resilience (Merged)

**Status:** All high/medium/low items documented as implemented and tested.

- **Network error handling:** `NetworkErrorMapper` centralizes messages; `ResilientHttpClient` injects auth headers (when available), logs telemetry, and retries transient errors.
- **Retry logic:** `RetryPolicy` standardizes backoff strategies; sync flow tracks retry metrics in `SyncCycleSummary`.
- **Connectivity visibility:** `SyncStatusBanner` surfaces degraded sync with retry UI hooks.
- **Empty states:** `CommonEmptyState` is the shared pattern with i18n coverage.
- **Loading skeletons:** `SkeletonListTile`, `SkeletonCard`, `SkeletonGridItem` added with accessibility semantics and `RepaintBoundary`.
- **Regression coverage:** `test/shared/http/resilient_http_client_headers_test.dart` guards headers behavior.
- **Retry UI feedback:** `RetryNotificationService` and `RetrySnackBarListener` provide optional user feedback for automatic retries.

## Duplicate Code Reduction (Merged)

**Status:** High-priority duplication reduction utilities implemented; backlog cleared.

- **Test helpers:** `test/test_helpers.dart` standardizes Hive setup, DI setup, and in-memory repositories.
- **Cubit subscriptions:** `CubitSubscriptionMixin` centralizes stream cleanup.
- **Async init helpers:** `BlocProviderHelpers.withAsyncInit` and `providerWithAsyncInit` reduce boilerplate.
- **Repository watch flows:** `RepositoryWatchHelper<T>` centralizes watch initialization and caching.
- **Repository initial load:** `RepositoryInitialLoadHelper` standardizes initial watch loads and resolution tracking.
- **Stream controller lifecycle:** `StreamControllerLifecycle<T>` provides safe emit and disposal.
- **Error handling:** `CubitErrorHandler` standardizes error mapping and `isClosed` guards.
- **View status patterns:** `ViewStatusSwitcher` consolidates loading/error/empty branching.
- **Navigation safety:** `NavigationUtils.safeGo` and dialog helpers centralize mounted checks.
- **State restoration:** `StateRestorationMixin` and `StateRestorationOutcome` unify restore flows.
- **Completer safety:** `CompleterHelper` standardizes safe completion/error/reset handling.

## Codebase Improvements (Historical Summary)

This section captures prior improvements reported in analysis docs. Use the snapshot above for current truth.

- **Coverage automation:** `tool/test_coverage.sh` updates `coverage/coverage_summary.md` and `README.md`.
- **Delivery checklist:** `./bin/checklist` runs format, analyze, and coverage.
- **Shared UI consistency:** `CommonPageLayout`, `CommonAppBar`, `CommonCard`, and shared form/loading widgets reduce duplication.
- **Responsive spacing:** migrated to `context.responsiveGap*` and responsive layout helpers.
- **Performance patterns:** `RepaintBoundary` and `BlocSelector` applied to heavy widgets.

## Dependencies & Security (Merged)

- **Monitoring:** Renovate is primary; Dependabot is backup for security-only updates.
- **CI checks:** dependency PRs run format, analyze, and tests with coverage.
- **Manual workflow:** `flutter pub outdated` and `flutter pub upgrade` remain the standard entry points.

For detailed dependency workflow, see `docs/DEPENDENCY_UPDATES.md`.

## Performance Profiling (Reference)

Performance tooling lives in `docs/PERFORMANCE_PROFILING.md` and includes:

- `PerformanceProfiler` usage and reporting.
- `RepaintBoundary` and `BlocSelector` adoption guidance.
- DevTools profiling steps and release validation checklist.

## Testing & Coverage Notes (Reference)

- **Test types:** unit, bloc, widget, golden, and common bugs prevention.
- **Common bug prevention suite:** validates lifecycle guards, completer safety, and stream cleanup.
- **Coverage target:** 85.34% documented baseline (re-verify after major changes).

## Report Sources

This report consolidates prior analysis documents that are now merged into this file.
