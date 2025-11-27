# GraphQL Demo – Offline First

## Goals

- Serve the countries/continents sample in a cache-first manner so the demo works offline.
- Keep network logic isolated while providing deterministic fallbacks for cubit/widget tests.

## Architecture

- **Remote:** `CountriesGraphqlRepository` still owns GraphQL calls to `https://countries.trevorblades.com/`.
- **Cache:** `GraphqlDemoCacheRepository` (Hive, encrypted) stores:
  - Continents under `continents`
  - Countries per filter under `countries:<continentCode|all>`
- **Coordinator:** `OfflineFirstGraphqlDemoRepository` wraps the remote + cache and implements `GraphqlDemoRepository`.
  - On success: write-through to cache, return remote data.
  - On failure: return cached data when available, otherwise rethrow the original error.

## Behavior

- **Continents:** `fetchContinents()` returns cached continents immediately when offline; otherwise fetches remote and refreshes cache.
- **Countries:** `fetchCountries(continentCode)` normalizes the filter key, returns cached rows on failures, and refreshes cache on success.
- **Staleness:** Cached entries expire after 24h (configurable via repository); stale entries are skipped so stale data doesn’t hide fresh remote results.
- **DI:** `GraphqlDemoRepository` now resolves to `OfflineFirstGraphqlDemoRepository` via `injector_registrations.dart`.
- **Storage format:** Plain JSON maps (no Hive adapters) to keep tests light; nested continent fields are serialized explicitly.
- **Dev controls:** Settings (dev/QA builds) include a “Clear GraphQL cache” control to force-refresh from the network on next load.
- **Telemetry:** Repository logs source (`remote` vs `cache`) and active continent for quick debugging.
- **UI badge:** GraphQL demo header shows a small “Cache/Remote” chip reflecting the last data source.

## Testing

- Cache round-trip: `test/features/graphql_demo/data/graphql_demo_cache_repository_test.dart`.
- Offline-first fallback + cache refresh: `test/features/graphql_demo/data/offline_first_graphql_demo_repository_test.dart`.

## Next Ideas

- Add staleness metadata (e.g., `lastSyncedAt`) and expire cached lists after N hours.
- Surface cache/remote source in the UI for debugging.
- Add a dev-only “Clear GraphQL cache” control alongside other diagnostics.
