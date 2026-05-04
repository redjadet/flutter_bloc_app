# Offline-First Adoption Guide

This guide describes how to onboard a feature into the shared offline-first stack used across the app.

## Prerequisites

- Feature has a clear domain model with JSON/Freezed serialization.
- Local storage is Hive-based via `HiveRepositoryBase` and `HiveService` (encryption by default).
- Remote repository is already DI-registered or can be injected.

## Step-by-Step

1. **Define local store**
   - Create a Hive-backed repository/data source under `lib/features/<feature>/data/` extending `HiveRepositoryBase`.
   - Add sync metadata fields (e.g., `changeId`, `lastSyncedAt`, `synchronized`) to the domain model and regen code with `dart run build_runner build --delete-conflicting-outputs`.
2. **Wrap with OfflineFirst repository**
   - Implement `<Feature>OfflineRepository` that composes the local + remote repos and implements `SyncableRepository`.
   - On `save`, write to Hive first, mark `synchronized: false`, generate `idempotencyKey`/`changeId`, and enqueue a `SyncOperation`.
   - `PendingSyncRepository.enqueue` dedupes by entity type, idempotency key,
     and best-effort user scope. Preserve those fields when adding new queued
     mutations.
   - When remote calls fail, enqueue the operation and throw/return a feature-specific “queued” signal (e.g., `ChatOfflineEnqueuedException`) so cubits can treat it as a pending success instead of an error.
   - On `processOperation`:
     - **Critical**: Persist user-generated data locally BEFORE attempting remote call to prevent data loss if sync fails.
     - Push to remote (if available) then mark local as synced.
     - If user data doesn't exist locally yet, create and persist it first, then attempt remote call.
   - On `pullRemote`, merge remote snapshots when newer.
   - **Don’t overwrite:** When merging a remote watch stream into local, use a `_shouldApplyRemote`-style check so older remote never overwrites newer unsynced local. See [Don’t overwrite guide](dont_overwrite_guide.md).
   - App resume sync stays debounced and flushes must not overlap; use
     `BackgroundSyncCoordinator.flush()` instead of starting parallel sync work.
3. **Register in DI + registry**
   - Wire the offline repo via `create<Feature>Repository` and register it in `SyncableRepositoryRegistry` within `lib/core/di/injector_registrations.dart`.
4. **Expose status (logs + Settings)**
   - Sync status is logged via `BackgroundSyncCoordinator` telemetry. Feature pages do not show sync banners.
   - For observability, the Sync Diagnostics section in Settings (dev/qa mode only) surfaces `SyncCycleSummary` history so engineering/QA can validate sync health.
   - `SyncStatusCubit` seeds its initial status via `NetworkStatusService.getCurrentStatus()`. Stub this in tests when testing sync-related flows.
5. **Tests**
   - Unit tests for local store serialization + migrations.
   - Repository tests for `save` queueing (if applicable) and `processOperation`/`pullRemote` paths.
   - Bloc/widget tests for sync flows; Sync Diagnostics (Settings, dev/qa) for manual inspection.
   - **Reference patterns**:
     - **Write-heavy features (Counter/Chat)**: See `test/chat_cubit_test.dart`, `test/chat_page_test.dart`, and `test/features/counter/presentation/pages/counter_page_sync_metadata_test.dart`.
     - **Read-only/cache-first features (Search)**: See `test/features/search/data/search_cache_repository_test.dart`, `test/features/search/data/offline_first_search_repository_test.dart`, and `test/features/search/presentation/widgets/search_sync_banner_test.dart`.
6. **Docs + runbook**
   - Document box names/keys under `offline_first/<feature>.md`.
   - Examples: [`offline_first/chat.md`](chat.md), [`offline_first/search.md`](search.md), [`offline_first/profile.md`](profile.md), and [`offline_first/remote_config.md`](remote_config.md).
   - Define and document the data retention policy for the feature's local cache (e.g., "prune synced items older than 90 days"). This is critical for managing storage.
   - Update [`offline_first/offline_first_plan.md`](offline_first_plan.md) progress and run `./bin/checklist` before committing. Keep the feature row in the adoption matrix current (cache strategy, UI status surfaces, tests).

## Next Steps After Adoption

Once a feature is onboarded, consider these enhancements:

1. **User-facing improvements**
   - Add cache management UI (clear cache, view cache size) for data-heavy features.
   - Sync status is in logs; Sync Diagnostics in Settings (dev/qa) for observability.
   - Add manual sync triggers beyond the global "Sync now" button.

2. **Observability**
   - Add sync metrics to analytics (queue depth, flush duration, success rates).
   - Implement debug menus to inspect pending operations and cache state.
   - Add structured logging with correlation IDs for sync operations.

3. **Performance optimizations**
   - Implement automatic cache eviction based on retention policies.
   - Add cache size monitoring and alerts for storage pressure.
   - Optimize `pullRemote` to only refresh changed data (differential sync).

4. **Advanced features**
   - Add conflict resolution UI for features that support concurrent edits.
   - Implement differential sync for large datasets.
   - Add background sync scheduling based on user behavior patterns.

## Debugging tips

- Use the pending sync inspector (where available) to view queued operations.
- Inject fake timers and mock connectivity to deterministically test retry/backoff.
- Keep files under 250 LOC to satisfy `file_length_lint`.
- Check `BackgroundSyncCoordinator.statusStream` to monitor sync state in real-time.
- Use `PendingSyncRepository.getPendingOperations()` to inspect queued operations during development.
