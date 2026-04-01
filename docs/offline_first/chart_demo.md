# Chart Demo – Offline First

## Goals

- Serve Bitcoin 7-day trending data in a cache-first manner so the chart works offline.
- When Supabase is configured and the user is signed in, use Edge Function first, then Supabase table fallback.
- When Supabase is not usable but the user is signed in to Firebase, use Firebase (Cloud Function → Firestore fallback).
- Otherwise use direct CoinGecko API.

## Architecture

- **Remote (auth-aware):** `AuthAwareChartRemoteRepository` chooses a remote per request:
  - When **signed in to Supabase**: `SupabaseChartRepository` uses the shared `runSupabaseEdgeThenTables()` helper (Edge first, then table fallback). It passes a repository-specific `genericFailureMessage` (“Failed to load chart data from Supabase”) so UI and tests see chart-specific error text.
  - When **not signed in to Supabase** but **signed in to Firebase**: `FirebaseChartRepository` calls a Firebase callable function (`syncChartTrending`) and falls back to reading Firestore.
  - When neither Supabase nor Firebase is usable: `DirectChartRemoteRepository` calls the CoinGecko API directly (`coins/bitcoin/market_chart`, 7 days, daily).
- **Cache:** `ChartDemoCacheRepository` (Hive) stores trending points under key `trending_points` with `updatedAt` and `items` for staleness.
- **Coordinator:** `OfflineFirstChartRepository` wraps the remote + cache and implements `ChartRepository`.
  - On success: write-through to cache, return remote data.
  - On failure: return cached data when available, otherwise rethrow.
  - `lastSource` reflects the active source (`remote`, `supabaseEdge`, `supabaseTables`, `firebaseCloud`, `firebaseFirestore`, or `cache`).

### Supabase backend sync

The table `public.chart_trending_points` is **synced from CoinGecko** via the Edge Function `sync-chart-trending`. The app **calls this Edge Function first** (with Bearer token when signed in); if the function fails or returns empty, the app falls back to reading from the table. The function is deployed with **verify_jwt: false**; RLS on the table restricts SELECT to authenticated users. Source: `supabase/functions/sync-chart-trending/`.

### Firebase backend sync (Cloud Function → Firestore)

- **Callable function:** `syncChartTrending` (region `us-central1`)
  - Requires Firebase Auth (rejects when unauthenticated)
  - Refresh gate: returns cached Firestore points if `updatedAt` < 15 minutes
  - Otherwise fetches CoinGecko, normalizes to `{date_utc,value}`, writes Firestore, returns `{points}`
- **Firestore document model:**
  - Doc: `chart_trending/bitcoin_7d`
  - Fields:
    - `updatedAt` (server timestamp)
    - `points`: array of `{ date_utc: "<ISO8601 UTC>", value: <number> }`
- **Firestore rules:** allow reads for signed-in users; deny client writes (writes come from Admin SDK in the function).

## Behavior

- **Trending counts:** On first open, the page loads cached points when available and within max age (24h), then immediately refreshes from the active remote so the badge and data can upgrade from cache to `Supabase (Edge)` / `Supabase (Tables)` / `Remote` without requiring a second visit. If no cache is available, it fetches remote directly.
- **Staleness:** Cached entries expire after 24h; stale entries are skipped so stale data doesn’t hide fresh remote results.
- **When Supabase not configured:** The app uses Firebase if signed-in; otherwise it uses the direct remote (CoinGecko).
- **DI:** `ChartRepository` resolves to `OfflineFirstChartRepository` via `register_chart_services.dart`.
- **UI badge:** Chart page shows a small chip reflecting the last data source (localized):
  - Cache — data from local Hive cache
  - Supabase (Edge) — data from the Edge Function
  - Supabase (Tables) — data from table fallback when Edge fails or returns empty
  - Firebase (Cloud) — data returned by the callable Cloud Function
  - Firebase (Firestore) — data returned from Firestore fallback
  - Remote — when not signed in to Supabase (direct CoinGecko)
- **L10n:** Keys `chartDataSourceCache`, `chartDataSourceSupabaseEdge`, `chartDataSourceSupabaseTables`, `chartDataSourceFirebaseCloud`, `chartDataSourceFirebaseFirestore`, `chartDataSourceRemote` in all `app_*.arb` files.

## Firebase vs Supabase (charts codebase comparison)

This section compares the two “backend-accelerated” chart paths as implemented in this repo (not a generic platform comparison).

### Client-side code paths

- **Supabase path**
  - **Selector**: `lib/features/chart/data/auth_aware_chart_remote_repository.dart` chooses Supabase when Supabase is initialized and `SupabaseAuthRepository.currentUser != null`.
  - **Remote repo**: `lib/features/chart/data/supabase_chart_repository.dart`
    - Calls Supabase Edge first (`sync-chart-trending`)
    - Falls back to reading Postgres table `chart_trending_points`
  - **Auth**: uses Supabase access token (Bearer) when invoking the edge function; table reads rely on Supabase auth/RLS.

- **Firebase path**
  - **Selector**: `lib/features/chart/data/auth_aware_chart_remote_repository.dart` chooses Firebase when `FirebaseAuth.currentUser != null` (via `FirebaseChartRepository.hasSignedInUser`).
  - **Remote repo**: `lib/features/chart/data/firebase_chart_repository.dart`
    - Calls callable Cloud Function `syncChartTrending` (Cloud Functions Gen2)
    - Falls back to Firestore doc `chart_trending/bitcoin_7d`
  - **Auth**: requires Firebase Auth; the client forces an ID token refresh before calling the function to avoid “signed-in but token not attached yet” races.

### Backend shape and failure modes

- **Supabase**
  - **Primary**: Edge Function; if it fails, table fallback can still succeed.
  - **Common failures**:
    - Edge function returns non-2xx / empty payload → table fallback kicks in.
    - RLS misconfig or missing auth → table reads fail.

- **Firebase**
  - **Primary**: callable Cloud Function; if it fails, Firestore fallback can still succeed.
  - **Common failures**:
    - **Gen2 callable IAM**: if Cloud Run invoker is blocked, the client can see misleading `UNAUTHENTICATED`. (See [`firebase_setup.md`](../firebase_setup.md) for the required `gcloud run services add-iam-policy-binding ... allUsers` fix.)
    - **App Check**: can be INVALID on iOS simulator; if enforcement is disabled, calls still succeed (auth remains required).
    - Missing Firestore doc (fresh install) → fallback is empty until the cloud function succeeds at least once.

### Data contract and parsing

- Both server paths return/contain the same shape so parsing can be shared:
  - `{ points: [{ date_utc: string, value: number }] }`
- The app uses a shared resilient parser:
  - `lib/features/chart/data/chart_points_parser.dart`

### Practical tradeoffs in this repo

- **Supabase is best when**
  - Supabase is already configured for the user/session (tables provide a durable fallback).
  - You want an SQL-backed store for analytics/admin queries (Postgres table).

- **Firebase is best when**
  - Supabase isn’t configured but Firebase Auth is (common for mobile-first flows).
  - You want to stay inside the Firebase ecosystem and use Firestore as the durable fallback store.

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

- **Complete:** Offline-first chart with cache, auth-aware 3-way remote (Supabase edge→tables vs Firebase cloud→firestore vs direct CoinGecko), data source badge + l10n, and tests. Apply the Supabase migration via MCP `user-supabase` → `apply_migration` with name `chart_trending_tables` (see [supabase_migrations.md](supabase_migrations.md)); check `list_migrations` first to avoid duplicate application.
