# Modularity

This document describes how the codebase stays modular: dependency direction, shared and core contracts, and where composition happens.

> **Related Documentation:**
>
> - [Clean Architecture](clean_architecture.md) - Layer responsibilities and dependency flow
> - [Architecture Details](architecture_details.md) - High-level architecture and diagrams
> - [Separation of Concerns](separation_of_concerns.md) - Responsibility boundaries
> - [Offline-First Architecture Case Study](engineering/offline_first_flutter_architecture_with_conflict_resolution.md) - Shared sync infrastructure and data-layer composition

## Allowed dependency shape

Use this as the shorthand:

- `apps/mobile/lib/app/` may compose features, core, and shared code
- `apps/mobile/lib/features/*/presentation/` may depend on its own feature `domain/` plus
  shared/core UI helpers
- `apps/mobile/lib/features/*/data/` may depend on its own feature `domain/`, shared/core
  infrastructure, and external SDKs
- `apps/mobile/lib/features/*/domain/` should remain pure Dart and feature-scoped
- `apps/mobile/lib/shared/` must not depend on `apps/mobile/lib/features/`

## Capability boundaries

When extracting reusable widgets, shared services, or cross-feature flows, pass
the smallest capability the caller needs:

- Prefer `VoidCallback`, typed callbacks, domain/core ports, or tiny interfaces
  over concrete cubits, repositories, pages, or feature view models.
- Keep capability interfaces named for behavior (`AuthTokenReader`,
  `ProfileCacheClearPort`, `NavigationTargetHandler`), not vague containers
  (`Helper`, `Manager`, `Utils`, `BaseThing`).
- Put a new port in `apps/mobile/lib/core/` only when app/router or multiple features need
  it; keep it feature-local when reuse is speculative.
- If repeated behavior appears across cubits/services, extract a focused mixin
  or service only after the shared lifecycle, error contract, and tests are the
  same.
- Reusable widgets accept state + capabilities; feature-specific policy stays
  in the owning cubit, route builder, or app composition layer.

## Dependency direction

- **`apps/mobile/lib/shared/` must never import `apps/mobile/lib/features/`.** Shared code is used by many features; it cannot depend on any single feature. If a helper (e.g. markdown parsing, design tokens) is needed by both shared and a feature, it lives in `apps/mobile/lib/shared/` and the feature imports from there.
- **Feature-to-feature imports are avoided.** Features do not depend on other features’ domain or presentation. When one screen needs another feature’s widget or data, composition is done in the **app layer** (router, app scope, or a page that receives dependencies via parameters).
- **`apps/mobile/lib/core/`** holds app-wide infrastructure. It may depend on feature types only at composition points (e.g. router building a feature page). Prefer interfaces in `core/` or `shared/` when multiple features or the app need a contract (e.g. auth, theme).
- **`apps/mobile/lib/app/` is the explicit composition layer.** It is allowed to import
  multiple features because that is where routes, auth redirects, app-scope
  providers, and screen composition are assembled.

## Core and shared contracts

### Auth (`apps/mobile/lib/core/auth/`)

- **`AuthUser`** – App-level model for “current user” (id, email, displayName, isAnonymous). Used by router, auth gates, and any code that needs “who is logged in” without depending on a specific auth implementation.
- **`AuthRepository`** – Read-only contract: `currentUser` and `authStateChanges`. Implementations (e.g. Firebase auth feature, Supabase auth feature) are registered in DI; app and router depend only on this core type.

The auth **feature** (`apps/mobile/lib/features/auth/`) extends the core contract (e.g. adds `signInAnonymously`, `signOut`) and re-exports `AuthUser` for backward compatibility. Router, redirect logic, and other features (e.g. supabase_auth, iot_demo) use `core/auth` only.

### Theme and design tokens (`apps/mobile/lib/shared/design_system/`)

- **EPOCH** – `EpochThemeExtension`, `EpochColors`, `EpochTextStyles`, and `EpochSpacing` live in `apps/mobile/lib/shared/design_system/epoch_theme_extension.dart`. Both library_demo and scapes import from shared; no feature owns the design system. The old `library_demo_theme.dart` re-exports from shared for compatibility.

### Shared utilities (`apps/mobile/lib/shared/utils/`)

- **Markdown parsing** – `MarkdownParser` and `MarkdownTableRenderer` live in `apps/mobile/lib/shared/utils/`. They are used by the markdown editor render object and by shared widgets such as `MessageBubble`. This avoids `shared/` depending on the example feature for generic markdown behavior.

### Settings-style section layout (`apps/mobile/lib/shared/widgets/`)

