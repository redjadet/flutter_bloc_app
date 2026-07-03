# Melos Monorepo Migration Plan

Date: 2026-07-03
Branch: `codex/melos-monorepo-plan`
Worktree: `../flutter_bloc_app_melos_plan`

## Goal

Migrate `flutter_bloc_app` from a single Flutter application package into an
incremental Melos-managed monorepo without changing user-visible behavior.
The target state supports mobile, web, desktop, backend services, reusable
Flutter/Dart packages, and future AI-native features.

This is a migration plan, not a big-bang rewrite. File moves should happen only
after package seams are proven by tests and repository guards.

## Build-Ready Critique

The first draft was directionally correct but not ready to execute. It had these
gaps:

- It described a target architecture but did not name the first implementation
  PRs.
- It mixed long-term package ideas with immediate build steps, which could push
  implementation toward unnecessary packages.
- It did not include a hard "do not touch" list for the first build phase.
- It proposed Melos configuration with `usePubspecOverrides`, which current
  Melos has removed.
- It did not require `resolution: workspace` in workspace package pubspecs.
- It did not specify exact script path rewrites after moving the app.
- It did not identify first canary tests before moving thousands of imports.
- It did not define stop criteria for each phase beyond generic validation.
- It did not say how to preserve the existing package name during the app move.
- It did not separate "workspace shell", "app relocation", and "package
  extraction" into independently reviewable PRs.
- It did not define `WORKSPACE_ROOT` vs `APP_ROOT` for 50+ path-sensitive scripts.
- It mixed auth extraction into PR-G while labeling PR-G as AI-only.
- It referenced `melos.yaml` though Melos 7 configures via root `pubspec.yaml`.

This revision fixes those gaps by adding an execution contract, explicit
phase write-sets, stop criteria, acceptance gates, and deferrals.

## Start Here (Implementation Kickoff)

Use this section as the first working session checklist. Do not start PR-A
until Phase 0 passes on a clean implementation worktree.

1. Create the build worktree from current `main` (not from the plan-only branch):

```bash
git fetch origin
git worktree add ../flutter_bloc_app_melos_build -b codex/melos-monorepo-build origin/main
cd ../flutter_bloc_app_melos_build
```

1. Run Phase 0 baseline commands (record outputs under `docs/plans/`).
2. Open PR-A only. Scope = workspace shell; zero `lib/**` moves.
3. Merge PR-A before starting PR-B. PR-B is the highest-risk PR — budget a
   dedicated review for path-root refactors.
4. Track progress in `tasks/cursor/todo.md` or `tasks/codex/todo.md` using the
   Build Todo checkboxes below.

**Authoritative gates (unchanged until explicitly migrated):**

| Gate | When | Command |
| --- | --- | --- |
| Full delivery | Every implementation PR | `./bin/checklist` |
| Fast docs/tooling | Plan-only or tooling edits | `./bin/checklist-fast --no-reuse` |
| Melos parity (non-blocking until PR-A lands) | After PR-A | `dart run melos bootstrap` then `dart run melos run analyze:flutter` |

**Melos 7 note:** Configuration lives in the root `pubspec.yaml` `melos:` section.
Do not add a standalone `melos.yaml` file.

## Why Migrate Now

[`melos_package_split_feasibility.md`](melos_package_split_feasibility.md) (2026-05-12)
recommended staying single-package until a second consumer exists. This plan
proceeds because the repo now meets multiple trigger conditions from that doc:

- A second app surface (`apps/admin`, dedicated web shell) is on the roadmap even
  if not immediate.
- Script-based boundary enforcement (`tool/check_*.sh`, `tool/modular_metrics.sh`)
  is noisy at 34 features / 1366 `lib` files.
- AI-native work needs a provider-neutral contract home (`packages/ai`) without
  pulling GenUI/provider SDKs into every compile graph.
- Workspace tooling (Melos + Pub workspaces) reduces future extraction cost even
  while features remain app-owned.

The migration still follows the feasibility doc's conservative rule: **no feature
packages until reuse is proven**; workspace shell and infrastructure packages only.

## Execution Contract

Build approach:

- Make one implementation PR per phase.
- Keep `flutter_bloc_app` as the app package name through Phase 2 to avoid
  import churn.
- Move files with `git mv` during implementation so history remains readable.
- Keep app behavior unchanged until a package extraction phase explicitly moves
  code.
- Keep `./bin/checklist` as the release gate until Melos parity is proven.
- Add Melos commands as wrappers first, not replacements.
- Update docs and scripts in the same phase as path changes.

Hard deferrals until after Phase 2:

- No feature package extraction.
- No `apps/web`, `apps/desktop`, or `apps/admin`.
- No auth provider redesign.
- No state management migration away from Cubit/BLoC.
- No router rewrite.
- No Firebase backend move.
- No package renaming from `flutter_bloc_app`.
- No dependency major upgrades except Melos itself.

Build branch recommendation:

```bash
git worktree add ../flutter_bloc_app_melos_build -b codex/melos-monorepo-build
cd ../flutter_bloc_app_melos_build
```

Phase order:

1. PR-A: Workspace shell only.
2. PR-B: Move app to `apps/mobile`.
3. PR-C: Extract `packages/utilities`.
4. PR-D: Extract `packages/core`.
5. PR-E: Extract `packages/design_system` foundation.
6. PR-F: Extract `packages/networking` and `packages/storage`.
7. PR-G: Add `packages/ai` contracts only.
8. PR-H: Move Firebase backend layout.
9. PR-I (optional wave 2): Extract `packages/auth`, `packages/feature_flags`, and
   sync presentation split — only after PR-F stabilizes Hive/HTTP seams.

Stop the migration after any phase if `./bin/checklist` fails for a reason not
directly owned by the phase, or if Melos and existing repo gates disagree on
package resolution.

### Path Root Contract (required from PR-B onward)

Introduce `tool/workspace_paths.sh` in PR-B as the single source of truth:

```bash
# tool/workspace_paths.sh (sourced by bin/* and tool/* that run Flutter commands)
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_ROOT="${APP_ROOT:-$WORKSPACE_ROOT/apps/mobile}"
# Before PR-B: APP_ROOT defaults to WORKSPACE_ROOT when apps/mobile is absent.
if [[ ! -f "$APP_ROOT/pubspec.yaml" ]]; then
  APP_ROOT="$WORKSPACE_ROOT"
fi
export WORKSPACE_ROOT APP_ROOT
```

Rules:

- `WORKSPACE_ROOT` = repository root (`bin/`, `tool/`, `docs/`, workspace `pubspec.yaml`).
- `APP_ROOT` = Flutter application package (`pubspec.yaml` with `flutter:` SDK dep).
- `./bin/checklist` stays invokable from `WORKSPACE_ROOT`; it must `source
  tool/workspace_paths.sh` and run `flutter pub get`, `flutter analyze`, and
  `tool/test_coverage.sh` from `APP_ROOT` after PR-B.
- Validation scripts under `tool/check_*.sh` that scan `lib/**` must accept
  `--app-root "$APP_ROOT"` or source `workspace_paths.sh` and use `"$APP_ROOT/lib"`.
- Do not duplicate path logic in individual scripts after `workspace_paths.sh` lands.

### Package Dependency DAG (enforce in every extraction PR)

Allowed dependency direction (higher may depend on lower; never reverse):

