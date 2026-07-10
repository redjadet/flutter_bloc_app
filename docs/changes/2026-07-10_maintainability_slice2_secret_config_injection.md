# Maintainability Slice 2: inject SecretConfig chat values into chat presentation

**Date:** 2026-07-10

## Problem

`ChatPage`, `ChatListView`, and navigation parts read `SecretConfig` statics
(`chatRenderDemoStrict`, `chatRenderDemoBaseUrl`, `huggingfaceModel`) directly.
That coupled feature presentation to app config loading and blocked pure widget
tests without `SecretConfig` setup.

## Fix

- Require `renderTransportDemoStrict` and `chatRenderDemoBaseUrl` on `ChatPage`.
- Require `initialHuggingfaceModel` plus the same transport fields on
  `ChatListPage` / `ChatListView`; pass through on in-app navigation to
  `ChatPage` and `ChatCubit`.
- Resolve `SecretConfig` once in `routes_demos.dart` when building route
  widgets.
- Remove `renderTransportDemoStrictOverride`; tests pass the bool directly.
- Badge / strict-mode policy unchanged for the same config values.

## Files

| Area | Paths |
| --- | --- |
| Chat presentation | `chat_page.dart`, `chat_list_page.dart`, `chat_list_view.dart`, `chat_list_view_navigation.part.dart` |
| Router | `apps/mobile/lib/app/router/routes_demos.dart` |
| Tests | `chat_page_transport_strict_test.dart` (+ FastAPI Cloud badge cases), updated call sites |

## Verification

```bash
cd apps/mobile
flutter test test/features/chat test/chat_page_test.dart --reporter compact
./tool/analyze.sh
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/modular_metrics.sh --cross-feature-only
rg SecretConfig apps/mobile/lib/features/chat/presentation
rg -n "getIt\.|GetIt\." apps/mobile/lib/features --glob '**/presentation/**/*.dart' -g '!*_test.dart'
```

Expected: focused tests green; analyze + architecture scripts pass; no
`SecretConfig` or presentation `getIt` in chat presentation; transport badge
behavior unchanged for same injected values.
