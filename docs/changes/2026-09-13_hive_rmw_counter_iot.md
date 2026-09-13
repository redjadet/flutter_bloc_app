# Migrate counter + IoT Hive getBox RMW off allowlist

Continue #834 / 2026-09-10 early-catch: remove high-traffic **counter** and
**IoT demo storage** from the per-method Hive RMW allowlist.

## What landed

- `HiveCounterRepository.save` wraps writes in `runWithBox`
- `PersistentIotDemoRepository` storage mutations (`addDeviceImpl`,
  `replaceDevicesImpl`, `connectImpl`, `disconnectImpl`, `sendCommandImpl`) use
  `runWithBox`; connect holds the mutex only around each RMW (not the delay)
- Allowlist + [`security/storage_rules.md`](../security/storage_rules.md) Known limitations updated
- Concurrent unit tests for counter saves and IoT `addDevice`

## Known limitations

Remaining allowlist: demo caches, iGaming balance, staff timeclock. Next
opportunistic shrink: profile/search caches when those features are touched.

## Verification

```bash
bash tool/check_hive_getbox_rmw.sh
cd apps/mobile && flutter test test/hive_counter_repository_test.dart \
  test/features/iot_demo/data/persistent_iot_demo_repository_test.dart
```