```text
apps/mobile
  → packages/design_system, networking, storage, auth, ai, feature_flags, shared_blocs, analytics
  → packages/core, utilities
packages/design_system → packages/core, utilities
packages/networking → packages/core, utilities
packages/storage → packages/core, utilities
packages/auth → packages/core, utilities
packages/ai → packages/core, utilities
packages/feature_flags → packages/core, utilities
packages/shared_blocs → packages/core, design_system (only if truly shared UI state)
packages/core → packages/utilities
packages/utilities → (none)
custom_lints/* → (none; workspace members only)
```

Add `tool/check_package_dependency_dag.sh` in PR-C if manual review becomes error-prone.
Until then, verify with `dart pub deps` per new package before merging.

## Build Todo

Use this as the implementation checklist.

- [ ] Create implementation worktree `../flutter_bloc_app_melos_build`.
- [ ] Run Phase 0 baseline commands and save dependency baseline.
- [ ] PR-A: add Melos/Pub workspace shell with root app still in place.
- [ ] PR-A: prove `dart run melos bootstrap` and `./bin/checklist`.
- [ ] PR-B: move app to `apps/mobile` with package name still
  `flutter_bloc_app`.
- [ ] PR-B: update scripts/CI paths and prove app route/counter canaries.
- [ ] PR-C: extract pure `packages/utilities`.
- [ ] PR-D: extract pure `packages/core`.
- [ ] PR-E: extract `packages/design_system` foundation.
- [ ] PR-F: extract `packages/networking` then `packages/storage`.
- [ ] PR-G: add provider-neutral `packages/ai` contracts.
- [ ] PR-H: move Firebase backend assets after app workspace stabilizes.
- [ ] PR-I (optional): extract `packages/auth`, `packages/feature_flags`, sync split.
- [ ] Defer extra apps until product split is real.

## Documentation Updates

Update these docs in the same PR as the relevant code change:

- [ ] [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md): Melos command
  routing and which gate remains authoritative.
- [ ] [`agents_quick_reference.md`](../agents_quick_reference.md): workspace root vs app root commands.
- [ ] [`agent_environment_setup.md`](../agent_environment_setup.md): Melos bootstrap and Pub workspace
  setup.
- [ ] [`feature_implementation_guide.md`](../feature_implementation_guide.md): feature location remains
  `apps/mobile/lib/features` until explicit extraction.
- [ ] [`clean_architecture.md`](../clean_architecture.md): package dependency direction after
  extraction.
- [ ] [`design_system.md`](../design_system.md): design system package ownership and forbidden
  imports.
- [ ] [`firebase_setup.md`](../firebase_setup.md): backend paths after PR-H only.
- [ ] [`deployment.md`](../deployment.md): app/backend CI command changes.
- [ ] `docs/changes/<date>_melos_monorepo_migration.md`: phase closeout note.

## Review Basis

This plan reviewed the live repository shape:

- Single root Flutter app package in `pubspec.yaml`.
- 34 feature folders under `lib/features`.
- 1366 Dart files under `lib`.
- 473 unit/widget test files and 30 integration test files.
- Existing app shell in `lib/app`.
- Existing reusable support code in `lib/core` and `lib/shared`.
- Existing Firebase Functions under `functions`.
- Existing Firebase rules at root: `firestore.rules`, `storage.rules`,
  `firestore.indexes.json`.
- Firebase deploy config template: `firebase.json.example` (committed);
  `firebase.json` is gitignored locally per [`firebase_setup.md`](../firebase_setup.md).
- Existing custom lint packages under `custom_lints`.
- Existing CI in `.github/workflows/ci.yml`.
- Existing validation entrypoints: `./bin/checklist`, `./bin/checklist-fast`,
  `./bin/integration_preflight`, and many `tool/check_*.sh` guards.

External guidance checked:

- Flutter architecture guide: structure apps for scale, testability, and
  maintainability while adapting recommendations to project needs.
- Flutter package docs: packages are the supported unit for modular reusable
  Dart and Flutter code.
- Melos docs: modern workspaces require root workspace configuration and
  bootstrap links local packages and runs dependency resolution.

## Current Architecture Review

### Structure

Current repo is a single Flutter package with:

```text
lib/
  app/                 # app shell, router, app-scope cubits
  core/                # bootstrap, DI, auth contracts, config, theme
  shared/              # widgets, storage, sync, http, utils, design helpers
  features/            # feature-first clean architecture slices
  l10n/                # generated and source localization files
functions/             # Firebase Cloud Functions TypeScript project
custom_lints/          # local analyzer plugin packages
tool/, bin/            # repo validation, release, agent, and migration scripts
android/, ios/, macos/, linux/, windows/, web/
```

This is already feature-first. Existing docs define `Presentation -> Domain <-
Data`, Cubit/BLoC as presentation ViewModel, and `lib/app` as composition shell.
The monorepo should preserve those rules.

### Dependencies

Root `pubspec.yaml` currently mixes app, platform, backend, UI, AI, storage,
test, and codegen dependencies in one graph. Important groups:

- App shell and state: `flutter_bloc`, `go_router`, `get_it`, `provider`.
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`,
  `firebase_storage`, `firebase_remote_config`, `firebase_messaging`,
  `firebase_analytics`, `firebase_crashlytics`, `cloud_functions`,
  `firebase_ui_auth`, App Check.
- Supabase: `supabase_flutter`.
- Networking: `dio`, `retrofit`, `web_socket_channel`.
- Storage: `hive`, `hive_flutter`, `shared_preferences`,
  `flutter_secure_storage`.
- UI/design: `mix`, `google_fonts`, `responsive_framework`, `flutter_svg`,
  `cached_network_image`, `skeletonizer`, `fl_chart`.
- AI/GenUI: `genui`, `genui_google_generative_ai`.
- Platform features: maps, BLE, local auth, media, IAP, TTS, video, desktop
  windowing, FFI.

Dependency override comments show the graph is already under pressure:
`firebase_ui_auth` vs `app_links`, `genui` version coupling, analyzer/codegen
coupling, Google sign-in mock constraints, SDK-pinned `intl` and `meta`, and an
iOS simulator path-provider workaround.

### State Management

State management is consistently Cubit/BLoC in presentation. App-scope state is
in `lib/app/presentation/cubit`. Feature state is mostly in
`lib/features/<feature>/presentation/cubit`.

Migration risk: package extraction can accidentally move Cubits into reusable
packages before their dependencies are clean. Keep feature Cubits app-owned
unless the feature is intentionally packaged and has stable public APIs.

### Routing

GoRouter is centralized in `lib/app/router`, with route groups and auth gate
logic. This should stay in `apps/mobile` first because routing composes product
features, auth policy, app shell, and platform behavior.

Reusable packages should not depend on `go_router`. They can expose route
metadata or page builders only when a second app actually needs them.

### Dependency Injection

`get_it` is centralized in `lib/core/di`. Registration files bind app,
feature, Firebase, Supabase, HTTP, storage, and demo services.

Migration risk: moving packages before DI seams exist creates circular package
dependencies. Convert registration into package-owned registration modules only
after the package public API is stable.

### Networking

Reusable HTTP infrastructure already exists under `lib/shared/http`, including
`AppDio`, auth token management, retry, telemetry, network check, Supabase
session manager, and Retrofit helpers. This is a strong candidate for
`packages/networking`.

Feature-specific API clients and repositories should remain with features until
their contracts are stable.

### Authentication

Auth spans:

- `lib/core/auth`: app-wide auth contracts, token repository, session lifecycle.
- `lib/features/auth`: Firebase UI/user-facing auth.
- `lib/features/supabase_auth`: Supabase sign-in demo.
- `lib/features/walletconnect_auth`: WalletConnect auth.
- shared HTTP token/session integration.

Recommended boundary: create `packages/auth` only after consolidating duplicate
core/feature auth models and deciding provider ownership. Firebase UI pages can
stay app-owned initially; provider-agnostic session contracts and token
management move first.

### Storage

Storage and sync infrastructure is mature under `lib/shared/storage` and
`lib/shared/sync`: Hive service, schema registry, migrations, pending sync,
sync operation models, sync Cubit, and background coordinator.

Recommended boundary: extract `packages/storage` and optionally
`packages/offline_sync` later. For first migration wave, use one `storage`
package because sync is tightly coupled to Hive and feature repositories.

### Localization

Localization is root-app scoped:

- `l10n.yaml`
- `lib/l10n/*.arb`
- generated `app_localizations*.dart`
- `BuildContext` l10n helpers in `lib/shared/extensions`.

Keep l10n in the first app package during the initial move. Extracting package
l10n only makes sense after design system or feature packages need standalone
localized widgets.

### Design System

Reusable UI exists in:

- `lib/core/theme`
- `lib/shared/design_system`
- `lib/shared/ui`
- `lib/shared/widgets`
- responsive extensions under `lib/shared/extensions/responsive`
- feature-local reusable widgets under `lib/features/*/presentation/widgets`

Recommended boundary: `packages/design_system` should start with app theme,
tokens, shared widgets, responsive primitives, skeletons, adaptive controls, and
diagnostic-free UI building blocks. Do not move feature widgets until there is
confirmed reuse outside their feature.

### Tests

Tests are broad and valuable. They currently assume one package import root
(`package:flutter_bloc_app/...`). Migration must preserve behavior through:

- package-level unit tests after extraction
- app-level widget tests for route/app shell behavior
- integration tests kept under the first app
- shared test utilities package only after repeated package test needs appear

### CI/CD

Current CI uses root `flutter pub get`, `./bin/checklist`, upload coverage, and
macOS integration preflight. Melos migration should not remove these gates.
Instead, wrap them behind Melos scripts, then migrate CI one job at a time.

### Backend

Firebase backend is partly root-level and partly under `functions`. Proposed
target:

```text
backend/firebase/
  functions/
  firestore_rules/
  storage_rules/
  indexes/
