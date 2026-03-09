# Counter Offline-First Contract

This document defines how the counter feature adopts the shared offline-first stack so engineers can implement and test it consistently.

## Goals

- Persist counter state locally so the counter UI boots instantly without network.
- Allow incrementing/decrementing while offline by queueing pending operations and reconciling when connectivity returns.
- Sync logic in repositories; sync status is logged. Sync diagnostics visible in Settings when dev/qa mode is active.

## Storage Plan

- Box: `counter` (reuses existing Hive box from `HiveCounterRepository`)
- Data shapes:
  - `CounterSnapshot` with `count`, `userId`, `lastChanged`, `changeId`, `lastSyncedAt`, `synchronized`
  - Keys: `count`, `last_changed`, `user_id`, `change_id`, `last_synced_at`, `synchronized`
- Encryption: uses `HiveService`/`HiveRepositoryBase`; never open Hive boxes directly.

## Repository Wiring

- `HiveCounterRepository` (existing) handles local persistence of `CounterSnapshot` with sync metadata.
- `OfflineFirstCounterRepository` composes:
  - `HiveCounterRepository` for local persistence.
  - Optional `CounterRepository` (remote, e.g., `RealtimeDatabaseCounterRepository`) for remote sync.
  - `PendingSyncRepository` for enqueueing pending operations.
  - Registers with `SyncableRepositoryRegistry` as entity `counter`.
- Behavior:
  - `save`: Always writes to Hive first, generates `changeId` if missing, marks `synchronized: false`, and enqueues a `SyncOperation` for remote sync (if remote repository exists).
  - `load`: Returns cached snapshot from Hive immediately.
  - `watch`: Streams updates from Hive box.
  - `processOperation`: Processes queued sync operations by pushing to remote (if available), then updating local snapshot with `synchronized: true` and `lastSyncedAt`.
  - `pullRemote`: Fetches remote snapshot when online and merges if remote is newer (based on `lastChanged` timestamp).

## Conflict Resolution

- Client generates `changeId` (timestamp + random hex) for each local mutation.
- On sync, compare `lastChanged` timestamps: if remote is newer, apply remote; otherwise keep local.
- Counter increments/decrements are additive operations, so conflicts are resolved by timestamp comparison (last write wins).
- `changeId` ensures idempotency when replaying queued operations.

## UI Integration

- No sync banner on the counter page; sync status is logged. For sync observability, use Settings → Sync Diagnostics (dev/qa only).
- `CounterCubit` works transparently with the offline-first repository - no changes needed to cubit logic.
- Counter state loads instantly from Hive on app start.

## Testing Checklist

- ✅ **Unit tests**: `test/features/counter/data/hive_counter_repository_test.dart` covers Hive serialization and sync metadata persistence.
- ✅ **Repository tests**: `test/features/counter/data/offline_first_counter_repository_test.dart` covers:
  - `save` enqueues operations when remote exists.
  - `save` marks snapshot as unsynchronized and generates `changeId`.
  - `processOperation` syncs to remote and updates local metadata.
  - `pullRemote` merges newer remote snapshots.
  - Registry registration.
- ✅ **Bloc tests**: `test/counter_cubit_test.dart` covers offline-first flows, ensuring cubit handles queued operations and sync state updates.
- ✅ **Widget tests**: `test/features/counter/presentation/widgets/counter_sync_banner_test.dart` covers banner visibility, offline/syncing states, and metadata display.
- ✅ **Widget tests**: `test/features/counter/presentation/widgets/counter_sync_banner_test.dart` covers the banner widget in isolation (banner not displayed on counter page).
- All tests use `FakeTimerService` + mock connectivity to cover offline/online transitions deterministically.

## Data Retention Policy

- Counter state persists indefinitely in Hive box.
- Pending operations are automatically processed by `BackgroundSyncCoordinator` when online.
- Completed operations are pruned by the coordinator after successful sync.

## Implementation Status

✅ **Complete**: All components implemented and tested:

- `HiveCounterRepository` with sync metadata support (`lib/features/counter/data/hive_counter_repository.dart`)
- `OfflineFirstCounterRepository` implementing `SyncableRepository` (`lib/features/counter/data/offline_first_counter_repository.dart`)
- `CounterSyncBanner` widget exists but is not displayed; sync diagnostics in Settings (dev/qa only)
- Full DI wiring in `lib/core/di/injector_registrations.dart` and registry registration
- Comprehensive test coverage:
  - Unit tests: `test/features/counter/data/hive_counter_repository_test.dart`
  - Repository tests: `test/features/counter/data/offline_first_counter_repository_test.dart`
  - Bloc tests: `test/counter_cubit_test.dart`
  - Widget tests: `test/features/counter/presentation/widgets/counter_sync_banner_test.dart`
  - Page tests: `test/features/counter/presentation/pages/counter_page_sync_metadata_test.dart`

## Next Actions

1. **Enhanced conflict resolution** (Priority: Low)
   - Consider implementing merge strategies for concurrent edits (e.g., replay unapplied changeIds).
   - Add version stamps or etags if remote API supports them.

2. **Observability** (Priority: Low)
   - Feed sync metrics (queue depth, flush duration, success rates) into analytics.
   - Add structured logging for sync operations with correlation IDs.

3. **User-facing improvements** (Priority: Low)
   - Consider adding manual "Sync now" action in the sync banner (currently handled by global `SyncStatusCubit.flush()`).
   - Surface sync status in counter display card for more visibility.
