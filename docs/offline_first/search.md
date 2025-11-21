# Search Offline-First Contract

This document defines how the search feature adopts the shared offline-first stack so engineers can implement and test it without re-triaging requirements.

## Goals

- Cache search results locally so the search UI can hydrate instantly without network.
- Serve cached results when offline, providing a seamless search experience.
- Refresh cached results in the background when online to keep data current.
- Surface sync state to the UI (offline/syncing indicators) while keeping logic in repositories.

## Storage Plan

- Box: `search_cache`
- Data shapes:
  - Query results: `query_<normalized_query>` → `List<SearchResultDto>` (JSON array)
  - Recent queries: `recent_queries` → `List<String>` (up to 50 most recent)
- Encryption: use `HiveService`/`HiveRepositoryBase`; never open Hive boxes directly.
- Cache eviction: Recent queries list is automatically trimmed to 50 entries. Individual query caches persist until explicitly cleared.

## Repository Wiring

- Add `SearchCacheRepository` (Hive-backed) handling read/write for cached results and recent queries.
- Add `OfflineFirstSearchRepository` composing:
  - `SearchRepository` (remote/MockSearchRepository) for actual search calls.
  - `SearchCacheRepository` for local persistence.
  - `NetworkStatusService` for connectivity checks.
- DI: register `SearchCacheRepository` and wire the offline-first repository into the sync registry.
- Implement `SyncableRepository`:
  - `entityType`: `search`
  - `processOperation`: No-op (search doesn't queue mutations; future features like "save search" could use this)
  - `pullRemote`: Refreshes cached results for the top 10 most recent queries when online
  - Register in `SyncableRepositoryRegistry`
- `search`: Always checks cache first. If cache hit and online, returns cached immediately and refreshes in background. If cache hit and offline, returns cached. If cache miss and online, fetches and caches. If cache miss and offline, returns empty.

## Conflict Resolution

- Search is read-only (queries), so no conflict resolution needed.
- Cache freshness: When online, cached results are returned immediately but refreshed in the background to provide instant UI while keeping data current.
- Query normalization: Queries are normalized (trimmed, lowercased) before caching to maximize cache hits.

## UI Integration

- Search page shows cached results instantly when available.
- `SearchSyncBanner` widget displays offline/syncing status (no pending operations since search doesn't queue).
- `SearchCubit` works transparently with the offline-first repository - no changes needed to cubit logic.

## Testing Checklist

- ✅ **Unit tests**: `test/features/search/data/search_cache_repository_test.dart` covers `SearchCacheRepository` serialization, cache eviction, recent queries management (ordering, duplicates, 50-item limit), and cache clearing.
- ✅ **Repository tests**: `test/features/search/data/offline_first_search_repository_test.dart` covers:
  - `search` serves from cache when offline.
  - `search` returns cached immediately and refreshes in background when online.
  - `search` fetches and caches when cache miss and online.
  - `search` returns empty when cache miss and offline.
  - `search` falls back to cache when remote fails.
  - `pullRemote` refreshes recent queries (top 10).
  - Registry registration.
- ✅ **Bloc/widget tests**: `test/features/search/presentation/widgets/search_sync_banner_test.dart` covers banner visibility, offline/syncing states, and status change updates. `test/features/search/presentation/pages/search_page_test.dart` covers `SearchSyncBanner` integration in the search page.
- All tests use `FakeTimerService` + mock connectivity to cover offline/online transitions deterministically.

## Data Retention Policy

- Recent queries: Automatically trimmed to 50 most recent entries.
- Query caches: Persist indefinitely until explicitly cleared (via `clearCache()`).
- Future consideration: Implement automatic cache eviction for queries older than 30 days if storage becomes a concern.

## Implementation Status

✅ **Complete**: All components implemented and tested:
- `SearchCacheRepository` with Hive-backed caching (`lib/features/search/data/search_cache_repository.dart`)
- `OfflineFirstSearchRepository` implementing `SyncableRepository` (`lib/features/search/data/offline_first_search_repository.dart`)
- `SearchSyncBanner` widget integrated into `SearchPage` (`lib/features/search/presentation/widgets/search_sync_banner.dart`)
- Full DI wiring in `lib/core/di/injector_registrations.dart` and registry registration
- Comprehensive test coverage:
  - Unit tests: `test/features/search/data/search_cache_repository_test.dart`
  - Repository tests: `test/features/search/data/offline_first_search_repository_test.dart`
  - Widget tests: `test/features/search/presentation/widgets/search_sync_banner_test.dart`
  - Page integration: `test/features/search/presentation/pages/search_page_test.dart`

## Next Actions

1. **User-facing cache management** (Priority: Low)
   - Add a "Clear cache" action in search settings for users to manage storage.
   - Implement cache size monitoring and display current cache size to users.

2. **Automatic cache eviction** (Priority: Low)
   - Implement automatic cache eviction for queries older than 30 days if storage becomes a concern.
   - Add cache size limits and LRU eviction for query results.

3. **Enhanced features** (Priority: Low)
   - Consider adding "saved searches" feature that would queue save/delete operations.
   - Add search history UI to show recent queries with quick re-search actions.

