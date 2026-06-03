# MapSample load guard and selection edge cases

**Date:** 2026-06-03

## Summary

- **`MapSampleCubit.loadLocations`**: `RequestIdGuard` so stale async completions cannot overwrite a newer load (Chart/Graphql parity).
- **`selectLocation`**: no-op when `locationId` is empty or whitespace-only.
- Tests: stale-completion race + empty-id selection.

## Verification

```bash
./tool/analyze.sh
flutter test test/features/google_maps/presentation/cubit/map_sample_cubit_test.dart
```
