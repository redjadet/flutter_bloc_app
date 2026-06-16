# Chat send: clear loading when RequestIdGuard superseded

**Date:** 2026-06-16

## Summary

- **`ChatCubit.sendMessage`**: After a successful remote reply, clear `isLoading` and persist the assistant message when a concurrent `loadHistory` / `deleteConversation` bumps the request id — same bug class as therapy booking (#328/#330).
- **`ChatCubit` history actions**: `loadHistory` / `deleteConversation` emit `isLoading: false` so in-flight sends cannot remain stuck.
- **`tool/check_regression_guards.sh`**: RequestIdGuard / chat changes now route to the chat supersession regression so the stuck-loading race is checked before merge.
- **`tool/delivery_checklist.sh`**: RequestIdGuard / chat supersession paths run focused regression guards before coverage, catching this class during checklist Step 4 instead of waiting for Step 5.

## Verification

```bash
flutter test test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart
bash tool/check_mutation_success_after_guard.sh
CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths lib/features/chat/presentation/cubit/chat_cubit_message_actions.dart
```