- **`SettingsSection`** – Title + spacing + child column used on the settings screen and on **remote_config** diagnostics. Living in `apps/mobile/lib/shared/widgets/settings_section.dart` keeps **`remote_config` from importing the `settings` feature** while preserving consistent layout.
- **QA cache diagnostics widgets** – `GraphqlCacheControlsSection` and `ProfileCacheControlsSection` live under `apps/mobile/lib/shared/widgets/diagnostics/` and depend only on **`apps/mobile/lib/core/diagnostics/`** ports (`GraphqlCacheClearPort`, `ProfileCacheControlsPort`). The **router** wires `getIt` implementations so the **settings** feature stays free of `graphql_demo`, `profile`, and `remote_config` imports. Feature adapters (e.g. `GraphqlCacheClearPortAdapter` in `apps/mobile/lib/features/graphql_demo/data/`) implement core ports and are registered in `register_graphql_services.dart` — same pattern as HF token and GenUI host-handle ports.
- **Remote config diagnostics DTO** – `RemoteConfigDiagnosticsViewData` + `RemoteConfigDiagnosticsStatus` live in `apps/mobile/lib/core/diagnostics/remote_config_diagnostics_view_data.dart`. The **remote_config** feature maps `RemoteConfigState` via `mapRemoteConfigStateToDiagnosticsViewData` (`apps/mobile/lib/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart`) so the cubit state type does not leak into core.

### Render orchestration HF token (`apps/mobile/lib/core/chat/`)

- **`RenderOrchestrationRemoteTokenPort`** – Narrow port in `apps/mobile/lib/core/chat/render_orchestration_remote_token_port.dart` exposing `readDevToken()` + `forceRefresh()`. The chat `LayeredRenderOrchestrationHfTokenProvider` depends only on this port, so **`chat` no longer imports `remote_config`**. The adapter lives in `apps/mobile/lib/features/remote_config/data/render_orchestration_remote_token_adapter.dart` and is wired in `apps/mobile/lib/core/di/register_remote_config_services.dart`. See [ports sweep](engineering/ports_adapters_modular_sweep_2026-05-12.md).

### Settings diagnostics decoupling (plan todos — **all complete**)

Canonical checklist with `[x]` markers: [settings_diagnostics_decouple_plan.md](plans/settings_diagnostics_decouple_plan.md).

- [x] GraphQL cache clear port — `apps/mobile/lib/core/diagnostics/graphql_cache_clear_port.dart`; DI in `register_graphql_services.dart`
- [x] Profile cache diagnostics port — `apps/mobile/lib/core/diagnostics/profile_cache_controls_port.dart`; DI in `register_profile_services.dart`
- [x] Cache section widgets (no `graphql_demo` / `profile` imports) — `apps/mobile/lib/shared/widgets/diagnostics/`
- [x] Remote config diagnostics DTO in core — `apps/mobile/lib/core/diagnostics/remote_config_diagnostics_view_data.dart`
- [x] Mapper in remote_config — `apps/mobile/lib/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart`
- [x] App composition — `apps/mobile/lib/app/router/routes_core.dart` → `SettingsPage.buildQaExtras`
- [x] Settings feature: zero imports of `graphql_demo` / `profile` / `remote_config` — `tool/check_feature_modularity_leaks.sh` + `rg` on `apps/mobile/lib/features/settings`

## Composition in the app layer

- **App shell** – `apps/mobile/lib/main_bootstrap.dart`, `apps/mobile/lib/core/bootstrap/`, `apps/mobile/lib/app.dart`,
  and `apps/mobile/lib/app/app_scope.dart` own startup, DI bootstrapping, router creation,
  and app-scope providers/listeners.
- **Counter + Remote Config** – The counter feature does not import remote_config. `CounterPageBody` always composes `CounterSyncBanner` for offline-first UX. The page also exposes an optional **banner slot** (`Widget? optionalBanner`) for app-level widgets; the **router** (`apps/mobile/lib/app/router/routes_core.dart`) passes `AwesomeFeatureWidget()` there. Counter stays agnostic; remote-config composition stays in the app.
- **Auth gates** – `AppRouteAuthGate` and feature-level gates (e.g. `IotDemoAuthGate`) take `getCurrentUser` and `authStateChanges` (or an auth repository) as parameters. The router supplies these from DI. Gates depend on the core `AuthUser` type only.

## Feature barrel (`apps/mobile/lib/features/features.dart`)

- A single barrel file re-exports public entry points for features that are used by the app or other composition points.
- It includes: auth, calculator, camera_gallery, chart, chat, counter, deeplink, example, fcm_demo, genui_demo, google_maps, graphql_demo, iot_demo, library_demo (page), playlearn, profile, remote_config, scapes, settings, supabase_auth, todo_list, websocket.
- Use this for a quick import of a feature’s public API when you are in app/router or tests; within a feature, prefer direct imports to the files you need.

