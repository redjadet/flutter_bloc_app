# Maintainability follow-up A — backend-disabled banner as `bool`

**Date:** 2026-07-10
**PR seam:** Follow-up to Rank 1 of [`docs/plans/2026-07-10_maintainability_program.md`](../plans/2026-07-10_maintainability_program.md)

## Goal

Slice 1 injected the `BackendAvailability` *value* into chat and IoT presentation
widgets instead of resolving it via `getIt`, but presentation still imported the
`BackendAvailability` *type* from `app/config/backend_availability.dart` and
recomputed the banner formula locally. This follow-up replaces the type
parameter with a plain `bool showBackendDisabledBanner` computed once at the
router/composition boundary, via two new getters on `BackendAvailability`.

## Locked design

```dart
// apps/mobile/lib/app/config/backend_availability.dart
bool get showChatBackendDisabledBanner =>
    webNoBackendMode && (!firebaseInitialized || !supabaseInitialized);

bool get showIotCloudBackendDisabledBanner =>
    webNoBackendMode && !supabaseInitialized;
```

Formulas are unchanged from the prior inline logic (chat:
`webNoBackendMode && (!firebase || !supabase)`; IoT:
`webNoBackendMode && !supabase`) — only the computation site moved.

## Changes

| Call site | Before | After |
| --- | --- | --- |
| `BackendAvailability` | — | Adds `showChatBackendDisabledBanner`, `showIotCloudBackendDisabledBanner` getters |
| `routes_demos.dart` (chat, chatList routes) | passes `backendAvailability: availability` | passes `showBackendDisabledBanner: availability.showChatBackendDisabledBanner` |
| `routes_demos.part.dart` (iotDemo route) | passes `backendAvailability: availability` to `IotDemoHubPage` | computes `availability.showIotCloudBackendDisabledBanner` once, passes `showBackendDisabledBanner: ...` |
| `IotDemoHubPage` | `required BackendAvailability backendAvailability` | `required bool showBackendDisabledBanner` |
| `IotDemoCloudTab` | `required BackendAvailability backendAvailability` | `required bool showBackendDisabledBanner`; banner `visible` reads the bool directly |
| `ChatPage` | `required BackendAvailability backendAvailability` | `required bool showBackendDisabledBanner`; banner `visible` reads the bool directly |
| `ChatListPage` | threaded `backendAvailability` | threads `showBackendDisabledBanner` bool |
| `ChatListView` | threaded `backendAvailability` | threads `showBackendDisabledBanner` bool |
| `ChatListView._ChatListViewNavigation` (navigation part) | passed `backendAvailability` to pushed `ChatPage` | passes `showBackendDisabledBanner` |

`BackendAvailability` stays in `apps/mobile/lib/app/config/` and is still used
by `apps/mobile/lib/app/**` composition/router code and by
`register_auth_services.dart` (auth policy, unrelated to the banner). Tests
that exercise `BackendAvailability` itself (`backend_availability_test.dart`)
and DI registration (`register_auth_services_test.dart`) are unchanged in
shape.

## Proof

```bash
cd apps/mobile && flutter test \
  test/features/chat/presentation/pages/chat_page_backend_banner_test.dart \
  test/features/iot_demo/presentation/widgets/iot_demo_cloud_tab_backend_banner_test.dart \
  --reporter compact
cd .. && ./tool/analyze.sh
rg -n "package:flutter_bloc_app/app/(config|bootstrap)/" apps/mobile/lib/features --glob '**/presentation/**/*.dart'
# Expect: 0 matches (previously: BackendAvailability only, in chat + iot_demo_cloud_tab)
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
./bin/router_feature_validate
```

All commands pass; observable banner behavior is unchanged for the same
`BackendAvailability` inputs (verified via the two formula-derived getters and
the widget banner-visibility tests above, plus new unit tests on
`showChatBackendDisabledBanner` / `showIotCloudBackendDisabledBanner` in
`backend_availability_test.dart`).
