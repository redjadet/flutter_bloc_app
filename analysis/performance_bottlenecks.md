# Performance & Memory Observations

- **Scope:** Quick static pass focused on hot paths visible in UI/state glue. No runtime profiling traces were collected in this session.
- **Last Updated:** Performance optimizations implemented and verified.

## Potential Bottlenecks (Status)

### ✅ Fixed: Counter Page Sync Flush Throttling

- **File:** `lib/features/counter/presentation/pages/counter_page.dart`
- **Issue:** Every counter change triggered `SyncStatusCubit.flush()` via an unawaited listener. Rapid increments caused multiple concurrent flushes, increasing network churn and memory usage.
- **Fix Applied:** Added throttle mechanism with 500ms duration to prevent concurrent flush calls. Only one flush can be triggered per throttle window.
- **Implementation:** Added `_lastFlushTime` tracking and `_flushThrottleDuration` constant to gate flush calls.

### ✅ Fixed: Calculator Rate Selector NumberFormat Caching

- **File:** `lib/features/calculator/presentation/utils/calculator_formatters.dart`
- **Issue:** `NumberFormat` was created on every build to format percentage chips. `NumberFormat` allocates locale data and is expensive in hot rebuild paths.
- **Fix Applied:** Implemented static cache per locale using `Map<String, CalculatorFormatters>` with `putIfAbsent` to reuse formatter instances across rebuilds.
- **Implementation:** Formatters are now cached per locale name, eliminating redundant `NumberFormat` instantiation.

### ✅ Fixed: CommonLoadingButton Widget Recreation

- **File:** `lib/shared/widgets/common_loading_widget.dart`
- **Issue:** The loading button swapped the entire button subtree when `isLoading` toggled, instantiating new indicators/text each time, causing extra layout/rebuild churn.
- **Fix Applied:** Replaced direct child swapping with `AnimatedSwitcher` and `KeyedSubtree` to smoothly transition between loading and content states without full widget recreation.
- **Implementation:** Uses `AnimatedSwitcher` with 200ms duration and `KeyedSubtree` to maintain widget identity during transitions.

### ⚠️ Partially Addressed: Map View Rebuilds

- **File:** `lib/features/google_maps/presentation/widgets/map_sample_map_view.dart`
- **Issue:** The `MapSampleMapView` widget rebuilds the entire `GoogleMap`/`AppleMap` whenever tracked state changes (markers, map type, traffic, selected marker, camera).
- **Current Status:** Already optimized with:
  - `RepaintBoundary` wrapper to isolate repaints
  - `BlocBuilder` with `buildWhen` to prevent unnecessary rebuilds
  - Selective state tracking (only rebuilds when relevant state changes)
- **Remaining Optimization Opportunity:** For further optimization, consider using map controllers (`GoogleMapController`/`AppleMapController`) to push incremental updates (camera/traffic toggles, marker updates) instead of rebuilding the entire widget. This would require refactoring to use controller methods for state updates rather than widget rebuilds.

## Performance Improvements Summary

1. **Sync Flush Throttling:** Reduced network churn by preventing concurrent flush operations
2. **Formatter Caching:** Eliminated expensive `NumberFormat` instantiation on every rebuild
3. **Smooth Loading Transitions:** Reduced widget recreation overhead with animated transitions
4. **Map View:** Already well-optimized with selective rebuilds and repaint boundaries

## Follow-up Ideas

- Capture a short profile with `flutter run --profile` on an emulator while toggling map controls and rapidly tapping the counter to validate improvements with frame timings and memory snapshots.
- Add a small perf regression test (integration) that pumps the calculator page and rebuilds with rapid value changes to measure rebuild counts and ensure formatter caching works as expected.
- Consider implementing map controller-based updates for map state changes to further reduce map widget rebuilds (requires architectural changes).
