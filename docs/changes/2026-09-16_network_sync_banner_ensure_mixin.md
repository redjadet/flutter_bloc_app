# Network sync banner + EnsureSyncStartedMixin — 2026-09-16

## Summary

Deduped near-identical search / IoT demo sync banners into shared
`NetworkSyncBanner`, and extracted `EnsureSyncStartedMixin` for one-shot
`ensureSyncStartedIfAvailable` across sync UI. **No intentional sync or UI
behavior change.**

## Changes

- Added `apps/mobile/lib/app/sync/network_sync_banner.dart`
- Added `apps/mobile/lib/app/sync/ensure_sync_started_mixin.dart`
- Thinned `SearchSyncBanner` / `IotDemoSyncBanner` to wrappers
- Adopted mixin on chat/profile/todo/counter banners, global
  `SyncStatusBanner`, settings sync diagnostics, and `CounterPage`

Left gated/one-shot cases alone (`CounterSyncQueueInspectorButton` pending-UI
gate; remote-config diagnostics combined init).

## Tests

```bash
cd apps/mobile && flutter test \
  test/features/search/presentation/widgets/search_sync_banner_test.dart \
  test/features/todo_list/presentation/widgets/todo_sync_banner_test.dart \
  test/features/profile/presentation/widgets/profile_sync_banner_test.dart \
  test/features/counter/presentation/widgets/counter_sync_banner_test.dart \
  test/chat_sync_banner_test.dart \
  test/shared/widgets/sync_status_banner_test.dart
```
