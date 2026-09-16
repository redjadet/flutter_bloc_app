# Sync-now trailing button extract — 2026-09-16

## Summary

Extracted shared `SyncNowTrailingButton` for chat and profile sync banners
(manual flush + in-flight spinner). **No intentional sync or UI behavior
change.** Callers still own enable gates (chat: online + pending; profile:
not syncing).

## Changes

- Added `apps/mobile/lib/app/sync/sync_now_trailing_button.dart`
- Thinned `ChatSyncBanner` / `ProfileSyncBanner` flush + button UI

Left alone: `SyncStatusBanner` retry (different label, no spinner state);
`AppRouteAuthGate` ↔ `OptionalSupabaseAuthGate` merge (different policy).

## Tests

```bash
cd apps/mobile && flutter test \
  test/chat_sync_banner_test.dart \
  test/features/profile/presentation/widgets/profile_sync_banner_test.dart
```
