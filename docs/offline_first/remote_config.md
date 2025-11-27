# Remote Config Offline-First Notes

## Storage & Schema

- Hive box: `remote_config_cache`
- Keys:
  - `snapshot.values` – map of config keys to their latest typed values
  - `snapshot.lastFetchedAt` – ISO8601 timestamp when the cache was last updated
  - `snapshot.templateVersion` – optional string for backend rollout/versioning
  - `snapshot.dataSource` – human-readable source for the current values (e.g., `remote`, `cache`)
  - `snapshot.lastSyncedAt` – ISO8601 timestamp tracking when values last synced successfully
- Repository: `RemoteConfigCacheRepository` (`lib/features/remote_config/data/remote_config_cache_repository.dart`)
  - Uses `StorageGuard` to shield Hive errors
  - Provides `loadSnapshot()`, `saveSnapshot()`, and `clear()`

## Repository Layering

- `OfflineFirstRemoteConfigRepository`
  - Wraps the Firebase-backed `RemoteConfigRepository`
  - Hydrates `_snapshot` from Hive on `initialize()`
  - On `forceFetch()`:
    - Checks `NetworkStatusService` – if offline, serves cached values
    - Otherwise calls remote `forceFetch()`, reads tracked keys (`awesome_feature_enabled`, `test_value_1`), persists a new snapshot, and registers itself with `SyncableRepositoryRegistry`
  - Implements `SyncableRepository` so `BackgroundSyncCoordinator` can call `pullRemote()` for background refreshes
  - Gracefully swallows transient fetch errors when cached data already exists, but rethrows when no cache is available
  - Supports `clearCache()` to wipe the Hive snapshot and reset in-memory state before a fresh fetch (used by Settings diagnostics)

## Presentation

- `RemoteConfigDiagnosticsSection` now renders `_RemoteConfigSyncStatusBanner`
  - Listens to `SyncStatusCubit` + `NetworkStatusService`
  - Shows offline/syncing `AppMessage` copy using shared localization strings
  - Keeps existing status badge + retry button for manual fetches
  - Adds a clear-cache text button for dev/QA to wipe local config and refetch
  - Shows metadata row when `dataSource`/`lastSyncedAt` are available so engineers can see the source of the current values
- Settings page automatically benefits because `RemoteConfigCubit` is bootstrapped from `AppScope`

## Testing

- Cache serialization: `test/features/remote_config/data/remote_config_cache_repository_test.dart`
- Offline-first behavior: `test/features/remote_config/data/offline_first_remote_config_repository_test.dart`
  - Covers cache hydration, offline skips, sync registry registration, and fallback-on-error flows
- UI regression: `test/features/settings/presentation/widgets/remote_config_diagnostics_section_test.dart`
  - Coverage for sync status banner + clear-cache action and metadata display to keep localized copy aligned
- Cubit regression: `test/features/remote_config/presentation/cubit/remote_config_cubit_test.dart` verifies cache clear + refetch flow
- Telemetry: `OfflineFirstRemoteConfigRepository` emits debug telemetry events (`remote_config_fetch_*`) with duration/source metadata; hook into coordinator analytics as needed.
- Versioning: Current payloads/tracked keys are minimal, so no differential sync/version pinning is required. Revisit if config payloads grow or staged rollouts demand etag/template pinning.

## Follow-ups

- Feed refresh metrics (duration, fetch success) into `BackgroundSyncCoordinator` analytics
