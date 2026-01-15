# Lazy Loading and `late` Usage Review

## Scope

This document reviews lazy-loading patterns and `late` keyword usage across the codebase. It is based on a static scan of `lib/` and should be refreshed as the code evolves. No runtime profiling is included.

## Lazy-Loading Patterns in This Codebase

### Dependency Injection

- `get_it` registrations use lazy singletons via `registerLazySingletonIfAbsent`.
- Key files: `lib/core/di/injector.dart`, `lib/core/di/injector_registrations.dart`, `lib/core/di/injector_helpers.dart`.
- Outcome: services are created only when first requested.

### Repository Watch Streams

- Repository streams are lazy and start work only when listeners attach.
- Pattern uses `StreamController` with `onListen`/`onCancel` callbacks.
- Example files: `lib/shared/utils/repository_watch_helper.dart`, `lib/features/counter/data/hive_counter_repository_watch_helper.dart`.

### Repository Initial Load Guarding

- `RepositoryInitialLoadHelper` prevents duplicate initial loads.
- File: `lib/shared/utils/repository_initial_load_helper.dart`.

### Network Status Monitoring

- `NetworkStatusService` starts connectivity subscriptions on first listener.
- File: `lib/shared/services/network_status_service.dart`.

### UI List Rendering

- List and grid views use builder constructors for lazy item creation.
- Validation script: `tool/check_perf_nonbuilder_lists.sh`.

### Route-Level Cubit Initialization

- Feature-specific cubits are created at route level to avoid global initialization.
- Common pattern: `BlocProviderHelpers.withAsyncInit` in route builders.

## `late` Usage Summary

A previous scan found 31 `late` occurrences across 20 files. Refresh with:

```bash
rg -n "\\blate\\b" lib
```

### Appropriate Use Cases

- Widget controllers created in `initState()`.
- Cubits or services initialized in `initState()` or constructors.
- Stream controllers created with lifecycle callbacks.
- Computed values built in constructors from immutable inputs.

### Watchouts

- Avoid `late` fields initialized in `build()` unless the initialization is guarded and idempotent.
- Prefer nullable fields when initialization can fail or is conditional.
- Ensure `late` fields are always initialized before use, especially in async paths.

## Deferred Imports Primer

Deferred imports delay loading code until it is needed. In this project, deferred routes use the `DeferredPage` wrapper to handle loading states.

### Basic Syntax

```dart
import 'package:my_app/features/charts/chart_page.dart' deferred as chart_page;

Future<void> loadChart() async {
  await chart_page.loadLibrary();
}
```

### Project Pattern

```dart
GoRoute(
  path: AppRoutes.chartsPath,
  name: AppRoutes.charts,
  builder: (context, state) => DeferredPage(
    loadLibrary: chart_page.loadLibrary,
    builder: (context) => chart_page.buildChartPage(),
  ),
),
```

### Notes

- On mobile, deferred code is loaded from the app bundle at runtime.
- On web, deferred code is downloaded as separate JavaScript chunks.
- Prefer deferred imports for heavy, rarely used features; avoid for core flows or shared utilities.

See `docs/architecture_details.md` for the routing and deferred page patterns.

## Opportunities and Considerations

These are optional improvements to revisit if profiling shows startup or memory pressure:

- Gate background sync start until a sync-dependent feature is accessed.
- Keep Remote Config initialization on-demand, and avoid early startup work unless needed.
- Confirm whether app-scoped cubits can be moved to route scope without UX regressions.
- Defer heavy controller creation until the widget is visible where possible.

## Related Documentation

- [Performance Bottlenecks](performance_bottlenecks.md)
- [Startup Time Profiling](STARTUP_TIME_PROFILING.md)
- [Bundle Size Monitoring](BUNDLE_SIZE_MONITORING.md)
- [Compute/Isolate Usage](compute_isolate_review.md)
