# Feature Overview

This document is the catalog of user-facing capabilities in the repo. It is not
an implementation deep dive. Use it to find the owning feature module, route,
and the next document to read.

## Source of truth

- Route names and paths: `apps/mobile/lib/app/router/app_routes.dart`
- Route composition: `apps/mobile/lib/app/router/routes_core.dart`,
  `apps/mobile/lib/app/router/routes_demos.dart`, `apps/mobile/lib/app/router/route_groups.dart`,
  `apps/mobile/lib/app/router/routes_staff_app_demo.dart`,
  `apps/mobile/lib/app/router/routes_case_study_demo.dart`, and
  `apps/mobile/lib/app/router/routes_online_therapy_demo.dart`
- Feature modules: `apps/mobile/lib/features/<feature>/`

Complex features may include a co-located README (see
[`architecture/complex_feature_readme_template.md`](architecture/complex_feature_readme_template.md)).
Current READMEs: `native_platform_showcase`, `iot`, `library_demo`.

## Foundation and core flows

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Counter | `/` | `apps/mobile/lib/features/counter/` | Primary home flow with persisted state and timer-driven behavior. |
| Example hub | `/example` | `apps/mobile/lib/features/example/` | Entry point to many demo surfaces. |
| Settings | `/settings` | `apps/mobile/lib/features/settings/` | Theme, locale, app info, diagnostics, and integration entry points. **Auth-gated** (see [Authentication](authentication.md)). |
| Authentication | `/auth`, `/manage-account`, `/register`, `/logged-out` | `apps/mobile/lib/features/auth/` | Firebase Auth + FirebaseUI for primary sign-in and profile management. `/manage-account` is **auth-gated** (see [Authentication](authentication.md)). |
| Profile | `/profile` | `apps/mobile/lib/features/profile/` | Offline-first profile cache and profile screen. |
| Search | `/search` | `apps/mobile/lib/features/search/` | Cache-first search with background refresh. |
| Todo List | `/todo-list` | `apps/mobile/lib/features/todo_list/` | Realtime Database plus offline-first queueing. |

## Case study demos

Vertical demos driven by product briefs in [`docs/case_studies/`](case_studies/README.md).

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Case Study Demo (dentists) | `/case-study-demo`, `/case-study-demo/new`, `/record`, `/review`, `/history`, `/history/:id` | `apps/mobile/lib/features/case_study_demo/` | Ten-question video wizard, review/submit, history and playback. Gated by primary app auth. Local Hive by default; optional Supabase private storage when configured. Brief: [Dentists](case_studies/dentists.md). Plans: [demo rollout](changes/2026-04-01_dentist_case_study_demo_plan.md). |

## Data, sync, and backend-backed demos

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Chat | `/chat`, `/chat-list` | `apps/mobile/lib/features/chat/` | Offline-first chat flows with FastAPI Cloud orchestration, direct Hugging Face inference, and documented Supabase proxy support. |
| AI Decision Workbench | `/ai-decision-demo` (Example hub entry) | `apps/mobile/lib/features/ai_decision_demo/` | Local decision support demo with seeded SQLite cases, risk score, rationale, visible proof trail, and action history. Backend: `demos/ai_decision_api/`. Doc: [`ai_decision_workbench.md`](ai_decision_workbench.md). |
| Charts | `/charts` | `apps/mobile/lib/features/chart/` | Deferred-loaded chart experience with offline-first behavior. |
| GraphQL Demo | `/graphql-demo` | `apps/mobile/lib/features/graphql_demo/` | Cache-first countries browser with diagnostics support. |
| Remote Config surfaces | Counter and Settings diagnostics | `apps/mobile/lib/features/remote_config/` | Runtime feature flags, diagnostics, and cache behavior. |
| IoT Demo | `/iot-demo` | `apps/mobile/lib/features/iot_demo/` (+ BLE: `apps/mobile/lib/features/iot/`) | **Cloud** tab: offline-first device list; Supabase when configured. **BLE** tab: local GATT showcase (mock + optional real mobile). Hub: `IotDemoHubPage`. Doc: [`features/iot_ble.md`](features/iot_ble.md); cloud contract: [`offline_first/iot_demo.md`](offline_first/iot_demo.md). |
| Staff App Demo | `/staff-app-demo` and nested paths (dashboard, timeclock, messages, content, forms, proof, admin) | `apps/mobile/lib/features/staff_app_demo/` | Firestore-backed staff ops demo; shared site list via `StaffDemoSitesCubit` / `staffDemoSites`. Walkthrough: [Staff app demo](staff_app_demo_walkthrough.md). |
| Online Therapy Demo | `/online-therapy-demo` and nested client, therapist, and admin paths | `apps/mobile/lib/features/online_therapy_demo/` | Simulation-first product demo for booking, messaging, call state, verification, and admin audit flows. Walkthrough: [Online Therapy Demo](online_therapy_demo/README.md). |
| Supabase Auth | `/supabase-auth` | `apps/mobile/lib/features/supabase_auth/` | Separate optional auth flow for Supabase-backed demos. |
| WalletConnect Auth | `/walletconnect-auth` | `apps/mobile/lib/features/walletconnect_auth/` | Demo wallet-link flow layered on top of Firebase identity. **Auth-gated** (see [Authentication](authentication.md)). |
| FCM Demo | `/fcm-demo` | `apps/mobile/lib/features/fcm_demo/` | Permission, token, message, and sync-trigger demo. |

