# Counter: reject stale remote over newer synchronized local

**Date:** 2026-06-11

## Summary

- **`OfflineFirstCounterRepositoryHelpers.shouldApplyRemote`**: When local `lastChanged` is strictly after remote `lastChanged`, skip applying the remote snapshot so a stale RTDB write cannot overwrite newer local state (aligned with `TodoMergePolicy` / offline-first don't-overwrite guide).
- Test: regression in `offline_first_counter_repository_test.dart` for stale-remote-over-newer-local.

## Verification

```bash
flutter test test/features/counter/data/offline_first_counter_repository_test.dart
bash tool/check_feature_brief_linked.sh
```
