# Profile Offline-First Contract

This document captures the offline-first plan for the Profile feature so engineers can implement and test it consistently.

## Goals

- Serve the profile page instantly from local cache.
- Allow the profile page to render when offline, falling back to the last cached snapshot.
- Refresh the cache in the background when online.
- Surface sync status via shared banners (no pending operations for now).

## Storage Plan

- Box: `profile_cache`
- Key: `profile`
- Payload: serialized `ProfileUser` with `name`, `location`, `avatarUrl`, and `galleryImages` (`url`, `aspectRatio`).
- Encryption: uses `HiveService`/`HiveRepositoryBase`; never open Hive boxes directly.
- Retention: single entry; `clearProfile()` wipes the cache.

## Repository Wiring

- `ProfileCacheRepository` (Hive-backed) for load/save/clear of a single `ProfileUser`.
- `OfflineFirstProfileRepository` composes:
  - Remote `ProfileRepository` (current: `MockProfileRepository`).
  - `ProfileCacheRepository` for local persistence.
  - `NetworkStatusService` to decide offline/online.
  - Registers with `SyncableRepositoryRegistry` as entity `profile`.
- Behavior:
  - Returns cached profile immediately if available.
  - If online, refreshes cache in the background and returns cached data for instant UI.
  - If no cache and online, fetches remote → caches → returns.
  - If offline and no cache, throws an error so the UI can show an error state.
  - `processOperation`: no-op (read-only).
  - `pullRemote`: refreshes cache when online.

## UI Integration

- Profile page now shows `ProfileSyncBanner` using `SyncStatusCubit` (offline/syncing states; no pending queue).
- Manual “Sync now” action is available in the banner and calls `SyncStatusCubit.flush()` to trigger a refresh.
- Since profile is read-only, no pending queue is surfaced; banners show offline/syncing only.

## Testing Checklist

- ✅ **Cache tests**: `test/features/profile/data/profile_cache_repository_test.dart` covers load/save/clear round-trips.
- ✅ **Repository tests**: `test/features/profile/data/offline_first_profile_repository_test.dart` covers:
  - Serving cached profile when offline.
  - Returning cached immediately and refreshing when online.
  - Fetching and caching when no cache + online.
  - Throwing when offline with no cache.
- ✅ **Widget/page tests**: `test/features/profile/presentation/widgets/profile_sync_banner_test.dart` covers offline/syncing visibility + status changes. `test/features/profile/presentation/profile_page_test.dart` asserts the banner renders when offline.

## Next Actions

1. Add retention controls (manual "Clear profile cache") in settings if needed.
2. If profile ever supports edits, extend the repository to queue `SyncOperation`s and add conflict resolution similar to chat/counter.
