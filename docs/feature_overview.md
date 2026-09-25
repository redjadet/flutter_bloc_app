# Feature Overview

This document is the catalog of user-facing capabilities in the repo. It is not
an implementation deep dive. Use it to find the owning feature module, route,
and the next document to read.

## Feature tiers (Spine / Depth / Archive)

| Tier | Meaning | Investment rule |
| --- | --- | --- |
| **Spine** | Frozen interview / ownership walk modules | Keep green; preferred place for architecture proof |
| **Depth** | Follow-up demos and gold-layout references | Maintain when touched; no net-new sibling demos without Archive swap |
| **Archive** | Kept for history / screenshots; low priority | **No new investment** unless promoted (ADR-0005) |

Promotion / replacement requires an ADR or change note plus PR checklist acknowledgment.
NOT-in-scope (Phase 2–4 deferred work): [`scope_register.md`](scope_register.md).
Evidence baseline: [`changes/2026-09-24_authority_phase_0_evidence_baseline.md`](changes/2026-09-24_authority_phase_0_evidence_baseline.md).

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
Current READMEs: `native_platform_showcase`, `iot`, `library_demo`,
`secure_messaging_demo`.

## Foundation and core flows

| Feature | Tier | Route or entry | Code | Notes |
| --- | --- | --- | --- | --- |
| Counter | Spine | `/` | `apps/mobile/lib/features/counter/` | Primary home flow; offline-first + timer. Interview spine #1. |
| Todo List | Spine | `/todo-list` | `apps/mobile/lib/features/todo_list/` | Realtime Database + offline-first queue. Interview spine #2. |
| Chat | Spine | `/chat`, `/chat-list` | `apps/mobile/lib/features/chat/` | Offline-first chat; FastAPI / HF / Supabase paths. Interview spine #3. |
| Settings | Spine | `/settings` | `apps/mobile/lib/features/settings/` | Theme, locale, sync diagnostics (manual spine #4). |
| Authentication | Spine | `/auth`, `/manage-account`, `/register`, `/logged-out` | `apps/mobile/lib/features/auth/` | Firebase Auth + FirebaseUI. `/manage-account` auth-gated. |
| Profile | Spine | `/profile` | `apps/mobile/lib/features/profile/` | Offline-first profile cache; auth-gated. |
| Remote Config | Spine | Counter + Settings diagnostics | `apps/mobile/lib/features/remote_config/` | Runtime flags; Tier A gold with intentional P6 Yellow. |
| Deeplink | Spine | (host → GoRouter) | `apps/mobile/lib/features/deeplink/` | Universal/app links; auth redirect matrix. |
| Example hub | Depth | `/example` | `apps/mobile/lib/features/example/` | Entry to many Depth/Archive surfaces. |
| Search | Depth | `/search` | `apps/mobile/lib/features/search/` | Cache-first search with background refresh. |

## Case study demos

Vertical demos driven by product briefs in [`docs/case_studies/`](case_studies/README.md).

| Feature | Tier | Route or entry | Code | Notes |
| --- | --- | --- | --- | --- |
| Case Study Demo (dentists) | Depth | `/case-study-demo`, … | `apps/mobile/lib/features/case_study_demo/` | Auth-gated video wizard. Brief: [Dentists](case_studies/dentists.md). |

## Data, sync, and backend-backed demos

| Feature | Tier | Route or entry | Code | Notes |
| --- | --- | --- | --- | --- |
| AI Decision Workbench | Depth | `/ai-decision-demo` | `apps/mobile/lib/features/ai_decision_demo/` | Local decision support; sealed Freezed state. Doc: [`ai_decision_workbench.md`](features/ai_decision_workbench.md). |
| Charts | Depth | `/charts` | `apps/mobile/lib/features/chart/` | Deferred-loaded; offline-first. |
| GraphQL Demo | Depth | `/graphql-demo` | `apps/mobile/lib/features/graphql_demo/` | Cache-first countries browser. |
| IoT Demo | Depth | `/iot-demo` | `apps/mobile/lib/features/iot_demo/` (+ BLE: `iot/`) | Cloud + BLE tabs. Doc: [`features/iot_ble.md`](features/iot_ble.md). |
| Staff App Demo | Depth | `/staff-app-demo`, … | `apps/mobile/lib/features/staff_app_demo/` | Firestore staff ops; auth-gated. |
| Online Therapy Demo | Depth | `/online-therapy-demo`, … | `apps/mobile/lib/features/online_therapy_demo/` | Simulation-first product demo. |
| Production readiness | Depth | `/production-readiness` | `apps/mobile/lib/features/production_readiness/` | Alternate §3b ownership spine (ADR-0005/0006). |
| Social feed demo | Depth | `/social-feed-demo` | `apps/mobile/lib/features/social_feed_demo/` | Offline queue / optimistic UI judgment demo. |
| Supabase Auth | Depth | `/supabase-auth` | `apps/mobile/lib/features/supabase_auth/` | Optional auth for Supabase demos. |
| WalletConnect Auth | Depth | `/walletconnect-auth` | `apps/mobile/lib/features/walletconnect_auth/` | Auth-gated wallet-link demo. |
| FCM Demo | Depth | `/fcm-demo` | `apps/mobile/lib/features/fcm_demo/` | Permission, token, sync-trigger demo. |
| Realtime market | Depth | `/realtime-market` | `apps/mobile/lib/features/realtime_market/` | Simulated order book; Hive cache. |
| WebSocket Demo | Depth | `/websocket` | `apps/mobile/lib/features/websocket/` | Deferred reconnecting WebSocket. |
| Notes demo | Archive | `/notes-demo` | `apps/mobile/lib/features/notes_demo/` | Local-only offline exception; no net-new investment. |
| Weather demo | Archive | `/weather-demo` | `apps/mobile/lib/features/weather_demo/` | Portfolio filler; Archive unless promoted. |

## Platform, media, and UI demos

| Feature | Tier | Route or entry | Code | Notes |
| --- | --- | --- | --- | --- |
| Native Platform Showcase | Depth | `/native-platform-showcase` | `apps/mobile/lib/features/native_platform_showcase/` | MethodChannel / EventChannel / FFI / PlatformView. Teaching pack → Phase 2. |
| Secure messaging (Rust FFI) | Depth | `/secure-messaging-demo` | `apps/mobile/lib/features/secure_messaging_demo/` + `packages/secure_core_bridge/` | AES-256-GCM via Rust FFI. |
| Certificate pinning demo | Depth | (Example hub) | `apps/mobile/lib/features/certificate_pinning_demo/` | Policy demo; default off. |
| Event bus demo | Archive | (Example hub) | `apps/mobile/lib/features/event_bus_demo/` | Pattern sample only. |
| Google / Apple Maps | Depth | `/google-maps` | `apps/mobile/lib/features/google_maps/` | Deferred-loaded maps. |
| Camera Gallery | Depth | `/camera-gallery` | `apps/mobile/lib/features/camera_gallery/` | On-device filters. |
| Calculator | Depth | `/calculator`, `/calculator/payment` | `apps/mobile/lib/features/calculator/` | Pure domain payment rules (gold layout). |
| GenUI Demo | Depth | `/genui-demo` | `apps/mobile/lib/features/genui_demo/` | AI-generated UI. |
| In-App Purchase Demo | Depth | `/iap-demo` | `apps/mobile/lib/features/in_app_purchase_demo/` | Purchase flow demo. |
| Library Demo | Archive | `/library-demo` | `apps/mobile/lib/features/library_demo/` | Figma-inspired UI showcase; no net-new investment. |
| Scapes | Depth | `/scapes` | `apps/mobile/lib/features/scapes/` | Visual grid; sealed-state gold reference. |
| Playlearn | Archive | `/playlearn`, … | `apps/mobile/lib/features/playlearn/` | Vocabulary demo; Archive. |
| iGaming Demo | Archive | `/igaming-demo`, … | `apps/mobile/lib/features/igaming_demo/` | Lobby/game filler; Archive. |
| Whiteboard | Archive | `/whiteboard` | `apps/mobile/lib/features/example/…/whiteboard_page.dart` | CustomPainter toy. |
| Markdown Editor | Archive | `/markdown-editor` | `apps/mobile/lib/features/example/…/markdown_editor_page.dart` | Deferred editor toy. |
| Firebase Functions Test | Depth | `/firebase-functions-test` | `apps/mobile/lib/features/example/…/firebase_functions_test_page.dart` | Auth-gated callable diagnostic. |

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
  `packages/design_system/`

## Configuration notes

- Firebase-dependent features require platform Firebase configuration. See
  [Firebase Setup](integrations/firebase_setup.md).
- Supabase-backed flows require `SUPABASE_URL` and `SUPABASE_ANON_KEY`. See
  [Authentication](authentication.md) and [Security and Secrets](security_and_secrets.md).
- Universal-link handling is implemented under `apps/mobile/lib/features/deeplink/`; host
  verification files live in [Universal Links](universal_links/README.md).
- Maps require Google Maps platform keys where applicable. See
  [Google Maps Integration](integrations/google_maps_integration.md).
- AI chat demos require API keys. See [AI Integration](integrations/ai_integration.md) and
  [Security and Secrets](security_and_secrets.md).
- AI Decision Workbench uses FastAPI Cloud by default on all platforms.
  Override with `AI_DECISION_API_BASE_URL` when needed. See
  [AI Decision Workbench](features/ai_decision_workbench.md).

## Deep-dive references

- [Scope register](scope_register.md)
- [Case studies index](case_studies/README.md)
- [AI Decision Workbench](features/ai_decision_workbench.md)
- [Authentication](authentication.md)
- [Deep-link auth matrix](architecture/deep_link_auth_matrix.md)
- [Offline-First Adoption Guide](offline_first/adoption_guide.md)
- [Testing Overview](testing_overview.md)
- [Tech Stack](tech_stack.md)
- [FCM Demo Integration](integrations/fcm_demo_integration.md)
- [GenUI Demo User Guide](features/genui_demo_user_guide.md)
- [Google Maps Integration](integrations/google_maps_integration.md)
- [Native Platform Showcase](../apps/mobile/lib/features/native_platform_showcase/README.md)
- [Secure messaging demo](features/secure_messaging_demo.md)
