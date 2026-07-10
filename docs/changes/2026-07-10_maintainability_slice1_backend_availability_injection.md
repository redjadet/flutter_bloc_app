# Maintainability Slice 1: inject BackendAvailability into chat + IoT cloud UI

**Date:** 2026-07-10

## Problem

`ChatPage` and `IotDemoCloudTab` resolved `BackendAvailability` via GetIt (with
`fromBootstrap()` fallback). That coupled feature presentation to the service
locator and duplicated composition-root policy.

## Fix

- Require `BackendAvailability` on `ChatPage`, `IotDemoCloudTab`, and
  `IotDemoHubPage` (hub passes through to cloud tab).
- Thread through `ChatListPage` / `ChatListView` for in-app navigation to chat.
- Resolve `getIt<BackendAvailability>()` once in `routes_demos.dart` /
  `routes_demos.part.dart` when building route widgets.
- Banner visibility policy unchanged (same boolean expressions as before).

## Files

| Area | Paths |
| --- | --- |
| Chat | `apps/mobile/lib/features/chat/presentation/pages/chat_page.dart`, `chat_list_page.dart`, `widgets/chat_list_view.dart`, `chat_list_view_navigation.part.dart` |
| IoT | `apps/mobile/lib/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart` |
| Router | `apps/mobile/lib/app/router/pages/iot_demo_hub_page.dart`, `routes_demos.dart`, `routes_demos.part.dart` |
| Tests | `chat_page_backend_banner_test.dart`, `iot_demo_cloud_tab_backend_banner_test.dart`, updated call sites |

## Verification

```bash
cd apps/mobile
flutter test test/features/chat test/features/iot_demo --reporter compact
flutter test test/app/router/ --reporter compact
./tool/analyze.sh
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/modular_metrics.sh --cross-feature-only
rg -n "getIt\.|GetIt\." \
  apps/mobile/lib/features/chat/presentation/pages/chat_page.dart \
  apps/mobile/lib/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart
```

Expected: focused tests green; analyze + architecture scripts pass; no GetIt in
the two primary presentation call sites; banner text unchanged for same
`BackendAvailability` inputs.
