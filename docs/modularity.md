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

- `apps/mobile/lib/app/` may compose features and workspace packages (`packages/*`)
- `apps/mobile/lib/features/*/presentation/` may depend on its own feature `domain/` plus
  package-owned UI helpers (`packages/design_system`, `packages/app_shared_flutter`)
- `apps/mobile/lib/features/*/data/` may depend on its own feature `domain/`, package-owned
  infrastructure (`packages/storage`, `packages/networking`, `packages/auth`), and external SDKs
- `apps/mobile/lib/features/*/domain/` should remain pure Dart and feature-scoped
- Workspace packages must not depend on `apps/mobile` or `package:flutter_bloc_app`

## Capability boundaries

When extracting reusable widgets, shared services, or cross-feature flows, pass
the smallest capability the caller needs:

- Prefer `VoidCallback`, typed callbacks, domain/core ports, or tiny interfaces
  over concrete cubits, repositories, pages, or feature view models.
- Keep capability interfaces named for behavior (`AuthTokenReader`,
  `ProfileCacheClearPort`, `NavigationTargetHandler`), not vague containers
  (`Helper`, `Manager`, `Utils`, `BaseThing`).
- Put a new port in a workspace package (often `packages/core`, `packages/utilities`, or a
  domain package like `packages/auth`) only when app/router or multiple features need it;
  keep it feature-local when reuse is speculative.
- If repeated behavior appears across cubits/services, extract a focused mixin
  or service only after the shared lifecycle, error contract, and tests are the
  same.
- Reusable widgets accept state + capabilities; feature-specific policy stays
  in the owning cubit, route builder, or app composition layer.

## Dependency direction

- **Packages must never import `apps/mobile` or `package:flutter_bloc_app`.** Package code is used by many features; it cannot depend on any single app feature. If a helper (e.g. markdown parsing, design tokens) is needed by both multiple features, it lives in a package (often `packages/design_system` or `packages/utilities`) and features import from there.
- **Feature-to-feature imports are avoided.** Features do not depend on other features’ domain or presentation. When one screen needs another feature’s widget or data, composition is done in the **app layer** (router, app scope, or a page that receives dependencies via parameters).
- **`apps/mobile/lib/app/`** holds runnable app composition (DI/router/bootstrap). It may depend on feature types only at composition points (e.g. router building a feature page). Prefer interfaces in packages when multiple features or the app need a contract (e.g. auth, theme, diagnostics ports).
- **`apps/mobile/lib/app/` is the explicit composition layer.** It is allowed to import
  multiple features because that is where routes, auth redirects, app-scope
  providers, and screen composition are assembled.

## Core and shared contracts

### Auth (`packages/auth` + app shell adapters)

- **`package:auth`** — Pure-Dart contracts: `AuthUser`, base `AuthRepository` (`currentUser`, `authStateChanges`), `AuthProviderKind`, `SessionInvalidationReason`, `RemoteBackendAuthPort`. Router, gates, and cross-feature code import these types from `package:auth/auth.dart`.
- **App shell** — App session infrastructure and SDK glue: `apps/mobile/lib/app/auth/**` and DI wiring under `apps/mobile/lib/app/composition/**`.
- **`apps/mobile/lib/features/auth/domain/`** — Feature `AuthRepository` extends the package contract with `signInAnonymously` / `signOut`; Firebase/Supabase implementations live under `features/auth/data/`. DI registers the feature repository and aliases `core_auth.AuthRepository` to the same singleton (`apps/mobile/lib/app/composition/features/register_auth_services.dart`).

### Theme and design tokens (`packages/design_system`)

- **EPOCH** – `EpochThemeExtension`, `EpochColors`, `EpochTextStyles`, and `EpochSpacing` live in `packages/design_system`. Features import from `package:design_system/design_system.dart`.

### Shared utilities (`packages/utilities` + `packages/app_shared_flutter`)

- **Markdown parsing** – `MarkdownParser` and `MarkdownTableRenderer` live in `packages/design_system`. This avoids feature-to-feature coupling for generic markdown behavior.

