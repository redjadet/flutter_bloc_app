# Chart Demo – Offline First

## Goals

- Serve Bitcoin 7-day trending data in a cache-first manner so the chart works offline.
- When Supabase is configured and the user is signed in, use Edge Function first, then Supabase table fallback; otherwise use direct CoinGecko API (current behavior).

## Architecture

- **Remote (auth-aware):** `AuthAwareChartRemoteRepository` chooses a remote per request:
  - When **signed in to Supabase**: `SupabaseChartRepository` uses the shared `runSupabaseEdgeThenTables()` helper (Edge first, then table fallback). It passes a repository-specific `genericFailureMessage` (“Failed to load chart data from Supabase”) so UI and tests see chart-specific error text.
  - When **not signed in** (or Supabase not configured): `DirectChartRemoteRepository` calls the CoinGecko API directly (`coins/bitcoin/market_chart`, 7 days, daily).
- **Cache:** `ChartDemoCacheRepository` (Hive) stores trending points under key `trending_points` with `updatedAt` and `items` for staleness.
- **Coordinator:** `OfflineFirstChartRepository` wraps the remote + cache and implements `ChartRepository`.
  - On success: write-through to cache, return remote data.
  - On failure: return cached data when available, otherwise rethrow.
  - `lastSource` reflects the active source (`remote`, `supabaseEdge`, `supabaseTables`, or `cache`).

### Supabase backend sync

The table `public.chart_trending_points` is **synced from CoinGecko** via the Edge Function `sync-chart-trending`. The app **calls this Edge Function first** (with Bearer token when signed in); if the function fails or returns empty, the app falls back to reading from the table. The function is deployed with **verify_jwt: false**; RLS on the table restricts SELECT to authenticated users. Source: `supabase/functions/sync-chart-trending/`.

## Behavior

- **Trending counts:** On first open, the page loads cached points when available and within max age (24h), then immediately refreshes from the active remote so the badge and data can upgrade from cache to `Supabase (Edge)` / `Supabase (Tables)` / `Remote` without requiring a second visit. If no cache is available, it fetches remote directly.
- **Staleness:** Cached entries expire after 24h; stale entries are skipped so stale data doesn’t hide fresh remote results.
- **When Supabase not configured:** The app uses the direct remote only (CoinGecko), matching previous behavior.
- **DI:** `ChartRepository` resolves to `OfflineFirstChartRepository` via `register_chart_services.dart`.
- **UI badge:** Chart page shows a small chip reflecting the last data source (localized):
  - Cache — data from local Hive cache
  - Supabase (Edge) — data from the Edge Function
  - Supabase (Tables) — data from table fallback when Edge fails or returns empty
  - Remote — when not signed in to Supabase (direct CoinGecko)
- **L10n:** Keys `chartDataSourceCache`, `chartDataSourceSupabaseEdge`, `chartDataSourceSupabaseTables`, `chartDataSourceRemote` in all `app_*.arb` files.

## Testing

- Cache round-trip and staleness: `test/features/chart/data/chart_demo_cache_repository_test.dart`.
- Offline-first fallback and cache refresh: `test/features/chart/data/offline_first_chart_repository_test.dart`.
- Auth-aware remote selection: `test/features/chart/data/auth_aware_chart_remote_repository_test.dart`.
- Data source badge: `test/features/chart/presentation/widgets/chart_data_source_badge_test.dart`.

## References

- Migration: `supabase/migrations/20260310180000_chart_trending_tables.sql` (documented in [supabase_migrations.md](supabase_migrations.md)).
- Edge Function: `supabase/functions/sync-chart-trending/`.
- GraphQL demo pattern: [graphql_demo.md](graphql_demo.md).

## Implementation status

- **Complete:** Offline-first chart with cache, auth-aware remote (Supabase Edge + table fallback vs direct CoinGecko), data source badge and l10n, and tests (cache, offline-first, auth-aware, badge). Apply migration via MCP `user-supabase` → `apply_migration` with name `chart_trending_tables` (see [supabase_migrations.md](supabase_migrations.md)); check `list_migrations` first to avoid duplicate application.
