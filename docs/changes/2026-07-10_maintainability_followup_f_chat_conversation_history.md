# Maintainability follow-up F — chat conversation history domain

**Date:** 2026-07-10  
**Seam:** Rank 5 / chat P5

## Change

Move pure history list transforms (`sort`, `byId`, `replace`) into
`domain/chat_conversation_history.dart`. Cubit helpers become thin wrappers;
emit/persist stay in presentation.

## Proof

```bash
flutter test test/features/chat/domain/chat_conversation_history_test.dart
flutter test test/features/chat/presentation/
```