### Settings-style section layout (`packages/design_system`)

- **`SettingsSection`** – Title + spacing + child column used on the settings screen and on **remote_config** diagnostics. Living in `packages/design_system` keeps **`remote_config` from importing the `settings` feature** while preserving consistent layout.
- **QA cache diagnostics widgets** – `GraphqlCacheControlsSection` and `ProfileCacheControlsSection` live under `apps/mobile/lib/app/widgets/diagnostics/**` (app-wired) and depend on diagnostics ports in packages (see `packages/utilities` ports and app adapters) so the **settings** feature stays free of `graphql_demo`, `profile`, and `remote_config` imports.
- **Remote config diagnostics DTO** – `RemoteConfigDiagnosticsViewData` + `RemoteConfigDiagnosticsStatus` live in a package-owned diagnostics port module (see `packages/utilities` ports). The **remote_config** feature maps `RemoteConfigState` via `mapRemoteConfigStateToDiagnosticsViewData` (`apps/mobile/lib/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart`) so the cubit state type does not leak into app composition.

### Render orchestration HF token (`packages/utilities` ports)

- **`RenderOrchestrationRemoteTokenPort`** – Narrow port in `packages/utilities` exposing `readDevToken()` + `forceRefresh()`. The chat token provider depends only on this port, so **`chat` does not import `remote_config`**. The adapter lives in `apps/mobile/lib/features/remote_config/data/render_orchestration_remote_token_adapter.dart` and is wired in app composition. See [ports sweep](engineering/ports_adapters_modular_sweep_2026-05-12.md).

### Settings diagnostics decoupling (plan todos — **all complete**)

Canonical checklist with `[x]` markers: [settings_diagnostics_decouple_plan.md](plans/settings_diagnostics_decouple_plan.md).

- [x] GraphQL cache clear port — package-owned diagnostics port + app adapter; DI in `apps/mobile/lib/app/composition/features/register_graphql_services.dart`
- [x] Profile cache diagnostics port — package-owned diagnostics port + app adapter; DI in `apps/mobile/lib/app/composition/features/register_profile_services.dart`
- [x] Cache section widgets (no `graphql_demo` / `profile` imports) — app-owned diagnostics widgets under `apps/mobile/lib/app/widgets/diagnostics/`
- [x] Remote config diagnostics DTO — package-owned, mapped from feature state
- [x] Mapper in remote_config — `apps/mobile/lib/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart`
- [x] App composition — `apps/mobile/lib/app/router/routes_core.dart` → `SettingsPage.buildQaExtras`
- [x] Settings feature: zero imports of `graphql_demo` / `profile` / `remote_config` — `tool/check_feature_modularity_leaks.sh` + `rg` on `apps/mobile/lib/features/settings`

## Composition in the app layer

- **App shell** – `apps/mobile/lib/main_bootstrap.dart`, `apps/mobile/lib/app/bootstrap/**`, `apps/mobile/lib/app.dart`,
  and `apps/mobile/lib/app/app_scope.dart` own startup, DI bootstrapping, router creation,
  and app-scope providers/listeners.
- **Counter + Remote Config** – The counter feature does not import remote_config. `CounterPageBody` always composes `CounterSyncBanner` for offline-first UX. The page also exposes an optional **banner slot** (`Widget? optionalBanner`) for app-level widgets; the **router** (`apps/mobile/lib/app/router/routes_core.dart`) passes `AwesomeFeatureWidget()` there. Counter stays agnostic; remote-config composition stays in the app.
- **Auth gates** – `AppRouteAuthGate` and feature-level gates (e.g. `IotDemoAuthGate`) take `getCurrentUser` and `authStateChanges` (or an auth repository) as parameters. The router supplies these from DI. Gates depend on `package:auth` `AuthUser` only.

## Feature barrel (`apps/mobile/lib/features/features.dart`)

