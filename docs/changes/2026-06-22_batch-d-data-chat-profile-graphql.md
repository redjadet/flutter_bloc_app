# Batch D — chat, profile, graphql correctness

**Date:** 2026-06-22

## Summary

- **Chat `resetConversation`:** persist history before emitting cleared state; on save failure keep prior state and surface error.
- **Profile `pullRemote`:** `_doRefreshAndCache` propagates failures; `_saveProfileToCache` rethrows after log so cold `getProfile` and `pullRemote` fail when cache write fails; background cache refresh still logs-only via `catchError`.
- **GraphQL pull-to-refresh:** `onRefresh` awaits `cubit.refresh()` directly.

## Verification

```bash
flutter test test/chat_cubit_test.dart --name "resetConversation"
flutter test test/features/profile/data/offline_first_profile_repository_test.dart --name "pullRemote|cache save"
flutter test test/features/graphql_demo/presentation/
```
