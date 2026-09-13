# Migrate profile + search Hive getBox RMW off allowlist

Second Wave 3 slice after chat local DS: sync-demo caches use `runWithBox`.

## What landed

- `HiveProfileCacheRepository.saveProfile` / `clearProfile` → `runWithBox`
- `HiveSearchCacheRepository.saveCachedResults` / `clearCache` → `runWithBox`
  (recent-queries RMW serialized with the result write)
- Allowlist + [`security/storage_rules.md`](../security/storage_rules.md) Known limitations updated
- Concurrent unit tests for both caches
- Honesty: **REC-008** marked done — AP-04 barrel
  (`chat_remote_failure_mapper.dart`) already consolidates chat remote failure
  mappers ([`engineering/flutter-anti-patterns.md`](../engineering/flutter-anti-patterns.md), FN-04)

## Verification

```bash
bash tool/check_hive_getbox_rmw.sh
cd apps/mobile && flutter test \
  test/features/profile/data/profile_cache_repository_test.dart \
  test/features/search/data/search_cache_repository_test.dart
```
