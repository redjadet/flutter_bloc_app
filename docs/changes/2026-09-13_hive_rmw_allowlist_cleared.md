# Clear remaining Hive getBox RMW allowlist

Wave 3 follow-up: migrate last allowlisted mutations to `runWithBox`.

## What landed

- Chart, GraphQL cache, iGaming balance, realtime market snapshot,
  remote config cache, staff timeclock local store → `runWithBox`
- Realtime market `saveSnapshot` TOCTOU (load+compare+put) now one critical section
- Allowlist empty; [`storage_rules.md`](../security/storage_rules.md) Known limitations updated

## Verification

```bash
bash tool/check_hive_getbox_rmw.sh
```