```

Move backend only after app package movement is stable. Firebase CLI config must
be updated in the same phase.

## Current Issues

- Root package owns too many dependency categories, increasing solve time and
  coupling.
- `core` and `shared` contain several future package seams but no package-level
  visibility boundaries yet.
- Auth types exist in both `lib/core/auth` and `lib/features/auth/domain`.
- App DI imports many feature data implementations directly.
- Firebase, Supabase, networking, storage, AI, and presentation dependencies are
  all present in one compile graph.
- Custom lint packages are local packages but not managed as workspace members.
- Backend functions are not grouped with Firebase rules and indexes.
- Generated files and app imports all assume the root package name.
- Feature demos and production-like slices live beside each other with the same
  dependency weight.
- Design system primitives are split across `core/theme`, `shared/design_system`,
  `shared/ui`, `shared/widgets`, and feature widgets.

## Target Monorepo Structure

Recommended target, after phased migration:

```text
flutter_bloc_app/
  apps/
    mobile/                 # first migrated app; supports mobile/web/desktop
    admin/                  # later, only if staff/admin workflows split
  packages/
    core/
    design_system/
    auth/
    networking/
    storage/
    analytics/
    ai/
    feature_flags/
    shared_blocs/
    utilities/
    testing_support/        # later, only if package tests duplicate setup
  backend/
    firebase/
      functions/
      firestore_rules/
      storage_rules/
      indexes/
  custom_lints/
    file_length_lint/
    mix_lint/
  tool/
  bin/
  docs/
  pubspec.yaml              # workspace host + melos: scripts
  analysis_options.yaml
```

Recommended first target should be smaller:

```text
flutter_bloc_app/
  apps/mobile/
  packages/core/
  packages/utilities/
  packages/design_system/
  packages/networking/
  packages/storage/
  custom_lints/
  functions/
  tool/
  bin/
