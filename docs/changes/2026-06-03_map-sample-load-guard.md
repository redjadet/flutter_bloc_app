# MapSample load guard and selection edge cases

**Date:** 2026-06-03

## Summary

- **`MapSampleCubit.loadLocations`**: `RequestIdGuard` so stale async completions cannot overwrite a newer load (Chart/Graphql parity).
- **`loadLocations`**: skips when already loading; **`reloadLocations`** always fetches (race/retry paths).
- **`MapSampleState.initial`**: `isLoading: false` so coalesce does not block the first fetch (default field stays `true` for in-flight emits).
- **`selectLocation`**: no-op when `locationId` is empty or whitespace-only.
- Tests: coalesce + stale-completion races, empty-id selection, retry widget; removed duplicate `presentation/map_sample_cubit_test.dart`.

## Verification

```bash
./tool/analyze.sh
flutter test test/features/google_maps/presentation/cubit/map_sample_cubit_test.dart
```
