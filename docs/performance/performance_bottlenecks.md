# Performance and Memory Notes

- Scope: targeted fixes from static review and observed hot paths. No runtime profiling traces are included here.
- This document tracks completed changes and follow-up ideas; keep it updated as performance work evolves.

## Completed Fixes (In Codebase)

### Counter Page Sync Flush Throttling

- File: `apps/mobile/lib/features/counter/presentation/pages/counter_page.dart`
- Issue: Rapid counter updates triggered multiple concurrent `SyncStatusCubit.flush()` calls.
- Resolution: Added a 500 ms throttle window to prevent overlapping flushes.

### Calculator Rate Selector NumberFormat Caching

- File: `apps/mobile/lib/features/calculator/presentation/utils/calculator_formatters.dart`
- Issue: `NumberFormat` was created on every rebuild in hot paths.
- Resolution: Cached formatter instances per locale.

### CommonLoadingButton Transition Cost

- File: `packages/design_system/lib/src/widgets/common_loading_widget.dart`
- Issue: Swapping entire button subtree when `isLoading` toggled caused extra layout churn.
- Resolution: Use `AnimatedSwitcher` and keyed children for smoother transitions.

### Status-region AnimatedSwitcher (loading / error / content)

- Prefer a keyed `AnimatedSwitcher` (≈200 ms) for page or section shells that
  swap loading ↔ error ↔ content, same pattern as `CommonLoadingButton`.
  Proof: `apps/mobile/lib/features/production_readiness/presentation/pages/production_readiness_page.dart`.
- Widget tests: if `pumpAndSettle` hangs on the indicator ticker or switcher,
  use `pump()` then `pump(const Duration(milliseconds: 200))` — do not remove
  the switcher to “fix” the test.

### Intrinsic layout cost

- `IntrinsicHeight` / `IntrinsicWidth` force extra layout passes. Fine sparingly
  outside lists; avoid inside scrolling lists. See
  [`../architecture/flutter_layout_constraints.md`](../architecture/flutter_layout_constraints.md).

### Map View Rebuilds

- File: `apps/mobile/lib/features/google_maps/presentation/widgets/map_sample_map_view.dart`
- Issue: Map widget rebuilt on camera and state changes, even when controller updates could be used.
- Resolution: Controller-driven updates for camera changes; widget rebuilds only on map properties.

## Validation Suggestions

- Run `flutter run --profile` and capture frame timings during:
  - rapid counter taps
  - map camera movements and toggles
  - calculator rate selector interactions
- Use DevTools CPU and memory profiles to confirm reduced rebuilds and allocations.

## Flutter frame pipeline and jank diagnosis

A Flutter frame is not a screenshot. It is an end-to-end pipeline that turns
an input or state change into pixels:

```text
input/state -> frame schedule (vsync) -> build -> layout -> paint -> compositing/layer tree -> raster -> GPU/display
```

The frame budget follows the display refresh rate: about **16.67 ms** at 60 Hz
and **8.33 ms** at 120 Hz. “Every 16 ms” is therefore only an approximation for
a 60 Hz target, not a universal Flutter interval.

### What each stage owns

- **Build:** Reconfigures only dirty widget/element regions where possible. Keep
  `build()` pure and cheap: no heavy computation, blocking I/O, or synchronous
  large JSON conversion.
- **Layout:** **Constraints go down. Sizes go up. Parents set positions.**
  Parents pass `BoxConstraints` down; children return sizes up; parents place
  children. Detail:
  [`../architecture/flutter_layout_constraints.md`](../architecture/flutter_layout_constraints.md).
- **Paint:** Produces drawing commands.
- **Compositing:** Combines those commands into a layer tree.
- **Raster:** The engine/raster thread draws that layer tree for the GPU and
  display.

UI work (`build`, layout, and paint) and raster work are separate pipeline
budgets. Missing either budget produces jank, so a fast `build()` time alone is
not proof of smoothness.

### Triage by limiting stage

- **UI-bound frames:** Investigate unnecessary rebuilds, large eager lists,
  intrinsic layout, synchronous CPU work, and excessive layout or paint.
- **Raster-bound frames:** Investigate `saveLayer`, frequent or complex clips,
  opacity/shadow stacks, and expensive visual effects. These can be costly even
  when build time is low.

Measure before changing code. Run on a representative physical device with:

```bash
flutter run --profile
```

In DevTools **Performance**, select a red frame and inspect both UI and Raster
durations, then inspect the build/layout/paint timeline for the limiting stage.
Choose the intervention from that evidence rather than treating `build()` as the
sole performance metric.

Further reading: [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview),
[DevTools frame analysis](https://docs.flutter.dev/tools/devtools/performance),
and [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices).

## List and scroll performance (guidelines)

- **Heavy list items:** Wrap list item widgets that do custom paint, many children, or images in `RepaintBoundary` so repaints are isolated and scrolling stays smooth.
- **Long lists:** Prefer `CustomScrollView` with slivers (`SliverList`, `SliverList.builder`, `SliverGrid`) over nested scrollables with `shrinkWrap: true` to avoid unbounded height and layout cost. Use `ListView.builder` / `ListView.separated` (or sliver equivalents) for dynamic length; avoid non-builder `ListView(children: ...)` for long lists.
- **Current guidance:** See list/scroll patterns below (and `tool/check_perf_shrinkwrap_lists.sh`) for shrinkWrap usage and optional refactors.

## High-frequency events (rate limiting / debouncing)

- **Pattern:** For actions that trigger network or heavy work at high frequency (search-as-you-type, scroll-driven load, rapid taps), use **debounce or throttle** and, where order matters, **in-flight/request-id guards** so the app does not flood the backend or UI.
- **Existing patterns:** Counter page uses a 500 ms throttle for sync flush; SearchCubit uses debounce + [RequestIdGuard](https://pub.dev/packages/ilkersevim_async_utils); TodoListCubit uses debounce for search query. Prefer `TimerService.runOnce` for cancellable delays and [RequestIdGuard](https://pub.dev/packages/ilkersevim_async_utils) (or `isCurrent(id)` before emit) for async loads. Repositories use [InFlightCoalescer](https://pub.dev/packages/ilkersevim_async_utils) / [KeyedInFlightCoalescer](https://pub.dev/packages/ilkersevim_async_utils) for single-flight refresh.
- **When adding new triggers:** Apply debounce/throttle and optional [RequestIdGuard](https://pub.dev/packages/ilkersevim_async_utils) in the cubit; use [InFlightCoalescer](https://pub.dev/packages/ilkersevim_async_utils) in repos for coalesced refresh.

## Follow-up Ideas

- Add an integration test that stresses the calculator page and asserts stable rebuild counts.
- Add a profile workflow for map interactions to validate controller updates at scale.

## Related Documentation

- [Lazy Loading Review](lazy_loading_review.md)
- [Startup Time Profiling](startup_time_profiling.md)
- [Bundle Size Monitoring](bundle_size_monitoring.md)
- [Architecture Details](../architecture_details.md)