## Validation

- **Read-only metrics:** `bash tool/modular_metrics.sh` (stdout). Use
  `bash tool/modular_metrics.sh --cross-feature-only` for a classified list of
  `apps/mobile/lib/features/<A>/` files importing `package:flutter_bloc_app/features/<B>/`
  (Phase 1B inventory before any default-deny CI gate).
- **No shared → feature imports:** enforced by `tool/check_feature_modularity_leaks.sh`
  (fails on `package:flutter_bloc_app/features/` under `apps/mobile/lib/shared/`). Composition
  must inject feature behavior via DI callbacks from `apps/mobile/lib/core/di/` (see
  `AppMemoryService.onChartMemoryTrim`).
- **Domain purity (imports):** same script fails on `^import` lines in
  `apps/mobile/lib/features/*/domain/**` that pull in Flutter, `get_it`, Hive, Supabase client
  libs, Dio, Retrofit, `package:flutter_bloc_app/app/`, `package:flutter_bloc_app/core/di/`,
  or another feature’s `presentation/` / `data/` paths. Domain remains pure Dart;
  Flutter-only domain checks also run via `tool/check_flutter_domain_imports.sh`.
- **Known pairwise feature boundaries:** declarative rules in
  `tool/check_feature_modularity_leaks.sh` (e.g. `library_demo` ↔ `scapes`,
  `settings` ↔ `graphql_demo` / `profile` / `remote_config`, `remote_config` ↔
  `settings`). Extend the script when new rules land here.
- **Full sweep:** `./bin/checklist` runs `tool/check_feature_modularity_leaks.sh`
  (see [validation_scripts.md](validation_scripts.md)).
- **Router/feature tests:** Run `./bin/router_feature_validate` after changing routes or DI.
- When adding a new cross-cutting concept (e.g. “current user”), consider a **core** or **shared** contract so that app and features depend on the contract, not on a single feature’s implementation.

### Phase 1B — feature-to-feature imports

Cross-feature `package:` imports are **reported** via `modular_metrics.sh`, not
failed by default, until each hit is classified (move to `apps/mobile/lib/app/`, `apps/mobile/lib/shared/`,
`apps/mobile/lib/core/` port, or an explicit time-boxed exception documented in this file).

**Exception register** (regenerate pairs with `bash tool/modular_metrics.sh --cross-feature-only`; update this table when imports change):

| From → To | Representative files | Classification | Owner | Expiry / removal |
| --- | --- | --- | --- | --- |
| `case_study_demo` → `camera_gallery` | `case_study_image_picker_video_repository.dart`, `case_study_video_repository.dart`, `case_study_l10n_helpers.dart`, `case_study_session_cubit.dart` | Temporary — shared camera result/error types should move to `apps/mobile/lib/shared/` or a thin `core/` contract so the demo does not depend on another feature’s domain | Maintainers | Remove when camera gallery exports are replaced by a shared or core type, or case study owns equivalent DTOs |
| `case_study_demo` → `supabase_auth` | `case_study_session_cubit.dart`, `case_study_demo_home_page.dart`, `case_study_history_*.dart`, `case_study_data_mode_badge.dart` | Temporary — presentation pulls `SupabaseAuthRepository`; prefer app/DI passing an interface or core auth read model | Maintainers | Remove when cubit/pages receive auth via constructor/DI without importing `supabase_auth` |

## Phase 3 follow-ups (stronger seams)

- **App-layer deep imports:** `bash tool/check_feature_barrel_exports.sh` (report-only,
  exit 0) lists `apps/mobile/lib/app/**` imports into feature `presentation/` / `data/` /
  `domain/`. Use when shrinking imports toward per-feature barrels.
- **Ports sweep:** [`engineering/ports_adapters_modular_sweep_2026-05-12.md`](engineering/ports_adapters_modular_sweep_2026-05-12.md).
- **Scoped DI spike:** [`plans/feature_scoped_di_feasibility.md`](plans/feature_scoped_di_feasibility.md).
- **Package split:** [`plans/melos_package_split_feasibility.md`](plans/melos_package_split_feasibility.md).

## Out of scope (by design)

- **Multiple packages** – The app remains a single package with clear boundaries; splitting into multiple packages is not required for modularity.
- **Feature-scoped DI (get_it_modular)** – Scoped dependency injection (e.g. per-route modules) is not in use; the current `get_it` setup is global. If a future package (e.g. get_it_modular) becomes compatible with the project’s get_it version, feature-scoped registration could be adopted for features that should dispose when the user leaves the flow.
