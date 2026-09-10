# Harden Keychain dual-store + Hive getBox RMW early catch

After #834, add static guards so the same classes fail in checklist before merge.

## Bug classes

1. **Keychain delete resurrection:** read peeks legacy; delete must clear both
   envelopes.
2. **Hive getBox RMW:** `getBox()` unlocks before write — concurrent mutations
   can drop updates.

## What landed

- `tool/check_keychain_dual_store_symmetry.sh` — scoped `delete()` body check,
  independent dual-store clears, coexistence + delete-resurrection +
  hardened-delete-failure tests, [`security/storage_rules.md`](../security/storage_rules.md).
- `tool/check_hive_getbox_rmw.sh` / `.py` — detect `await getBox()` then
  `box.put` / `_save*` / `_deleteKeys`; fixture self-test; **per-method** debt
  allowlist (`path#method`, shrink-only; new methods in debt files still fail).
- Wired into `tool/delivery_checklist.sh` `CHECK_SCRIPTS`.
- Regression routing: `secure_secret_storage_test`, `hive_notes_repository_test`
  in `tool/check_regression_guards.sh`.
- Review/docs: storage rules (incl. Known limitations), security + architecture
  checklists, testing anchors, [`tasks/lessons.md`](../../tasks/lessons.md).
- Codex (`gpt-5.6-terra`, medium) review applied: `_save*` detection, per-method
  allowlist, independent Keychain deletes.
- **2026-09-10 follow-up:** migrate high-traffic allowlist debt —
  `HiveTodoRepository` + `PendingSyncRepository` (enqueue / getPending /
  mutations) to `runWithBox`; concurrent unit tests; detector covers
  `_deleteKeys`.

## Known limitations

- Remaining allowlist: chart/GraphQL/search/remote-config/profile/realtime-market
  caches, chat local DS, counter, iGaming balance, staff timeclock, IoT demo
  storage. Next shrink target: IoT + counter when those features are touched.
- `watch*` holding a box after `getBox()` is intentional and not flagged.
- Hardened Keychain delete failure can leave a readable hardened value; legacy
  clear must still succeed independently.

## Verification

```bash
bash tool/check_keychain_dual_store_symmetry.sh
bash tool/check_hive_getbox_rmw.sh
bash tool/check_hive_getbox_rmw.sh --paths tool/fixtures/hive_getbox_rmw/bad_repository.dart  # expect fail
cd apps/mobile && flutter test test/features/todo_list/data/hive_todo_repository_test.dart
cd packages/storage && flutter test test/sync/pending_sync_repository_test.dart
bash tool/fix_validation_docs.sh && bash tool/validate_validation_docs.sh
```
