# Realtime market cache resume (2026-06-20)

## Problem

Realtime market reconnects restarted the simulated feed from its bootstrap
state, which could overwrite a richer cached Hive snapshot with sparse initial
book/trade/chart data.

## Change

- Load the cached snapshot before starting or reconnecting the feed.
- Resume the simulator from cached book/trade/chart state instead of initial
  state.
- Guard 24h open reconstruction against `-100%` change snapshots so resumed
  prices stay finite.
- Let the feature-brief checker count untracked `docs/changes/*.md` notes during
  local uncommitted validation.

## Proof

```bash
flutter test test/features/realtime_market/data/realtime_market_repository_test.dart
flutter test test/features/realtime_market/data/simulated_market_feed_test.dart
bash tool/analyze.sh
./bin/checklist
```
