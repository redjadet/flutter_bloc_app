# Realtime market cache resume (2026-06-20)

## Problem

Realtime market reconnects restarted the simulated feed from its bootstrap
state, which could overwrite a richer cached Hive snapshot with sparse initial
book/trade/chart data.

## Change

- Load the cached snapshot before starting or reconnecting the feed.
- Resume the simulator from cached book/trade/chart state instead of initial
  state.
- Seed generated trade ids from the highest cached `recentTrades` id so resumed
  snapshots cannot contain duplicate trade ids.
- Register the realtime market feed regression test in
  `tool/check_regression_guards.sh` so `./bin/checklist` catches future
  duplicate-id regressions.
- Guard 24h open reconstruction against `-100%` change snapshots so resumed
  prices stay finite.
- Let the feature-brief checker count untracked `docs/changes/*.md` notes during
  local uncommitted validation.

## Proof

```bash
flutter test test/features/realtime_market/data/realtime_market_repository_test.dart
flutter test test/features/realtime_market/data/simulated_market_feed_test.dart
CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths apps/mobile/lib/features/realtime_market/data/simulated_market_feed.dart
bash tool/analyze.sh
./bin/checklist
```
