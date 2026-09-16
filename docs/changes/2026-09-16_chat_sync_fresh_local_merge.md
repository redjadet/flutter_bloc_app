# Chat sync fresh-local merge

## Why

Chat background sync captured local history before awaiting remote inference.
Writing the terminal result or a non-retryable failure through that stale
snapshot could restore a deleted conversation or discard a follow-up added
while the request was in flight.

## Change

- Re-read `ChatHistoryRepository` immediately before terminal sync writes.
- Update only the matching conversation in the fresh list; skip a conversation
  deleted while sync was in flight.
- Preserve concurrent messages in that conversation while applying the remote
  reply or terminal failure marker.
- Extend the existing `check_offline_first_remote_merge.sh` guard so chat data
  changes run and inventory these updater regressions before later checklist
  lanes.

## Proof

```bash
cd apps/mobile
flutter test test/features/chat/data/chat_local_conversation_updater_test.dart
cd ../..
CHECK_OFFLINE_FIRST_REMOTE_MERGE_MODE=always \
  bash tool/check_offline_first_remote_merge.sh
```
