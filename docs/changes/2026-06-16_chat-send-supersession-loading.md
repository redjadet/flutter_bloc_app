# Chat send: clear loading when RequestIdGuard superseded

**Date:** 2026-06-16

## Summary

- **`ChatCubit.sendMessage`**: After a successful remote reply, clear `isLoading` and persist the assistant message when a concurrent `loadHistory` / `deleteConversation` bumps the request id — same bug class as therapy booking (#328/#330).
- **`ChatCubit` history actions**: `loadHistory` / `deleteConversation` emit `isLoading: false` so in-flight sends cannot remain stuck.

## Verification

```bash
flutter test test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart
bash tool/check_mutation_success_after_guard.sh
```
