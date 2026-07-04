# Feature map

Per-feature agent context. **17 full** + **15 stub** = 32 modules (2026-06-08). Catalog: [`docs/feature_overview.md`](../../docs/feature_overview.md).

**Legend:** `minimal_context` = smallest file set before editing (expand only as needed).

---

## Full entries

### counter (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Home flow; persisted count + timer behavior |
| Routes | `/` |
| LOC | 3983 |
| Layers | `domain/`, `data/` (Hive, REST), `presentation/cubit/counter_cubit*` |
| Key paths | `apps/mobile/lib/features/counter/counter.dart`, `presentation/pages/counter_page.dart` |
| Tests | `test/features/counter/` |
| Docs | [`docs/feature_overview.md`](../../docs/feature_overview.md) |
| minimal_context | `counter.dart`, `counter_cubit_base.dart`, `counter_page.dart`, `domain/*repository*.dart`, `data/hive_counter_repository*.dart` |

### auth (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Firebase Auth + FirebaseUI sign-in / register / profile |
| Routes | `/auth`, `/register`, `/logged-out`, `/manage-account` |
| LOC | 2293 |
| Layers | `domain/auth_repository.dart`, `data/firebase_auth_repository.dart`, `presentation/cubit/` |
| Tests | `test/features/auth/` |
| Docs | [`docs/authentication.md`](../../docs/authentication.md) |
| minimal_context | `auth.dart`, `auth_repository.dart`, `firebase_auth_repository.dart`, main auth pages |

### settings (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Theme, locale, diagnostics, integration entry points |
| Routes | `/settings` |
| LOC | 1219 |
| Layers | `presentation/widgets/`, settings cubits, Hive-backed prefs |
| Tests | `test/features/settings/` |
| minimal_context | `settings.dart`, settings page + theme/locale sections |

### example (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Demo hub routing to many sample surfaces |
| Routes | `/example`, hub-linked demos |
| LOC | 2257 |
| Layers | `presentation/pages/`, `example_page_body_content.part.dart` |
| minimal_context | `example.dart`, hub page, route table in `app/router/` |

### chat (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Offline-first chat; FastAPI / HF / Supabase backends |
| Routes | `/chat`, `/chat-list` |
| LOC | 6384 |
| Layers | `domain/`, `data/*repository*`, `presentation/chat_*_cubit.dart` |
| Docs | [`docs/ai_integration.md`](../../docs/ai_integration.md), offline-first chat doc |
| minimal_context | `chat.dart`, `chat_repository` contract, primary cubit, one repository impl |

### todo_list (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Realtime DB + offline-first queue |
| Routes | `/todo-list` |
| LOC | 5166 |
| Layers | `offline_first_todo_repository*.dart`, `presentation/pages/todo_list_page_body.dart` |
| Docs | offline-first adoption guide |
| minimal_context | `todo_list.dart`, repository contract, offline_first impl part, page body |

### profile (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Offline-first profile cache |
| Routes | `/profile` |
| LOC | 1383 |
| minimal_context | `profile.dart`, cache repository, profile page |

### search (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Cache-first search |
| Routes | `/search` |
| LOC | 1088 |
| minimal_context | `search.dart`, offline_first_search_repository, search UI |

### case_study_demo (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Video wizard case study; Hive + optional Supabase |
| Routes | `/case-study-demo`, `/record`, `/history`, etc. |
| LOC | 3711 |
| Cross-deps | `camera_gallery`, `supabase_auth` domain |
| Docs | [`docs/case_studies/`](../../docs/case_studies/README.md) |
| minimal_context | session cubit, video repository contract, home page |

### chart (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Deferred chart demo; offline-first |
| Routes | `/charts` |
| LOC | 1991 |
| minimal_context | `chart.dart`, chart repository, chart page |

### graphql_demo (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Countries browser; cache-first GraphQL |
| Routes | `/graphql-demo` |
| LOC | 1850 |
| minimal_context | `graphql_demo.dart`, supabase graphql repository, demo page |

### iot_demo (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Device list/commands; Supabase when configured |
| Routes | `/iot-demo` |
| LOC | 3056 |
| minimal_context | `iot_demo.dart`, `iot_demo_cubit.dart`, supabase/persistent repos |

### staff_app_demo (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Firestore staff ops demo |
| Routes | `/staff-app-demo/*` |
| LOC | 4558 |
| Docs | [`docs/staff_app_demo_walkthrough.md`](../../docs/staff_app_demo_walkthrough.md) |
| minimal_context | session cubit, sites cubit, dashboard page |

### online_therapy_demo (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Booking/messaging/call simulation |
| Routes | `/online-therapy-demo/*` |
| LOC | 4578 |
| Docs | [`docs/online_therapy_demo/README.md`](../../docs/online_therapy_demo/README.md) |
| minimal_context | shell page, session cubit, fake API impl part |

### google_maps (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Deferred maps experience |
| Routes | `/google-maps` |
| LOC | 1425 |
| Docs | [`docs/google_maps_integration.md`](../../docs/google_maps_integration.md) |
| minimal_context | `google_maps.dart`, map cubit, map view widget |

### walletconnect_auth (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Wallet link demo on Firebase identity |
| Routes | `/walletconnect-auth` |
| LOC | 1413 |
| minimal_context | `walletconnect_auth.dart`, repository impl, auth page impl part |

### native_platform_showcase (`status: full`)

| Field | Value |
| --- | --- |
| Purpose | Platform capability catalog + live MethodChannel (Swift/Kotlin) and FFI (C/C++) interop demos |
| Routes | `/native-platform-showcase` (Example hub entry) |
| LOC | 2345 |
| Layers | `domain/` (ports + use case), `data/` (MethodChannel, FFI, mapper), `presentation/cubit/` |
| Key paths | `apps/mobile/lib/features/native_platform_showcase/native_platform_showcase.dart`, `presentation/pages/native_platform_showcase_page.dart` |
| Native | `ios/Runner/NativeShowcaseBridge.swift`, `macos/Runner/NativeShowcaseBridge.swift`, `android/.../MainActivity.kt`, `native/native_showcase/` |
| Tests | `test/features/native_platform_showcase/`, `integration_test/native_platform_showcase_flow_test.dart`, web smoke in `test/integration_preflight/web_bootstrap_smoke_test.dart` |
| Docs | [`apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md), brief [`docs/changes/2026-06-08_native_platform_showcase_feature_brief.md`](../../docs/changes/2026-06-08_native_platform_showcase_feature_brief.md) |
| minimal_context | `native_platform_showcase.dart`, `load_native_platform_showcase_use_case.dart`, `native_platform_info_repository_impl.dart`, method channel + FFI services, `native_platform_showcase_cubit.dart`, showcase page |

---

## Stub entries (`status: stub`)

One-line purpose only—expand when editing.

| Feature | Purpose |
| --- | --- |
| ai_decision_demo | Local decision workbench + SQLite cases |
| calculator | Calculator and payment summary |
| camera_gallery | Camera/gallery picker (dep of case study) |
| deeplink | Universal link handling |
| fcm_demo | FCM token/message demo |
| genui_demo | GenUI + Gemini generated UI |
| igaming_demo | Demo game lobby |
| in_app_purchase_demo | IAP flow demo |
| library_demo | Figma-inspired UI showcase |
| playlearn | Vocabulary / audio learning |
| realtime_market | Simulated market data |
| remote_config | Feature flags + diagnostics |
| scapes | Visual grid demo |
| supabase_auth | Optional Supabase auth flow |
| websocket | Reconnecting WebSocket demo |

---

## Regenerate LOC column

```bash
bash tool/modular_metrics.sh
```
