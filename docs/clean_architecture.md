# Clean Architecture in flutter_bloc_app

This app uses feature-based clean architecture with **domain contracts at the
center**, **data implementations behind those contracts**, and **presentation
code depending on abstractions rather than concrete repositories**.

The app also has an **app shell** above the feature layers (`BootstrapCoordinator`,
`MyApp`, `AppScope`, router) and workspace packages beside them (`packages/*`).
Post Phase 5, `apps/mobile/lib/` is a thin shell (`app/**`, `features/**`, `l10n/**`, `main*.dart`)
with no `core/` or `shared/` trees. This document explains how those parts fit together
without blurring layer responsibilities.

Map: [Architecture Details](architecture_details.md). Folder contract:
[`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md).
Package boundaries: [Modularity](modularity.md) and
[Shared Utilities And Package Ownership](SHARED_UTILITIES.md).

## Architecture skeleton

**Clean Architecture is the main skeleton** for every feature. Dependency rule:
`Presentation -> Domain <- Data`. Domain never depends on presentation or data.

**MVVM applies only inside the presentation layer** — it is not a parallel
app-wide architecture and must not introduce extra top-level layers such as
`application/`, `infrastructure/`, or `viewmodels/`.

**Cubit/BLoC is presentation-layer state management only** — live under
`presentation/cubit/` (or app-scope presentation in `AppScope`). Never in
`domain/` or `data/`. Domain rules and invariants belong in domain models and
use cases; data owns I/O and mapping.

```text
presentation/                 ← MVVM boundary (UI + ViewModel only)
  pages/, widgets/            ← View
  cubit/                      ← ViewModel (Cubit / BLoC)

domain/
  <entity>.dart               ← Entity / domain model (pure Dart)
  use_cases/                  ← Use case (when policy requires; see use_case_dto_policy)
  <feature>_repository.dart   ← Repository interface

data/
  <feature>_repository_impl   ← Repository implementation
  *_remote_*, *_local_*, etc.  ← Data source (HTTP, Hive, SDK adapters)
  *_dto.dart                  ← DTO
  *_mapper.dart               ← DTO ↔ domain mapping
```

| MVVM role | This repo |
| --- | --- |
| View | `presentation/pages/`, `presentation/widgets/` — render state; no business rules |
| ViewModel | `presentation/cubit/` — Cubit/BLoC: **presentation state management**; orchestrates user flow and calls domain |
| Model (read) | Domain entities + repository contracts; data implements behind the interface |

Presentation ViewModels call **domain** (repository or use case), never concrete
data classes, DTOs, or SDK types. Orchestration that spans multiple domain
ports belongs in `domain/use_cases/` per
[`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md),
not in widgets.

## Mental Model

Use this model when placing code:

- **App shell** starts the app, configures DI, owns top-level routing, and
  provides app-scope state.
- **Presentation** owns widgets, pages, and **Cubit/BLoC state management**
  (`presentation/cubit/`) for route- and app-scoped user flows.
- **Domain** owns repository/service contracts and pure models.
- **Data** implements domain contracts and owns storage, HTTP/SDKs, sync, and
  merge policies.
- **Workspace packages** hold reusable infrastructure and utilities that should not be
  owned by a single feature (`packages/*`).

## Workspace packages

Packages own reusable capabilities; [`SHARED_UTILITIES.md`](SHARED_UTILITIES.md)
is the package ownership table. [`modularity.md`](modularity.md) owns allowed
dependency direction. Packages never import `apps/mobile` or
`package:flutter_bloc_app`; `bash tool/check_package_dependency_dag.sh` enforces
the current DAG.

## Layer Responsibilities

- **Domain** — Pure Dart contracts and models; no Flutter imports. Examples: `apps/mobile/lib/features/counter/domain/counter_repository.dart`, `apps/mobile/lib/features/remote_config/domain/remote_config_service.dart`, `apps/mobile/lib/features/deeplink/domain/deep_link_parser.dart`.
- **Data** — Adapters that implement domain contracts and coordinate platforms, caching, and sync. Examples: `apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart` (Hive + optional remote), `apps/mobile/lib/features/remote_config/data/offline_first_remote_config_repository.dart` (Firebase Remote Config + Hive cache), `apps/mobile/lib/features/supabase_auth/data/supabase_auth_repository_impl.dart` (Supabase Auth SDK → domain `AuthUser`), `apps/mobile/lib/features/deeplink/data/app_links_deep_link_service.dart` (App Links listener).
- **Presentation** — Cubits/Blocs and widgets that orchestrate user flows while depending only on domain abstractions. Canonical ViewModel path: `presentation/cubit/` (e.g. `remote_config/presentation/cubit/remote_config_cubit.dart`, `counter/presentation/cubit/counter_cubit.dart`). Remaining legacy root-level cubits are listed in [`architecture/reference_features.md`](architecture/reference_features.md).
- **Shared cross-cutting** — Reusable infrastructure lives in packages (`packages/storage`, `packages/networking`, `packages/design_system`, `packages/utilities`, `packages/app_shared_flutter`). Remote images go through `CachedNetworkImageWidget`, timers through `TimerService`, and persistence through `HiveService` (never call `Hive.openBox` directly). See [`SHARED_UTILITIES.md`](SHARED_UTILITIES.md) for detailed documentation of shared utilities.
- **Dependency injection** — The app shell bootstraps DI via `apps/mobile/lib/app/composition/injector_registrations.dart` and feature registrars under `apps/mobile/lib/app/composition/features/`.

