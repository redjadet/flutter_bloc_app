# Chat persist epoch for destructive history races

**Date:** 2026-06-23

## Summary

- **`ChatCubit` history persistence:** Add a persist epoch so late unawaited
  `sendMessage` assistant saves cannot restore chat history after
  `clearHistory` or `deleteConversation`.
- **History actions:** Destructive history operations bump the epoch before
  saving their newer snapshot.
- **Regression tests:** Cover delayed `sendMessage` completion racing with
  `clearHistory` and `deleteConversation`.

## Verification

```bash
flutter test test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart test/chat_cubit_test.dart
flutter analyze lib/features/chat/presentation/cubit/
```