## Platform, media, and UI demos

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Google / Apple Maps | `/google-maps` | `apps/mobile/lib/features/google_maps/` | Deferred-loaded map experience with platform-specific map providers. |
| Native Platform Showcase | `/native-platform-showcase` (Example hub entry) | `apps/mobile/lib/features/native_platform_showcase/` | Capability catalog plus live command `MethodChannel` (Swift/Kotlin), bounded streaming `EventChannel` telemetry demo, and FFI (C/C++); presentation → use cases → repository / telemetry service ports. Web builds with unavailable stubs. README: [`apps/mobile/lib/features/native_platform_showcase/README.md`](../apps/mobile/lib/features/native_platform_showcase/README.md). Portfolio depth: [`interview_showcase.md`](interview_showcase.md) §13. |
| WebSocket Demo | `/websocket` | `apps/mobile/lib/features/websocket/` | Deferred-loaded reconnecting WebSocket flow. |
| Realtime market demo (simulated) | `/realtime-market` (Example hub entry) | `apps/mobile/lib/features/realtime_market/` | Simulated order book + trades; Hive cache; no production exchange. Doc: [`features/realtime_market.md`](features/realtime_market.md). |
| Camera Gallery | `/camera-gallery` | `apps/mobile/lib/features/camera_gallery/` | Camera and gallery picker with on-device original, grayscale, sepia, and invert previews. |
| Calculator | `/calculator`, `/calculator/payment` | `apps/mobile/lib/features/calculator/` | Calculator and payment summary flow. |
| Whiteboard | `/whiteboard` | `apps/mobile/lib/features/example/presentation/pages/whiteboard_page.dart` | `CustomPainter`-based drawing experience. |
| Markdown Editor | `/markdown-editor` | `apps/mobile/lib/features/example/presentation/pages/markdown_editor_page.dart` | Deferred-loaded markdown editor using custom rendering. |
| Library Demo | `/library-demo` | `apps/mobile/lib/features/library_demo/` | Figma-inspired UI showcase built on shared design patterns. |
| Scapes | `/scapes` | `apps/mobile/lib/features/scapes/` | Visual grid and content demo used by the library showcase. |
| GenUI Demo | `/genui-demo` | `apps/mobile/lib/features/genui_demo/` | AI-generated UI demo powered by GenUI and Gemini. |
| Playlearn | `/playlearn`, `/playlearn/vocabulary/:topicId` | `apps/mobile/lib/features/playlearn/` | Vocabulary and audio-learning demo. |
| iGaming Demo | `/igaming-demo`, `/igaming-demo/game` | `apps/mobile/lib/features/igaming_demo/` | Demo lobby and game flow. |
| In-App Purchase Demo | `/iap-demo` | `apps/mobile/lib/features/in_app_purchase_demo/` | Demo purchase flow and repository switching. |
| Firebase Functions Test | `/firebase-functions-test` | `apps/mobile/lib/features/example/presentation/pages/firebase_functions_test_page.dart` | Utility/debug route for callable function work. |

## Deferred-loaded features

The following routes are intentionally loaded on demand to keep the initial app
bundle smaller:

- `/charts`
- `/google-maps`
- `/markdown-editor`
- `/websocket`
- `/realtime-market`

See [Architecture Details](architecture_details.md) and
[Lazy Loading Review](performance/lazy_loading_review.md) for the rationale.

## Cross-cutting modules

- Dependency injection: `apps/mobile/lib/app/composition/`
- Routing: `apps/mobile/lib/app/router/`
- Shared sync infrastructure: `packages/storage/lib/src/sync/`
- Shared HTTP and auth retry behavior: `packages/networking/lib/src/`
- Shared widgets and design primitives: `apps/mobile/lib/app/widgets/`,
  `packages/design_system/`, `packages/design_system/`

## Configuration notes

- Firebase-dependent features require platform Firebase configuration. See
  [Firebase Setup](firebase_setup.md).
- Supabase-backed flows require `SUPABASE_URL` and `SUPABASE_ANON_KEY`. See
  [Authentication](authentication.md) and [Security and Secrets](security_and_secrets.md).
- Universal-link handling is implemented under `apps/mobile/lib/features/deeplink/`; host
  verification files live in [Universal Links](universal_links/README.md).
- Maps require Google Maps platform keys where applicable. See
  [Google Maps Integration](google_maps_integration.md).
- AI chat demos require API keys. See [AI Integration](ai_integration.md) and
  [Security and Secrets](security_and_secrets.md).
- AI Decision Workbench uses FastAPI Cloud by default on all platforms.
  Override with `AI_DECISION_API_BASE_URL` when needed. See
  [AI Decision Workbench](ai_decision_workbench.md).

## Deep-dive references

- [Case studies index](case_studies/README.md)
- [AI Decision Workbench](ai_decision_workbench.md)
- [Authentication](authentication.md)
- [Offline-First Adoption Guide](offline_first/adoption_guide.md)
- [Testing Overview](testing_overview.md)
- [Tech Stack](tech_stack.md)
- [FCM Demo Integration](fcm_demo_integration.md)
- [GenUI Demo User Guide](genui_demo_user_guide.md)
- [Google Maps Integration](google_maps_integration.md)
- [Native Platform Showcase](../apps/mobile/lib/features/native_platform_showcase/README.md) (feature README; brief: [2026-06-08](changes/2026-06-08_native_platform_showcase_feature_brief.md))
