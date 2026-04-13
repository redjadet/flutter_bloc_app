# Feature Overview

This document is the catalog of user-facing capabilities in the repo. It is not
an implementation deep dive. Use it to find the owning feature module, route,
and the next document to read.

## Source of truth

- Route names and paths: `lib/core/router/app_routes.dart`
- Route composition: `lib/app/router/routes_core.dart`,
  `lib/app/router/routes_demos.dart`, `lib/app/router/route_groups.dart`
- Feature modules: `lib/features/<feature>/`

## Foundation and core flows

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Counter | `/` | `lib/features/counter/` | Primary home flow with persisted state and timer-driven behavior. |
| Example hub | `/example` | `lib/features/example/` | Entry point to many demo surfaces. |
| Settings | `/settings` | `lib/features/settings/` | Theme, locale, app info, diagnostics, and integration entry points. |
| Authentication | `/auth`, `/manage-account`, `/register`, `/logged-out` | `lib/features/auth/` | Firebase Auth + FirebaseUI for primary sign-in and profile management. See [Authentication](authentication.md). |
| Profile | `/profile` | `lib/features/profile/` | Offline-first profile cache and profile screen. |
| Search | `/search` | `lib/features/search/` | Cache-first search with background refresh. |
| Todo List | `/todo-list` | `lib/features/todo_list/` | Realtime Database plus offline-first queueing. |

## Case study demos

Vertical demos driven by product briefs in [`docs/case_studies/`](case_studies/README.md).

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Case Study Demo (dentists) | `/case-study-demo`, `/case-study-demo/new`, `/record`, `/review`, `/history`, `/history/:id` | `lib/features/case_study_demo/` | Ten-question video wizard, review/submit, history and playback. Gated by primary app auth. Local Hive by default; optional Supabase private storage when configured. Brief: [Dentists](case_studies/dentists.md). Plans: [demo rollout](changes/2026-04-01_dentist_case_study_demo_plan.md), [Supabase storage](changes/2026-04-02_case_study_supabase_private_storage_plan.md). |

## Data, sync, and backend-backed demos

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Chat | `/chat`, `/chat-list` | `lib/features/chat/` | Offline-first chat flows with FastAPI Cloud orchestration, direct Hugging Face inference, and documented Supabase proxy support. |
| Charts | `/charts` | `lib/features/chart/` | Deferred-loaded chart experience with offline-first behavior. |
| GraphQL Demo | `/graphql-demo` | `lib/features/graphql_demo/` | Cache-first countries browser with diagnostics support. |
| Remote Config surfaces | Counter and Settings diagnostics | `lib/features/remote_config/` | Runtime feature flags, diagnostics, and cache behavior. |
| IoT Demo | `/iot-demo` | `lib/features/iot_demo/` | Offline-first device list and commands; uses Supabase when configured. |
| Staff App Demo | `/staff-app-demo` and nested paths (dashboard, timeclock, messages, content, forms, proof, admin) | `lib/features/staff_app_demo/` | Firestore-backed staff ops demo; shared site list via `StaffDemoSitesCubit` / `staffDemoSites`. Walkthrough: [Staff app demo](staff_app_demo_walkthrough.md). |
| Supabase Auth | `/supabase-auth` | `lib/features/supabase_auth/` | Separate optional auth flow for Supabase-backed demos. |
| WalletConnect Auth | `/walletconnect-auth` | `lib/features/walletconnect_auth/` | Demo wallet-link flow layered on top of Firebase identity. |
| FCM Demo | `/fcm-demo` | `lib/features/fcm_demo/` | Permission, token, message, and sync-trigger demo. |

## Platform, media, and UI demos

| Feature | Route or entry | Code | Notes |
| --- | --- | --- | --- |
| Google / Apple Maps | `/google-maps` | `lib/features/google_maps/` | Deferred-loaded map experience with platform-specific map providers. |
| WebSocket Demo | `/websocket` | `lib/features/websocket/` | Deferred-loaded reconnecting WebSocket flow. |
| Camera Gallery | `/camera-gallery` | `lib/features/camera_gallery/` | Camera and gallery picker demo. |
| Calculator | `/calculator`, `/calculator/payment` | `lib/features/calculator/` | Calculator and payment summary flow. |
| Whiteboard | `/whiteboard` | `lib/features/example/presentation/pages/whiteboard_page.dart` | `CustomPainter`-based drawing experience. |
| Markdown Editor | `/markdown-editor` | `lib/features/example/presentation/pages/markdown_editor_page.dart` | Deferred-loaded markdown editor using custom rendering. |
| Library Demo | `/library-demo` | `lib/features/library_demo/` | Figma-inspired UI showcase built on shared design patterns. |
| Scapes | `/scapes` | `lib/features/scapes/` | Visual grid and content demo used by the library showcase. |
| GenUI Demo | `/genui-demo` | `lib/features/genui_demo/` | AI-generated UI demo powered by GenUI and Gemini. |
| Playlearn | `/playlearn`, `/playlearn/vocabulary/:topicId` | `lib/features/playlearn/` | Vocabulary and audio-learning demo. |
| iGaming Demo | `/igaming-demo`, `/igaming-demo/game` | `lib/features/igaming_demo/` | Demo lobby and game flow. |
| In-App Purchase Demo | `/iap-demo` | `lib/features/in_app_purchase_demo/` | Demo purchase flow and repository switching. |
| Firebase Functions Test | `/firebase-functions-test` | `lib/features/example/presentation/pages/firebase_functions_test_page.dart` | Utility/debug route for callable function work. |

## Deferred-loaded features

The following routes are intentionally loaded on demand to keep the initial app
bundle smaller:

- `/charts`
- `/google-maps`
- `/markdown-editor`
- `/websocket`

See [Architecture Details](architecture_details.md) and
[Lazy Loading Review](lazy_loading_review.md) for the rationale.

## Cross-cutting modules

- Dependency injection: `lib/core/di/`
- Routing: `lib/app/router/`
- Shared sync infrastructure: `lib/shared/sync/`
- Shared HTTP and auth retry behavior: `lib/shared/http/`
- Shared widgets and design primitives: `lib/shared/widgets/`,
  `lib/shared/components/`, `lib/shared/design_system/`

## Configuration notes

- Firebase-dependent features require platform Firebase configuration. See
  [Firebase Setup](firebase_setup.md).
- Supabase-backed flows require `SUPABASE_URL` and `SUPABASE_ANON_KEY`. See
  [Authentication](authentication.md) and [Security and Secrets](security_and_secrets.md).
- Maps require Google Maps platform keys where applicable. See
  [Google Maps Integration](google_maps_integration.md).
- AI demos require API keys. See [AI Integration](ai_integration.md) and
  [Security and Secrets](security_and_secrets.md).

## Deep-dive references

- [Case studies index](case_studies/README.md)
- [Authentication](authentication.md)
- [Offline-First Adoption Guide](offline_first/adoption_guide.md)
- [Testing Overview](testing_overview.md)
- [Tech Stack](tech_stack.md)
- [FCM Demo Integration](fcm_demo_integration.md)
- [GenUI Demo User Guide](genui_demo_user_guide.md)
- [Google Maps Integration](google_maps_integration.md)