## How Dependencies Flow

1. **Domain contracts** define the feature API and stay free of Flutter and SDK
   concerns.
2. **Data implementations** satisfy those contracts and hide storage,
   networking, Firebase/Supabase, platform APIs, and offline-first sync logic.
3. **DI** binds interfaces to implementations so presentation code sees only
   abstractions.
4. **Cubits/Blocs** depend on the contracts, enforce user-flow rules, and emit
   immutable states.
5. **Widgets/pages** render those states and delegate actions back to cubits.

The important dependency rule is:

- **Presentation depends on Domain**
- **Data depends on Domain**
- **Domain depends on nothing below it**

So the dependency picture is closer to `Presentation -> Domain <- Data` than a
literal runtime pipeline of `Presentation -> Domain -> Data`.

## SOLID decision rule

Agents must preserve Clean Architecture and apply SOLID to every new or changed
production type. Treat a violation as a stop condition, not a later cleanup.
Detailed rules and examples: [`solid_principles.md`](solid_principles.md).
Review against [`review/architecture_checklist.md`](review/architecture_checklist.md)
before accepting a feature or boundary-sensitive change.

At runtime, the **app shell** composes everything from above:

- `BootstrapCoordinator` initializes platform/services before `runApp`
- `MyApp` creates the router and top-level app object
- `AppScope` provides app-scope cubits and listeners
- feature routes build route-scoped cubits/blocs and pages

## What Sits Outside the Feature Layers

These directories are intentionally outside the per-feature `domain/data/presentation`
split:

- **`apps/mobile/lib/app/`** — app shell, router, app-scope composition, route groups
- **`packages/*`** — reusable infrastructure (storage/networking/design_system/utilities/auth/app_shared_flutter)

These folders are not "extra layers" between domain and data. They are support
and composition code around the feature layers.

## Reference implementations

| Feature | Boundary worth copying |
| --- | --- |
| Counter | Pure repository contract; offline-first data implementation; timer/user flow in Cubit |
| Remote Config | Firebase and cache hidden behind domain service; presentation receives SDK-free values |
| Deep Links | URI parsing in domain; platform listener in data; GoRouter mapping in presentation |

Exact gold and legacy status: [`architecture/reference_features.md`](architecture/reference_features.md).

## Working Within the Architecture

- Start from the **app shell boundary** first: ask whether the change belongs
  in bootstrap/router/app-scope composition or inside a specific feature.
- Start with the **domain contract/model** under `apps/mobile/lib/features/<feature>/domain/`.
- Implement the contract in **data** (local/remote/offline-first) and register it in DI (`injector_registrations.dart` or `injector_factories.dart`).
- Build a **Cubit/Bloc** that depends only on the domain contract, uses `CubitExceptionHandler` for async work, and respects lifecycle guards.
- Create **responsive, platform-adaptive widgets** that invoke cubit methods and
  render Freezed states (prefer Freezed for new code; legacy Equatable may
  remain). Avoid putting business logic in widgets;
  keep `build()` pure.
- For persistence or timers, rely on shared abstractions (`HiveService`, `SharedPreferencesMigrationService`, `TimerService`, `NetworkStatusService`) to keep layers consistent and testable.
- Keep offline-first logic in the **data layer**; presentation can show pending
  state, but queueing, replay, and conflict resolution stay in repositories and
  shared sync infrastructure.
- Add tests per layer: pure unit tests for domain/data, `bloc_test` for cubits, widget/golden tests for UI; run `./bin/checklist` before shipping.

## AI-Friendly Architecture Rules

Use these as review questions before accepting generated feature/refactor code:

- Model a **system**, not a screen: feature entrypoint, domain contract, data
  adapter, cubit/bloc, route wiring, and tests should be discoverable without
  reading unrelated modules.
- Pass **capabilities**, not concrete feature classes, across reusable UI or
  shared boundaries. Prefer narrow domain/core contracts, callbacks, or typed
  ports over passing a full cubit/repository/view model when only one behavior
  is needed.
- Put shared behavior in the lowest honest owner: feature-local helper first,
  then domain/core/shared service or mixin only after repeated behavior is
  proven. Avoid global `Utils`, `Helper`, `Manager`, and `Base*` buckets.
- Keep widgets dumb: render state, expose callbacks, delegate actions. Do not
  add networking, sync decisions, navigation policy, filtering, aggregation,
  or unrelated state mutation inside `build()`.
- Put **derived view data** (counts, filtered lists, grouped products, lookup
  by id) on `presentation/cubit` state getters or cubit methods — not in pages
  or reusable widgets. Pure domain helpers (date windows, schedule defaults)
  belong in `domain/` and are called from cubits.
- Centralize navigation ownership: map domain targets to GoRouter locations in
  presentation/app routing code; do not scatter raw route strings or
  `context.go` calls through reusable widgets.
- Optimize for future refactors: explicit constructor injection, minimal
  public APIs, stable names that explain intent, immutable state, and tests that
  assert behavior contracts rather than implementation shape.

## Review and validation

Use [`review/architecture_checklist.md`](review/architecture_checklist.md) for
review questions and [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md)
for folder gates. Run `bash tool/check_clean_architecture_imports.sh`,
`bash tool/check_feature_modularity_leaks.sh`, and
`bash tool/check_package_dependency_dag.sh`; `./bin/checklist` owns full proof.
