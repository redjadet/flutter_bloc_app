# Remote Config Offline-First Notes

## Storage & Schema

- Hive box: `remote_config_cache`
- Keys:
  - `snapshot.values` – map of config keys to their latest typed values
  - `snapshot.lastFetchedAt` – ISO8601 timestamp when the cache was last updated
  - `snapshot.templateVersion` – optional string for backend rollout/versioning
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

## Presentation

- `RemoteConfigDiagnosticsSection` now renders `_RemoteConfigSyncStatusBanner`
  - Listens to `SyncStatusCubit` + `NetworkStatusService`
  - Shows offline/syncing `AppMessage` copy using shared localization strings
  - Keeps existing status badge + retry button for manual fetches
- Settings page automatically benefits because `RemoteConfigCubit` is bootstrapped from `AppScope`

## Testing

- Cache serialization: `test/features/remote_config/data/remote_config_cache_repository_test.dart`
- Offline-first behavior: `test/features/remote_config/data/offline_first_remote_config_repository_test.dart`
  - Covers cache hydration, offline skips, sync registry registration, and fallback-on-error flows
- UI regression: `test/features/settings/presentation/widgets/remote_config_diagnostics_section_test.dart`
  - Added coverage for the sync status banner to ensure offline copy stays localized

## Follow-ups

- Surface `lastFetchedAt` + `dataSource` metadata directly in the diagnostics card
- Consider exposing a “Reset Remote Config cache” action for dev/QA flavors
- Feed refresh metrics (duration, fetch success) into `BackgroundSyncCoordinator` analytics