```

Do not create `apps/web` or `apps/desktop` immediately. The current Flutter app
already targets web and desktop. Split separate app packages only when product
requirements diverge.

## Package Responsibilities

### `packages/core`

Owns provider-agnostic app foundations:

- app runtime config interfaces
- flavor/environment types
- result/failure primitives
- logging facade
- shared exceptions
- lifecycle contracts
- platform environment contracts
- DI helpers, not full app registration

No Flutter widgets. Avoid Firebase, Supabase, Hive, Dio, and GoRouter imports.

Initial candidates:

- `lib/core/domain`
- `lib/core/config` provider-agnostic contracts
- `lib/core/time`
- selected `lib/shared/utils` primitives
- selected `lib/shared/platform/platform_environment*`

### `packages/utilities`

Owns pure helpers with no business logic:

- parsing helpers
- date/time formatting
- request ID guards
- disposable/subscription helpers
- markdown utilities only if reused outside app
- retry policy primitives without Dio

Initial candidates:

- `lib/shared/utils/disposable_bag.dart`
- `lib/shared/utils/safe_parse_utils.dart`
- `lib/shared/utils/date_time_formatting.dart`
- `lib/shared/utils/relative_time_formatting.dart`
- `lib/shared/utils/in_flight_coalescer.dart`
- `lib/shared/utils/request_id_guard.dart`
- `lib/shared/utils/retry_policy.dart`

### `packages/design_system`

Owns reusable UI only:

- Material 3 theme extensions
- colors, spacing, typography
- common buttons, cards, dialogs, loading, empty/error states
- adaptive/responsive layout primitives
- skeleton/loading widgets
- image helpers only if UI-generic

No repositories, Cubits with business state, Firebase, Supabase, routing, or
feature decisions.

Initial candidates:

- `lib/core/theme`
- `lib/shared/design_system`
- `lib/shared/ui`
- `lib/shared/widgets/common_*`
- `lib/shared/widgets/skeletons`
- `lib/shared/widgets/responsive_action_bar.dart`
- `lib/shared/extensions/responsive`
- [`DESIGN.md`](../../DESIGN.md) package-facing subset

### `packages/networking`

Owns provider-agnostic HTTP infrastructure:

- Dio factory/config
- interceptors
- retry and circuit breaker
- network status abstraction
- Retrofit response helpers
- auth/session interceptor extension points

Initial candidates:

- `lib/shared/http`
- `lib/shared/services/network_status_service.dart`
- `lib/shared/utils/network_error_mapper*`
- `lib/shared/utils/http_request_failure.dart`

Keep Firebase/Supabase-specific session managers behind optional adapters or
move them to `auth` if they need auth provider types.

### `packages/storage`

Owns local persistence infrastructure:

- Hive initialization
- Hive key management
- schema migrations/registry
- repository base classes
- secure storage abstraction
- preferences migration helpers
- pending sync models and runner if still Hive-coupled

Initial candidates:

- `lib/shared/storage`
- `lib/shared/platform/secure_secret_storage.dart`
- `lib/shared/sync` infrastructure after separating presentation Cubit

### `packages/auth`

Owns provider-agnostic auth/session contracts first:

- `AuthUser`
- `AuthRepository`
- token repository
- session lifecycle coordinator
- permissions interfaces
- remote backend auth port

Provider adapters:

- Firebase adapter can live in `packages/auth/firebase_auth_adapter` later or
  remain app-owned during first extraction.
- Supabase and WalletConnect stay feature/app-owned until product direction
  proves they are first-class auth providers.

Initial candidates:

- `lib/core/auth`
- provider-neutral pieces from `lib/shared/http/auth_token_*`

Do not move Firebase UI pages in the first auth extraction.

### `packages/analytics`

Create only when observability becomes shared across apps. Own:

- analytics facade
- Crashlytics facade
- logging/monitoring adapters
- event naming conventions

Initial app can keep Firebase Analytics/Crashlytics wiring in `apps/mobile`
until `apps/admin` exists.

### `packages/ai`

Create early as a provider-agnostic AI boundary, but start small:

- LLM provider interfaces
- prompt template interfaces
- structured output schemas
- streaming response contracts
- tool-call contracts
- embeddings/RAG interfaces
- agent session/tool registry contracts
- MCP adapter interfaces

Move no UI in the first wave. Existing `genui_demo`, `ai_decision_demo`, and
chat provider code should depend on this package only after contracts are
extracted.

### `packages/feature_flags`

Create when Remote Config and local flags need reuse across apps. Own:

- flag contracts
- local defaults
- typed flag values
- refresh policy

Firebase Remote Config adapter can remain app-owned first.

### `packages/shared_blocs`

Use sparingly. Candidate:

- sync status Cubit
- app status Cubit only if reused by multiple apps

Do not move feature-specific Cubits here.

### `packages/testing_support`

Create later if package tests duplicate:

- fake Firebase bootstrap
- fake repositories
- widget harnesses
- route/test app builders

Keep integration test harness in `apps/mobile/integration_test` initially.

## Feature Extraction Decisions

Default: features remain in `apps/mobile/lib/features` until shared use is real.

| Feature | Initial location | Rationale |
| --- | --- | --- |
| `auth` | app, then split contracts to `auth` | UI tied to Firebase UI and app routes |
| `settings` | app | app-owned l10n, theme, diagnostics, package info |
| `profile` | app | app-specific sync and UI |
| `chat` | app, contracts to `ai` later | mixes UI, chat history, offline, provider adapters |
| `genui_demo` | app | demo UI; extract provider-neutral contracts only |
| `ai_decision_demo` | app | demo; useful concepts feed `packages/ai` |
| `counter` | app | reference offline-first feature; keep as migration canary |
| `todo_list` | app | feature-specific but good storage/sync validation canary |
| `search` | app | app-specific UI and cache |
| `chart` | app | app feature; chart widget may later feed design system |
| `graphql_demo` | app | demo + API-specific |
| `iot`, `iot_demo` | app | platform permissions, BLE, Supabase, offline sync |
| `realtime_market` | app | cohesive feature; reusable domain possible later |
| `staff_app_demo` | app or future `apps/admin` | likely future app split, not package first |
| `remote_config` | app, contracts to `feature_flags` later | Firebase adapter and diagnostics app-owned |
| `camera_gallery`, `google_maps`, `in_app_purchase_demo`, `playlearn`, `native_platform_showcase` | app | platform/demo-specific |
| `library_demo`, `scapes`, `example`, `event_bus_demo`, `igaming_demo`, `online_therapy_demo` | app | demos; avoid premature package creation |

## Build Write-Set

PR-A workspace shell only:

- add root `pubspec.yaml` workspace metadata and Melos dev dependency
- add root `melos:` scripts in that same file
- add `pubspec.lock`
- keep existing app at repo root
- update docs only where commands are introduced
- do not move `lib`, `test`, platform folders, assets, or CI yet

PR-B app relocation:

- `lib/**` -> `apps/mobile/lib/**`
- `test/**` -> `apps/mobile/test/**`
- `integration_test/**` -> `apps/mobile/integration_test/**`
- `assets/**` -> `apps/mobile/assets/**`
- `l10n.yaml` -> `apps/mobile/l10n.yaml`
- platform folders -> `apps/mobile/{android,ios,macos,linux,windows,web}`
- app `pubspec.yaml` -> `apps/mobile/pubspec.yaml`
- app `pubspec.lock` -> `apps/mobile/pubspec.lock` only if Phase A does not
  use Pub workspaces yet; with Pub workspaces, keep root `pubspec.lock`
- update path references in `tool`, `bin`, `.github`, `docs`, `l10n.yaml`,
  `flutter_launcher_icons`, platform scripts, Fastlane, and build scripts
- add root wrappers where existing commands assume app root
- keep package name `flutter_bloc_app`

PR-C package seed:

- selected `apps/mobile/lib/shared/utils/**` ->
  `packages/utilities/lib/src/**`
- add `packages/utilities/lib/utilities.dart`
- add direct package tests before deleting corresponding app tests
- update app imports from `package:flutter_bloc_app/shared/utils/...` to
  `package:utilities/...` only for moved files

PR-D package seed:

- `apps/mobile/lib/core/domain/**` -> `packages/core/lib/src/domain/**`
- provider-neutral `apps/mobile/lib/core/config/**` ->
  `packages/core/lib/src/config/**`
- add `packages/core/lib/core.dart`
- keep Flutter/Firebase/Supabase/GoRouter-free rule enforced by package deps

PR-E package seed:

- `apps/mobile/lib/core/theme/**`,
  `apps/mobile/lib/shared/design_system/**`,
  `apps/mobile/lib/shared/ui/**`, selected
  `apps/mobile/lib/shared/widgets/**` ->
  `packages/design_system/lib/src/**`
- move only widgets with no feature, repository, route, Firebase, Supabase, or
  app-l10n dependencies
- add widget tests for moved components

PR-F package seed:

- `apps/mobile/lib/shared/http/**` -> `packages/networking/lib/src/**`
- `apps/mobile/lib/shared/storage/**` -> `packages/storage/lib/src/**`
- leave app-specific auth/session adapters in `apps/mobile` until auth package
  phase

PR-G package seed (contracts only):

- new `packages/ai/lib/src/**` from provider-neutral interfaces only
- no app feature migration unless one canary adapter is required for proof

PR-I package expansions (optional wave 2; do not combine with PR-G):

- `apps/mobile/lib/core/auth/**` -> `packages/auth/lib/src/**`
- `apps/mobile/lib/shared/sync/**` -> `packages/storage/lib/src/sync/**` or
  `packages/offline_sync/lib/src/**` after coupling review
- Remote Config contracts -> `packages/feature_flags/lib/src/**`

PR-H backend phase:

- `functions/**` -> `backend/firebase/functions/**`
- `firestore.rules` -> `backend/firebase/firestore_rules/firestore.rules`
- `firestore.indexes.json` -> `backend/firebase/indexes/firestore.indexes.json`
- `storage.rules` -> `backend/firebase/storage_rules/storage.rules`

## Files To Keep In Root

Keep repo-level control files at root:

- [`AGENTS.md`](../../AGENTS.md)
- repository README
- `LICENSE`
- [`SECURITY.md`](../../SECURITY.md)
- [`CONTRACTS.md`](../../CONTRACTS.md)
- [`PLAN.md`](../../PLAN.md)
- [`CODEMAP.md`](../../CODEMAP.md)
- `docs/**`
- `tool/**`
- `bin/**`
- `.github/**`
- `analysis_options.yaml` as root default (plugin paths stay workspace-relative)
- root `pubspec.yaml` (workspace host + `melos:` scripts; no standalone `melos.yaml`)
- `analysis/lints/**`
- `custom_lints/**`

Keep generated/platform files inside app packages, not root, after phase 1.

## PR-B Path Rewrite Inventory

PR-B must update every path-sensitive file in one PR. Run the Phase 0 audit
first; treat anything it finds as in-scope for PR-B.

**Phase 0 audit (no code changes):**

```bash
rg -l '(^|[^a-zA-Z_])(lib/|test/|integration_test/|l10n\.yaml|pubspec\.yaml)' \
  bin tool .github .vscode \
  --glob '!docs/**' \
  --glob '!**/melos_*' \
  | LC_ALL=C sort > docs/plans/melos_path_dependent_files.txt