- A single barrel file re-exports public entry points for features that are used by the app or other composition points.
- It re-exports every feature barrel under `apps/mobile/lib/features/<name>/` (alphabetical in `features.dart`), including demos such as `ai_decision_demo`, `case_study_demo`, `igaming_demo`, `in_app_purchase_demo`, `online_therapy_demo`, `staff_app_demo`, and `walletconnect_auth`. `library_demo` still exports its page entry directly.
- Use this for a quick import of a feature’s public API when you are in app/router or tests; within a feature, prefer direct imports to the files you need.

## Validation

- **Read-only metrics:** `bash tool/modular_metrics.sh` (stdout). Use
  `bash tool/modular_metrics.sh --cross-feature-only` for a classified list of
  `apps/mobile/lib/features/<A>/` files importing `package:flutter_bloc_app/features/<B>/`
  (Phase 1B inventory before any default-deny CI gate).
- **No package → app imports:** enforced by `tool/check_feature_modularity_leaks.sh` and
  `tool/check_package_dependency_dag.sh`. Composition must inject feature behavior via DI
  callbacks from `apps/mobile/lib/app/composition/**` (see `AppMemoryService.onChartMemoryTrim`).
- **Domain purity (imports):** same script fails on `^import` lines in
  `apps/mobile/lib/features/*/domain/**` that pull in Flutter, `get_it`, Hive, Supabase client
  libs, Dio, Retrofit, `package:flutter_bloc_app/app/`, `package:flutter_bloc_app/app/composition/`,
  or another feature’s `presentation/` / `data/` paths. Domain remains pure Dart;
  Flutter-only domain checks also run via `tool/check_flutter_domain_imports.sh`.
- **Known pairwise feature boundaries:** declarative rules in
  `tool/check_feature_modularity_leaks.sh` (e.g. `library_demo` ↔ `scapes`,
  `settings` ↔ `graphql_demo` / `profile` / `remote_config`, `remote_config` ↔
  `settings`). Extend the script when new rules land here.
- **Full sweep:** `./bin/checklist` runs `tool/check_feature_modularity_leaks.sh`
  (see [validation_scripts.md](validation_scripts.md)).
- **Router/feature tests:** Run `./bin/router_feature_validate` after changing routes or DI.
- When adding a new cross-cutting concept (e.g. “current user”), consider a **package-owned** contract so that app and features depend on the contract, not on a single feature’s implementation.

### Phase 1B — feature-to-feature imports

Cross-feature `package:` imports are **reported** via `modular_metrics.sh`, not
failed by default, until each hit is classified (move to `apps/mobile/lib/app/`, a package-owned port,
or an explicit time-boxed exception documented in this file).

**Exception register** (regenerate pairs with `bash tool/modular_metrics.sh --cross-feature-only`; update this table when imports change). Current status: no reported cross-feature imports.

| From → To | Representative files | Classification | Owner | Expiry / removal |
| --- | --- | --- | --- | --- |
| None | `bash tool/modular_metrics.sh --cross-feature-only` reports no rows | Clean | Maintainers | Recheck after feature import changes |

## Phase 3 follow-ups (stronger seams)

- **App-layer deep imports:** `bash tool/check_feature_barrel_exports.sh` (report-only,
  exit 0) lists `apps/mobile/lib/app/**` imports into feature `presentation/` / `data/` /
  `domain/`. Use when shrinking imports toward per-feature barrels.
- **Ports sweep:** [`engineering/ports_adapters_modular_sweep_2026-05-12.md`](engineering/ports_adapters_modular_sweep_2026-05-12.md).
- **Scoped DI spike:** [`plans/feature_scoped_di_feasibility.md`](plans/feature_scoped_di_feasibility.md).
- **Package split:** [`plans/melos_package_split_feasibility.md`](plans/melos_package_split_feasibility.md).

## Out of scope (by design)

- **More package splitting** – The workspace already uses focused packages for shared ownership. Further package splits are optional and should be justified by a concrete reuse, validation, or dependency-boundary need.
- **Feature-scoped DI (get_it_modular)** – Scoped dependency injection (e.g. per-route modules) is not in use; the current `get_it` setup is global. If a future package (e.g. get_it_modular) becomes compatible with the project’s get_it version, feature-scoped registration could be adopted for features that should dispose when the user leaves the flow.
