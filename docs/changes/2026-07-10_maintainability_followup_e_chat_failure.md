# Maintainability follow-up E — ChatFailure

**Date:** 2026-07-10  
**Seam:** Rank 6 / chat P6

## Change

Add `ChatFailure` (freezed: `message` + optional `l10nCode`).  
`ChatState` stores `ChatFailure? failure` (compat getters `error` / `remoteFailureL10nCode`).  
`ChatListState.error` carries `ChatFailure` instead of bare `String message`.

## Proof

```bash
flutter test \
  test/features/chat/presentation/chat_list_cubit_test.dart \
  test/features/chat/presentation/widgets/chat_list_view_test.dart \
  test/features/chat/presentation/widgets/chat_message_list_remote_failure_l10n_test.dart \
  test/features/chat/presentation/cubit/
```