wc -l docs/plans/melos_path_dependent_files.txt
```

**Mandatory PR-B code changes (minimum set):**

| Area | Files / patterns | Action |
| --- | --- | --- |
| Path roots | `tool/workspace_paths.sh` (new) | Define `WORKSPACE_ROOT` / `APP_ROOT` |
| Checklist gate | `tool/delivery_checklist.sh` | Source `workspace_paths.sh`; `cd "$APP_ROOT"` before `flutter pub get`, `flutter analyze`, coverage |
| Integration | `tool/run_integration_tests.sh`, `tool/run_integration_preflight.sh`, `bin/integration_tests` | Resolve targets relative to `APP_ROOT` |
| Metrics / guards | `tool/modular_metrics.sh`, `tool/check_*.sh` that scan `lib/**` | Use `"$APP_ROOT/lib"` or `--app-root` flag |
| Router validate | `bin/router_feature_validate` | Point analyze/format paths at `APP_ROOT` |
| CI | `.github/workflows/ci.yml`, `deploy_web.yml`, `drift.yml`, `dependency-updates.yml` | `dart pub get` at workspace root; `flutter pub get` / tests from `APP_ROOT` or via Melos scope |
| IDE | `.vscode/settings.json` coverage/search excludes | `lib/**` -> `apps/mobile/lib/**` |
| Firebase template | `firebase.json.example` | `android/app/...` -> `apps/mobile/android/app/...`; `lib/firebase_options.dart` -> `apps/mobile/lib/firebase_options.dart` |
| Launcher / icons | `flutter_launcher_icons` config in app `pubspec.yaml` | Verify asset paths after move |
| Agent bootstrap | `tool/setup_cursor_agent_environment.sh`, `tool/local_ide_open_preflight.sh` | Resolve app `pubspec.yaml` via `APP_ROOT` |

**PR-B git moves (use `git mv` only):**

```bash
mkdir -p apps/mobile
git mv lib test integration_test assets l10n.yaml apps/mobile/
git mv android ios macos linux windows web apps/mobile/
# pubspec.yaml + pubspec.lock: split per PR-B steps (workspace root vs app package)
```

**Do not move in PR-B:** `tool/bloc_codegen/build.yaml` (repo tooling), `functions/`,
`custom_lints/`, root `analysis_options.yaml` (update plugin paths if needed, keep at root).

## Proposed Melos Configuration

Current Melos configuration belongs under the `melos:` section in the root
`pubspec.yaml`. Pin Melos in root `dev_dependencies`. Do not use
`usePubspecOverrides`; current Melos removed that option. Use Pub workspaces so
the repository has one shared resolution.

PR-A root `pubspec.yaml` target:

```yaml
name: flutter_bloc_app_workspace
publish_to: none

environment:
  sdk: ">=3.12.0 <4.0.0"

dev_dependencies:
  melos: ^7.0.0

workspace:
  # PR-A bridge: root app remains the app package.
  - .
  - custom_lints/file_length_lint
  - custom_lints/mix_lint

melos:
  name: flutter_bloc_app
  sdkPath: auto
  packages:
    - .
    - custom_lints/*
  scripts:
    bootstrap:
      run: melos bootstrap
      description: Link local packages and run pub get.
    analyze:
      run: melos exec --fail-fast -- "dart analyze ."
      description: Analyze every Dart package.
    analyze:flutter:
      run: melos exec --flutter --fail-fast -- "flutter analyze"
      description: Analyze Flutter packages.
    format:
      run: dart format --set-exit-if-changed .
      description: Check formatting from workspace root.
    format:write:
      run: dart format .
      description: Format workspace.
    test:
      run: melos exec --dir-exists=test --fail-fast -- "dart test"
      description: Run Dart package tests.
    test:flutter:
      run: melos exec --flutter --dir-exists=test --fail-fast -- "flutter test"
      description: Run Flutter package tests.
    coverage:
      run: melos exec --scope=mobile -- "flutter test --coverage"
      description: Run mobile app coverage gate.
    build_runner:
      run: >
        melos exec --depends-on=build_runner --fail-fast --
        "dart run build_runner build --delete-conflicting-outputs"
      description: Generate code in packages that use build_runner.
    clean:
      run: melos exec --flutter -- "flutter clean"
      description: Clean package build outputs.
    checklist:
      run: ./bin/checklist
      description: Existing full repo delivery gate.
    checklist:fast:
      run: ./bin/checklist-fast
      description: Existing fast docs/tooling gate.
```

PR-B root workspace update after app relocation:

```yaml
workspace:
  - apps/mobile
  - custom_lints/file_length_lint
  - custom_lints/mix_lint

melos:
  packages:
    - apps/*
    - custom_lints/*
```

PR-C+ workspace update as packages are created:

```yaml
workspace:
  - apps/mobile
  - packages/utilities
  - packages/core
  - packages/design_system
  - packages/networking
  - packages/storage
  - custom_lints/file_length_lint
  - custom_lints/mix_lint
```

Each workspace package must include:

```yaml
name: <package_name>
publish_to: none

environment:
  sdk: ">=3.12.0 <4.0.0"
resolution: workspace
```

**New package skeleton (use for PR-C onward):**

```text
packages/<name>/
  pubspec.yaml
  analysis_options.yaml          # include: ../../analysis_options.yaml
  lib/
    <name>.dart                  # export barrel only
    src/                         # implementation
  test/
```

```yaml
# packages/<name>/pubspec.yaml (example: utilities)
name: utilities
publish_to: none
resolution: workspace

environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  meta: ^1.17.0

dev_dependencies:
  test: ^1.26.2
  very_good_analysis: ^10.0.0
```

```dart
// packages/<name>/lib/<name>.dart
library;

export 'src/...'; // explicit exports only; no src/ in consumer imports
```

**Codegen rule:** `build_runner` / `build.yaml` stay in `apps/mobile` until a
package owns generated files. When moving Retrofit/Freezed sources to a package,
add that package's `build.yaml` and run `melos run build_runner` scoped to it
before deleting app-generated outputs.

Do not replace existing `./bin/checklist` until Melos scripts prove parity.

## Dependency Management Plan

1. Move root app dependencies unchanged to `apps/mobile/pubspec.yaml`.
2. Add root workspace `pubspec.yaml` with Melos only.
3. For each new package, add only direct dependencies used by that package.
4. Use `dependency_overrides` only at root during migration and document every
   override owner.
5. Remove app dependencies only after code no longer imports them.
6. Keep Firebase, Supabase, maps, BLE, IAP, and platform plugins out of pure
   packages unless that package is explicitly platform-bound.
7. Move analyzer plugin packages into workspace membership without changing
   their internals.
8. Split codegen by package after each package owns generated files.

Expected wins:

- smaller compile graph for pure packages
- package-local analyzer feedback
- lower risk upgrades for utility/core/design code
- clearer Firebase/Supabase boundaries
- better cache keys in CI

## Backend Integration Plan

Recommended final shape:

```text
backend/firebase/
  functions/
    package.json
    src/
    test/
    tool/
  firestore_rules/
    firestore.rules
  storage_rules/
    storage.rules
  indexes/
    firestore.indexes.json
  firebase.json
```

Keep backend at root until app relocation passes. Then move all Firebase CLI
paths together. Backend should not become a Melos Dart package. It should be a
workspace-adjacent Node project with its own `npm` scripts and CI job.

Update `firebase.json.example` (and document gitignored `firebase.json` path
changes) in the same PR as backend moves. Paths in the example today assume root
app layout (`android/app/...`, `lib/firebase_options.dart`); after PR-B those
point at `apps/mobile/...`.

Evaluate:

- Cloud Functions: move as-is first; preserve Node 24 pin.
- Firestore Rules: move with tests or deploy preflight update.
- Storage Rules: move with deploy config update.
- Auth: app provider adapter remains in app/auth package.
- Hosting: if GitHub Pages remains separate from Firebase Hosting, document the
  split in deployment docs.
- Extensions: no extension folder found; add only when used.

## AI-Native Architecture

Create `packages/ai` as a provider-neutral contract package before adding more
AI features. Keep UI and product workflows in app features.

Recommended layers:

```text
packages/ai/lib/
  ai.dart
  src/
    providers/
      llm_provider.dart
      embedding_provider.dart
      streaming_chat_provider.dart
    prompts/
      prompt_template.dart
      prompt_registry.dart
      prompt_version.dart
    structured_outputs/
      schema.dart
      decoder.dart
      validation_error.dart
    tools/
      tool_descriptor.dart
      tool_call.dart
      tool_result.dart
      tool_registry.dart
    agents/
      agent_context.dart
      agent_plan.dart
      agent_runtime.dart
      agent_memory.dart
    rag/
      document_chunk.dart
      retriever.dart
      vector_store.dart
    mcp/
      mcp_server_descriptor.dart
      mcp_tool_adapter.dart
```

Rules:

- No Flutter imports in `packages/ai`.
- No provider SDK in public contracts.
- Provider adapters live behind interfaces.
- Streaming is exposed as typed events, not raw provider payloads.
- Tool calling uses typed descriptors and validation before execution.
- Prompt templates are versioned and testable.
- GenUI transforms structured outputs into app/domain view models outside the
  AI core package.

## Design System Plan

Start with foundation and shared components:

1. Move tokens, typography, theme extensions, responsive primitives, common
   cards/buttons/error/loading widgets.
2. Keep feature-specific widgets in app.
3. Add design system widget tests and golden tests after extraction.
4. Add Storybook/Widgetbook or Flutter Widget Previewer only after package API
   stabilizes.
5. Enforce no business imports from `design_system`.

Accessibility requirements:

- semantic labels for icon-only controls
- contrast-safe color tokens
- scalable text
- adaptive layout breakpoints
- keyboard/focus support for web/desktop
- reduced-motion path for animations

## Performance Opportunities

- Package pure Dart utilities/core to reduce Flutter analyzer/build cost.
- Keep heavy platform plugins app-owned to avoid pulling them into pure package
  graphs.
- Preserve deferred route strategy in app shell.
- Use package-aware CI cache keys.
- Run build_runner only for packages that depend on it.
- Keep feature routes lazy where possible.
- Audit `design_system` exports to avoid broad imports that defeat tree shaking.
- Isolate AI provider adapters so unused providers are not linked into all apps.

## Testing Strategy

Per phase:

- Package extraction: package unit tests plus app tests that cover import/use.
- App move: `flutter test` and existing route/widget tests under `apps/mobile`.
- Shared package public API: add focused package tests before moving app tests.
- Backend move: `npm test` in `backend/firebase/functions` plus Firebase
  preflight.
- CI migration: run old `./bin/checklist` and Melos equivalent in parallel
  before deleting old assumptions.

Minimum proof commands by phase:

```bash
melos bootstrap
melos run analyze
melos run test:flutter
./bin/checklist
```

For docs-only plan edits:

```bash
./bin/checklist-fast --no-reuse
```

## CI/CD Plan

Phase CI changes:

1. Add Melos install/bootstrap after Flutter setup.
2. Keep `./bin/checklist` as primary gate.
3. Add non-blocking `melos run analyze` and `melos run test:flutter`.
4. Promote Melos analyze/test to blocking after parity.
5. Split jobs:
   - workspace-bootstrap
   - package-analyze-test
   - app-checklist
   - app-integration-preflight
   - backend-functions-test
6. Cache:
   - Flutter SDK
   - Pub cache
   - `.dart_tool` per package where safe
   - npm cache for backend functions
7. Use changed-path filters only after baseline package gates are stable.

## Migration Roadmap

### Phase 0 - Baseline And Guardrails

Objective: capture current behavior before workspace edits.

Write-set:

- no source movement
- record `docs/plans/melos_dependency_baseline.txt`
- record `docs/plans/melos_path_dependent_files.txt` (audit command in PR-B section)
- optional: `docs/changes/<date>_melos_monorepo_plan.md` if implementation
  starts from this plan
- optional: create the current repo task tracker file if implementation needs a
  multi-turn checklist

Commands:

```bash
git status --short --branch
flutter pub get
./bin/checklist
./bin/integration_preflight
dart pub deps --style=compact > docs/plans/melos_dependency_baseline.txt
rg -l '(^|[^a-zA-Z_])(lib/|test/|integration_test/|l10n\.yaml)' \
  bin tool .github .vscode --glob '!docs/**' \
  | LC_ALL=C sort > docs/plans/melos_path_dependent_files.txt
```

Acceptance:

- baseline dependency graph recorded
- path-dependent file inventory recorded (expect 50+ hits; PR-B owns them all)
- existing checklist state known before Melos edits
- unrelated dirty files identified and left untouched
- implementation worktree created from `origin/main`, not plan branch

Stop criteria:

- stop if `./bin/checklist` fails for current-main reasons; fix or document
  baseline first
- stop if package resolution is already broken before Melos work

Rollback: no code movement.

### PR-A - Workspace Shell

Objective: add Melos and Pub workspace metadata while the app remains at root.

Write-set:

- root `pubspec.yaml`
- root `pubspec.lock`
- no `lib/**` movement
- no `test/**` movement
- no `.github/**` movement unless CI installs Melos in a non-blocking job
- docs command update if needed

Implementation steps:

1. Convert root `pubspec.yaml` into a workspace-aware app package, keeping app
   dependencies intact and `name: flutter_bloc_app`.
2. Add `dev_dependencies: melos: ^7.0.0`.
3. Add root `workspace:` entries for `.`, `custom_lints/file_length_lint`, and
   `custom_lints/mix_lint`.
4. Add `resolution: workspace` to each workspace member pubspec (`pubspec.yaml`,
   `custom_lints/*/pubspec.yaml`).
5. Add `melos:` scripts that call existing repo commands (see config below).
6. Run `dart pub get` from root (produces/updates root `pubspec.lock`).

PR-A must not rename the root package to `flutter_bloc_app_workspace` yet; that
rename happens in PR-B when the app leaves root.

Commands:

```bash
dart pub add melos --dev
dart pub get
dart run melos bootstrap
dart run melos run analyze:flutter
dart run melos run checklist:fast
./bin/checklist
```

Acceptance:

- root app still runs as before
- Melos bootstrap succeeds
- custom lint packages stay path-resolved
- no source import changes
- `./bin/checklist` remains primary proof

Stop criteria:

- stop if Melos requires changing app dependency versions
- stop if analyzer plugin resolution changes unexpectedly
- stop if root app can no longer run `flutter pub get`

Rollback:

- remove Melos dev dependency
- remove `workspace:` and `melos:` sections
- restore previous root `pubspec.lock`

### PR-B - App Relocation To `apps/mobile`

Objective: make root a real workspace and move the existing app unchanged.

Write-set:

- `apps/mobile/**`
- root `pubspec.yaml`
- root `pubspec.lock`
- `bin/**`
- `tool/**`
- `.github/workflows/**`
- `docs/**` paths that mention root app commands
- platform script references

Implementation steps:

1. Add `tool/workspace_paths.sh` (see Path Root Contract).
2. Create `apps/mobile`.
3. Move app-owned folders with `git mv` (see PR-B Path Rewrite Inventory).
4. Split pubspecs:
   - `apps/mobile/pubspec.yaml` — copy current app deps; keep `name:
     flutter_bloc_app`; add `resolution: workspace`.
   - root `pubspec.yaml` — rename to `flutter_bloc_app_workspace`; Melos
     dev_dep only; `workspace:` lists members; no `flutter:` SDK dependency.
5. Keep single root `pubspec.lock` (Pub workspace resolution).
6. Update `tool/delivery_checklist.sh` and integration scripts before merging.
7. Update asset paths only if relative path changes require it.
8. Keep top-level `bin/checklist` callable from workspace root.
9. Update GitHub Actions workflows listed in PR-B inventory.
10. Leave feature imports unchanged because package name remains
    `flutter_bloc_app`.

Canary files to verify first:

- `apps/mobile/lib/main.dart`
- `apps/mobile/lib/app.dart`
- `apps/mobile/lib/app/router/routes.dart`
- `apps/mobile/lib/core/di/injector_registrations.dart`
- `apps/mobile/test/app/router/app_route_auth_gate_test.dart`
- `apps/mobile/test/counter_cubit_test.dart`
- `apps/mobile/integration_test/smoke_flows_test.dart`

Commands:

```bash
dart pub get
dart run melos bootstrap
dart run melos exec --scope=flutter_bloc_app -- flutter pub get
dart run melos exec --scope=flutter_bloc_app -- flutter test \
  test/app/router/app_route_auth_gate_test.dart
dart run melos exec --scope=flutter_bloc_app -- flutter test \
  test/counter_cubit_test.dart
./bin/checklist
./bin/integration_preflight
```

Acceptance:

- package imports still use `package:flutter_bloc_app/...`
- app platform folders build from `apps/mobile`
- checklist still runs from repo root
- CI paths updated in same PR
- no feature extraction in this PR

Stop criteria:

- stop if scripts require broad rewrites beyond path-root handling
- stop if platform generated files are accidentally regenerated with noisy diffs
- stop if l10n generation changes output unexpectedly

Rollback:

- move app folders back with `git mv`
- restore root `pubspec.yaml` app package
- remove `apps/mobile`

### PR-C - Extract `packages/utilities`

Objective: prove first package extraction with pure Dart, low-coupling code.

Allowed source candidates:

- `apps/mobile/lib/shared/utils/disposable_bag.dart`
- `apps/mobile/lib/shared/utils/safe_parse_utils.dart`
- `apps/mobile/lib/shared/utils/in_flight_coalescer.dart`
- `apps/mobile/lib/shared/utils/request_id_guard.dart`
- `apps/mobile/lib/shared/utils/date_time_formatting.dart`
- `apps/mobile/lib/shared/utils/relative_time_formatting.dart`

Do not move:

- `CubitExceptionHandler`
- app navigation helpers
- logging if it depends on Flutter/app policy
- storage/network/platform helpers

Commands:

```bash
dart run melos bootstrap
dart run melos exec --scope=utilities -- dart test
dart run melos exec --scope=flutter_bloc_app -- flutter test \
  test/counter_cubit_test.dart
./bin/checklist
```

Acceptance:

- `packages/utilities` has no Flutter dependency unless proven necessary
- every moved file has package tests or retained app tests
- app imports only moved utilities from `package:utilities/...`

Stop criteria:

- stop if moved utility needs app logging, routing, storage, or DI
- stop if import rewrites spread across unrelated features

Rollback: move files back to `apps/mobile/lib/shared/utils` and remove package
dependency.

### PR-D - Extract `packages/core`

Objective: extract pure contracts and primitives after utilities proves path.

Allowed source candidates:

- `apps/mobile/lib/core/domain/failure.dart`
- `apps/mobile/lib/core/domain/result.dart`
- `apps/mobile/lib/core/time/timer_service.dart`
- provider-neutral config value objects
- pure platform environment contracts if Flutter-free

Do not move:

- `lib/core/di`
- `lib/core/bootstrap`
- Firebase/Supabase config providers
- router constants
- theme

Commands:

```bash
dart run melos bootstrap
dart run melos exec --scope=core -- dart test
dart run melos exec --scope=flutter_bloc_app -- flutter test \
  test/app/router/app_route_auth_gate_test.dart
./bin/checklist
```

Acceptance:

- `packages/core` public API is small
- no Flutter SDK import unless explicit and justified
- no provider SDK imports
- app remains DI composition root

Stop criteria:

- stop if `core` starts depending on app, design system, networking, storage, or
  auth provider packages

Rollback: move files back and remove `core` dependency.

### PR-E - Extract `packages/design_system`

Objective: create reusable UI foundation without business logic.

Allowed source candidates:

- theme extensions and tokens
- typography constants
- common loading/error/empty/card/form widgets
- skeleton widgets
- responsive layout primitives

Do not move:

- feature widgets
- settings diagnostics widgets
- sync banners if they depend on sync Cubit/domain
- widgets importing GoRouter, repositories, Firebase, Supabase, or app l10n

Commands:

```bash
dart run melos bootstrap
dart run melos exec --scope=design_system -- flutter test
dart run melos exec --scope=flutter_bloc_app -- flutter test \
  test/account_section_test.dart
./bin/checklist
```

Acceptance:

- design system has Flutter dependency but no app package dependency
- moved widgets have widget tests
- no business/domain imports from design system

Stop criteria:

- stop if component extraction requires changing feature behavior
- stop if l10n or route dependencies leak into package

Rollback: move widgets/tokens back and restore app imports.

### PR-F - Extract Networking And Storage

Objective: reduce app infrastructure coupling after pure packages stabilize.

Order:

1. `packages/networking`
2. `packages/storage`

Networking allowed candidates:

- Dio factory
- retry/circuit breaker
- telemetry interceptor interfaces
- network error mapping
- Retrofit response helpers

Storage allowed candidates:

- Hive initializer
- Hive service
- Hive schema registry/migrations
- secure storage abstraction
- repository base classes

Do not move:

- feature repositories
- Firebase/Supabase concrete adapters
- app DI registrations
- sync presentation Cubit until storage package is stable

Commands:

```bash
dart run melos bootstrap
dart run melos exec --scope=networking -- dart test
dart run melos exec --scope=storage -- dart test
dart run melos exec --scope=flutter_bloc_app -- flutter test \
  test/counter_cubit_test.dart
./bin/checklist
```

Acceptance:

- app still owns provider-specific setup
- storage package owns Hive lifecycle only through stable public API
- no feature repository moves in this phase

Stop criteria:

- stop if storage extraction changes Hive box names or schema fingerprints
- stop if networking extraction changes auth/session refresh behavior

Rollback: move infrastructure files back and restore app dependencies.

### PR-G - AI Contracts

Objective: add provider-neutral AI interfaces for future AI-native features.

Write-set:

- `packages/ai/**`
- focused tests for prompt/tool/stream contracts
- no app feature migration unless a contract has one simple canary use

Commands:

```bash
dart run melos bootstrap
dart run melos exec --scope=ai -- dart test
./bin/checklist
```

Acceptance:

- no Flutter dependency
- no direct provider SDK dependency
- no prompt secrets or provider keys
- public API covers streaming, tool calls, structured output, embeddings, and
  retrieval contracts without UI assumptions

Stop criteria:

- stop if package starts implementing product behavior instead of contracts
- stop if provider SDK types leak into public API

Rollback: remove package; app behavior unchanged.

Rollback: remove package; app behavior unchanged.

### PR-I - Auth, Feature Flags, And Sync Split (Optional Wave 2)

Objective: extract provider-neutral auth and flag contracts after networking/storage
packages prove DI and adapter seams.

Prerequisite: PR-F merged and stable for at least one release cycle OR explicit
product need for second app consuming auth contracts.

Write-set:

- `packages/auth/**`
- `packages/feature_flags/**`
- optional `packages/offline_sync/**` if sync Cubit cannot stay app-owned
- app DI registration updates only; no Firebase UI page moves

Do not move in PR-I:

- `lib/features/auth/presentation/**` (Firebase UI)
- WalletConnect / Supabase demo auth UIs
- settings diagnostics

Commands:

```bash
dart run melos bootstrap
dart run melos exec --scope=auth -- dart test
dart run melos exec --scope=flutter_bloc_app -- flutter test \
  test/app/router/app_route_auth_gate_test.dart
./bin/checklist
```

Acceptance:

- auth package has no Firebase UI imports
- app remains composition root for provider adapters
- no change to user-visible auth flows

Stop criteria:

- stop if auth extraction requires moving Firebase UI or GoRouter types into packages
- stop if duplicate `AuthUser` models cannot be unified without behavior change

Rollback: move contracts back to app; remove package dependencies.

### PR-H - Firebase Backend Layout

Objective: move backend assets only after workspace/app paths are stable.

Write-set:

- `backend/firebase/functions/**`
- `backend/firebase/firestore_rules/firestore.rules`
- `backend/firebase/storage_rules/storage.rules`
- `backend/firebase/indexes/firestore.indexes.json`
- Firebase CLI config and deploy scripts
- GitHub Actions backend job paths

Commands:

```bash
cd backend/firebase/functions
npm ci
npm test
cd ../../..
bash tool/firebase_preflight.sh --require-cli
./bin/checklist
```

Acceptance:

- functions build/test path works from new location
- rules/index deploy paths are explicit
- app code does not change in backend PR

Stop criteria:

- stop if Firebase CLI config cannot deploy rules/functions independently
- stop if app CI and backend CI become coupled

Rollback: move backend files back and restore script paths.

### Optional App Splits

Create extra apps only with a product trigger:

- `apps/admin`: staff/admin UX diverges from mobile shell.
- `apps/web`: web shell/deployment differs materially from mobile shell.
- `apps/desktop`: desktop UX, menus, windows, or native entitlements diverge.

Do not create empty app packages.

## Risks And Mitigations

| Risk | Mitigation |
| --- | --- |
| Import churn breaks app | Keep package name stable in phase 2; use small package waves |
| Circular package dependencies | Enforce dependency direction and package analyzer gates |
| DI becomes fragmented | Keep app as composition root; package registration optional |
| Generated files break | Move build_runner packages one at a time and run codegen |
| Firebase config paths break | Move backend in one dedicated phase with deploy preflight |
| CI becomes slower | Add Melos non-blocking first, then package-aware caching |
| Design system absorbs business logic | Enforce no feature/domain imports from design system |
| AI package over-engineered | Start with contracts only; no provider SDK in public API |
| Multiple apps duplicate routes/features | Split apps only when UX/product requirements diverge |
| Existing scripts assume root app | Update scripts with workspace/app root variables before moves |

## Final Directory Tree

```text
flutter_bloc_app/
  apps/
    mobile/
      android/
      ios/
      macos/
      linux/
      windows/
      web/
      assets/
      lib/
        app/
        features/
        l10n/
        main.dart
      test/
      integration_test/
      l10n.yaml
      pubspec.yaml
  packages/
    core/
      lib/core.dart
      test/
      pubspec.yaml
    utilities/
      lib/utilities.dart
      test/
      pubspec.yaml
    design_system/
      lib/design_system.dart
      test/
      pubspec.yaml
    networking/
      lib/networking.dart
      test/
      pubspec.yaml
    storage/
      lib/storage.dart
      test/
      pubspec.yaml
    auth/
      lib/auth.dart
      test/
      pubspec.yaml
    analytics/
      lib/analytics.dart
      test/
      pubspec.yaml
    ai/
      lib/ai.dart
      test/
      pubspec.yaml
    feature_flags/
      lib/feature_flags.dart
      test/
      pubspec.yaml
    shared_blocs/
      lib/shared_blocs.dart
      test/
      pubspec.yaml
  backend/
    firebase/
      functions/
      firestore_rules/
      storage_rules/
      indexes/
      firebase.json
  custom_lints/
    file_length_lint/
    mix_lint/
  analysis/
  bin/
  docs/
  tool/
  .github/
  analysis_options.yaml
  pubspec.yaml
```

Do not add `melos.yaml`; Melos 7 reads the `melos:` key from root `pubspec.yaml`.

## PR Sizing And Review Expectations

| PR | Expected diff size | Review focus | Max scope creep |
| --- | --- | --- | --- |
| PR-A | Small (~10–30 files) | workspace pubspec, custom_lint resolution, Melos bootstrap | No `lib/**` moves |
| PR-B | Large (100+ files) | `workspace_paths.sh`, checklist, CI, git mv correctness | No package extraction |
| PR-C | Medium | import rewrites for utilities only | ≤8 utility files |
| PR-D | Medium | pure Dart boundary, DAG compliance | No DI/bootstrap moves |
| PR-E | Medium–large | widget/l10n leakage, golden tests | No feature widgets |
| PR-F | Large | Hive box names, auth interceptor behavior | No feature repos |
| PR-G | Small | contract-only AI package | No provider SDKs |
| PR-H | Medium | Firebase CLI paths, `firebase.json.example` | No app Dart changes |
| PR-I | Medium–large | auth model unification | No Firebase UI moves |

## Recommendation

Recommended path: move to Melos in three conservative milestones:

1. Workspace shell with current app still intact (PR-A).
2. App relocation to `apps/mobile` with path-root contract (PR-B).
3. Pure package extraction before platform/auth/storage/AI packages (PR-C–G).

Defer PR-I (auth/feature_flags/sync) until PR-F proves infrastructure seams.
Avoid immediate `apps/web`, `apps/desktop`, `apps/admin`, and feature packages.
Those splits add value only after product surfaces diverge or feature code has
confirmed second use.

## Open Questions (resolve before PR-F)

| Question | Default if unresolved | Owner |
| --- | --- | --- |
| Do Supabase session managers live in `networking` or `auth`? | Stay in app until PR-I | implementer |
| Is sync Cubit app-owned or `shared_blocs`? | App-owned through PR-F | implementer |
| Single `packages/storage` vs split `offline_sync`? | Single package in PR-F | implementer |
| Promote Melos analyze/test to blocking in CI? | After PR-B checklist parity | CI maintainer |
