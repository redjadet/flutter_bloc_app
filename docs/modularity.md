# Modularity

This document describes how the codebase stays modular: dependency direction, shared and core contracts, and where composition happens.

> **Related Documentation:**
>
> - [Clean Architecture](clean_architecture.md) - Layer responsibilities and dependency flow
> - [Architecture Details](architecture_details.md) - High-level architecture and diagrams
> - [Separation of Concerns](separation_of_concerns.md) - Responsibility boundaries

## Dependency direction

- **`lib/shared/` must never import `lib/features/`.** Shared code is used by many features; it cannot depend on any single feature. If a helper (e.g. markdown parsing, design tokens) is needed by both shared and a feature, it lives in `lib/shared/` and the feature imports from there.
- **Feature-to-feature imports are avoided.** Features do not depend on other features’ domain or presentation. When one screen needs another feature’s widget or data, composition is done in the **app layer** (router, app scope, or a page that receives dependencies via parameters).
- **`lib/core/`** holds app-wide infrastructure. It may depend on feature types only at composition points (e.g. router building a feature page). Prefer interfaces in `core/` or `shared/` when multiple features or the app need a contract (e.g. auth, theme).

## Core and shared contracts

### Auth (`lib/core/auth/`)

- **`AuthUser`** – App-level model for “current user” (id, email, displayName, isAnonymous). Used by router, auth gates, and any code that needs “who is logged in” without depending on a specific auth implementation.
- **`AuthRepository`** – Read-only contract: `currentUser` and `authStateChanges`. Implementations (e.g. Firebase auth feature, Supabase auth feature) are registered in DI; app and router depend only on this core type.

The auth **feature** (`lib/features/auth/`) extends the core contract (e.g. adds `signInAnonymously`, `signOut`) and re-exports `AuthUser` for backward compatibility. Router, redirect logic, and other features (e.g. supabase_auth, iot_demo) use `core/auth` only.

### Theme and design tokens (`lib/shared/design_system/`)

- **EPOCH** – `EpochThemeExtension`, `EpochColors`, `EpochTextStyles`, and `EpochSpacing` live in `lib/shared/design_system/epoch_theme_extension.dart`. Both library_demo and scapes import from shared; no feature owns the design system. The old `library_demo_theme.dart` re-exports from shared for compatibility.

### Shared utilities (`lib/shared/utils/`)

- **Markdown parsing** – `MarkdownParser` and `MarkdownTableRenderer` live in `lib/shared/utils/`. They are used by the markdown editor render object and by shared widgets such as `MessageBubble`. This avoids `shared/` depending on the example feature for generic markdown behavior.

### Settings-style section layout (`lib/shared/widgets/`)

- **`SettingsSection`** – Title + spacing + child column used on the settings screen and on **remote_config** diagnostics. Living in `lib/shared/widgets/settings_section.dart` keeps **`remote_config` from importing the `settings` feature** while preserving consistent layout.
- **QA cache diagnostics widgets** – `GraphqlCacheControlsSection` and `ProfileCacheControlsSection` live under `lib/shared/widgets/diagnostics/` and depend only on **`lib/core/diagnostics/`** ports (`GraphqlCacheClearPort`, `ProfileCacheControlsPort`). The **router** wires `getIt` implementations so the **settings** feature stays free of `graphql_demo`, `profile`, and `remote_config` imports.
- **Remote config diagnostics DTO** – `RemoteConfigDiagnosticsViewData` + `RemoteConfigDiagnosticsStatus` live in `lib/core/diagnostics/remote_config_diagnostics_view_data.dart`. The **remote_config** feature maps `RemoteConfigState` via `mapRemoteConfigStateToDiagnosticsViewData` (`lib/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart`) so the cubit state type does not leak into core.

### Settings diagnostics decoupling (plan todos — **all complete**)

Canonical checklist with `[x]` markers: [settings_diagnostics_decouple_plan.md](plans/settings_diagnostics_decouple_plan.md).

- [x] GraphQL cache clear port — `lib/core/diagnostics/graphql_cache_clear_port.dart`; DI in `register_graphql_services.dart`
- [x] Profile cache diagnostics port — `lib/core/diagnostics/profile_cache_controls_port.dart`; DI in `register_profile_services.dart`
- [x] Cache section widgets (no `graphql_demo` / `profile` imports) — `lib/shared/widgets/diagnostics/`
- [x] Remote config diagnostics DTO in core — `lib/core/diagnostics/remote_config_diagnostics_view_data.dart`
- [x] Mapper in remote_config — `lib/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart`
- [x] App composition — `lib/app/router/routes_core.dart` → `SettingsPage.buildQaExtras`
- [x] Settings feature: zero imports of `graphql_demo` / `profile` / `remote_config` — `tool/check_feature_modularity_leaks.sh` + `rg` on `lib/features/settings`

## Composition in the app layer

- **Counter + Remote Config** – The counter feature does not import remote_config. The counter page exposes an optional **banner slot** (`Widget? optionalBanner`). The **router** (`lib/app/router/routes_core.dart`) builds `CounterPage` and passes `AwesomeFeatureWidget()` as the banner. Counter stays agnostic; composition is in the app.
- **Auth gates** – `AppRouteAuthGate` and feature-level gates (e.g. `IotDemoAuthGate`) take `getCurrentUser` and `authStateChanges` (or an auth repository) as parameters. The router supplies these from DI. Gates depend on the core `AuthUser` type only.

## Feature barrel (`lib/features/features.dart`)

- A single barrel file re-exports public entry points for features that are used by the app or other composition points.
- It includes: auth, calculator, camera_gallery, chart, chat, counter, deeplink, example, fcm_demo, genui_demo, google_maps, graphql_demo, iot_demo, library_demo (page), playlearn, profile, remote_config, scapes, settings, supabase_auth, todo_list, websocket.
- Use this for a quick import of a feature’s public API when you are in app/router or tests; within a feature, prefer direct imports to the files you need.

## Validation

- **No shared → feature imports:** `grep -r "import.*features/" lib/shared` should find no matches.
- **Known feature-boundary leaks:** `./bin/checklist` runs `tool/check_feature_modularity_leaks.sh` (see [validation_scripts.md](validation_scripts.md)). Extend that script when you add new cross-feature rules.
- **Router/feature tests:** Run `./bin/router_feature_validate` after changing routes or DI.
- When adding a new cross-cutting concept (e.g. “current user”), consider a **core** or **shared** contract so that app and features depend on the contract, not on a single feature’s implementation.

## Out of scope (by design)

- **Multiple packages** – The app remains a single package with clear boundaries; splitting into multiple packages is not required for modularity.
- **Feature-scoped DI (get_it_modular)** – Scoped dependency injection (e.g. per-route modules) is not in use; the current `get_it` setup is global. If a future package (e.g. get_it_modular) becomes compatible with the project’s get_it version, feature-scoped registration could be adopted for features that should dispose when the user leaves the flow.
