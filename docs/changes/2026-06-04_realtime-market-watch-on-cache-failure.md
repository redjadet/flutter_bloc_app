# Realtime market: watch feed when cache load fails

**Date:** 2026-06-04

## Summary

- **`RealtimeMarketCubit._bootstrap`**: If `loadCached` throws, still call `_registerMarketWatch` so live snapshots flow; previously returned before subscribing and left the screen stuck on a cache error with no updates.
- Test: `still watches feed when loadCached throws`.

## Verification

```bash
flutter test test/features/realtime_market/presentation/realtime_market_cubit_test.dart
```
