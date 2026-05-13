# Realtime market demo

Simulated high-frequency order book + trades for **UI and state patterns only**
(no exchange, no real money, no WebSocket to production).

## Stack

- **Domain**: `RealtimeMarketRepository`, `MarketFeedSnapshot`, use cases
  (`LoadCachedMarketSnapshot`, `WatchRealtimeMarket`, `ReconnectRealtimeMarket`).
- **Data**: `SimulatedMarketFeed` (timers), `RealtimeMarketRepositoryImpl`
  (caps + Hive persistence), `RealtimeMarketLocalDataSource` (box
  `realtime_market_v1`).
- **Presentation**: `RealtimeMarketCubit` (cache-first bootstrap, stream
  listen via `CubitSubscriptionMixin`), `RealtimeMarketPage` (deferred route,
  `RefreshIndicator`, skeletonizer). Widgets under
  `lib/features/realtime_market/presentation/widgets/` — header + disclaimer,
  connection pill, segmented buy/sell focus, order book with column headers and
  per-row depth tint, recent trades (empty state), stats card, `fl_chart` line
  chart with grid + touch tooltip + area fill. Buy/sell accents use app success
  green + `ColorScheme.error` via `realtime_market_ui_tokens.dart`.
- **Security stubs** (Phase 2 placeholders, not wired): `CertificatePinningPolicy`,
  `TradingApiTokenStore`, `RealtimeMarketBackendConfig`, `MarketFeedRemotePort`
  (`NoopMarketFeedRemotePort`).

## Routing & DI

- Deep link / universal path segment: `realtime-market` (maps to `AppRoutes.realtimeMarketPath`). Host `/.well-known/apple-app-site-association` template includes `/realtime-market` when you ship verified links.
- Route: `AppRoutes.realtimeMarket` → deferred `buildRealtimeMarketPage()` builds a
  **per-visit** `RealtimeMarketRepositoryImpl` so `cubit.close()` can call
  `repository.dispose()` without stopping a global singleton.
- Registration: `registerRealtimeMarketServices()` from
  `register_demo_services` registers Hive data source, simulator feed, and stubs.

## Entry

- **Counter (home)**: app bar chart icon (`Icons.show_chart` / `CupertinoIcons.chart_bar`) and **More** overflow → “Open realtime market demo”.
- **Example hub**: **Realtime market demo** (`ValueKey('example-realtime-market-button')`).

## Localization

Strings live in `lib/l10n/app_*.arb` under the `realtimeMarket*` prefix. Besides
title, connection labels, and section titles, the UI adds: disclaimer
(`realtimeMarketDisclaimer`), order book column headers
(`realtimeMarketOrderBookColumnPrice` / `realtimeMarketOrderBookColumnAmount`), empty trades
(`realtimeMarketTradesEmpty`), and pull-to-refresh hint
(`realtimeMarketPullToRefreshHint`) used on error/empty surfaces. Run
`flutter gen-l10n` after arb edits.

## Verification

```bash
./bin/router_feature_validate
flutter test test/features/realtime_market/
flutter test test/features/realtime_market/presentation/realtime_market_page_layout_test.dart
```

The layout test pumps **RealtimeMarketPage** at iPhone size with a **16×16** order book (same depth as `SimulatedMarketFeed`) and fails if any `FlutterError` mentions **overflow** — catches fixed-height flex regressions before manual QA. It uses `pumpAndSettle` with a bounded duration; reconnecting UI must not use an infinite animation (for example, avoid an indeterminate progress indicator on the connection pill) so the test can settle.
