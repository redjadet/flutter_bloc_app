# Migrate chat local DS Hive getBox RMW off allowlist

Wave 3 slice of the balanced backlog: interview-spine chat history save uses
`runWithBox`.

## What landed

- `ChatLocalDataSource.save` wraps writes in `runWithBox`
- Allowlist + [`security/storage_rules.md`](../security/storage_rules.md) Known limitations updated
- Concurrent save unit test

## Verification

```bash
bash tool/check_hive_getbox_rmw.sh
cd apps/mobile && flutter test test/features/chat/data/chat_local_data_source_test.dart
```
