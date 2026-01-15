# Performance and Memory Notes

- Scope: targeted fixes from static review and observed hot paths. No runtime profiling traces are included here.
- This document tracks completed changes and follow-up ideas; keep it updated as performance work evolves.

## Completed Fixes (In Codebase)

### Counter Page Sync Flush Throttling

- File: `lib/features/counter/presentation/pages/counter_page.dart`
- Issue: Rapid counter updates triggered multiple concurrent `SyncStatusCubit.flush()` calls.
- Resolution: Added a 500 ms throttle window to prevent overlapping flushes.

### Calculator Rate Selector NumberFormat Caching

- File: `lib/features/calculator/presentation/utils/calculator_formatters.dart`
- Issue: `NumberFormat` was created on every rebuild in hot paths.
- Resolution: Cached formatter instances per locale.

### CommonLoadingButton Transition Cost

- File: `lib/shared/widgets/common_loading_widget.dart`
- Issue: Swapping entire button subtree when `isLoading` toggled caused extra layout churn.
- Resolution: Use `AnimatedSwitcher` and keyed children for smoother transitions.

### Map View Rebuilds

- File: `lib/features/google_maps/presentation/widgets/map_sample_map_view.dart`
- Issue: Map widget rebuilt on camera and state changes, even when controller updates could be used.
- Resolution: Controller-driven updates for camera changes; widget rebuilds only on map properties.

## Validation Suggestions

- Run `flutter run --profile` and capture frame timings during:
  - rapid counter taps
  - map camera movements and toggles
  - calculator rate selector interactions
- Use DevTools CPU and memory profiles to confirm reduced rebuilds and allocations.

## Follow-up Ideas

- Add an integration test that stresses the calculator page and asserts stable rebuild counts.
- Add a profile workflow for map interactions to validate controller updates at scale.

## Related Documentation

- [Lazy Loading Review](lazy_loading_review.md)
- [Startup Time Profiling](STARTUP_TIME_PROFILING.md)
- [Bundle Size Monitoring](BUNDLE_SIZE_MONITORING.md)
- [Architecture Details](architecture_details.md)
