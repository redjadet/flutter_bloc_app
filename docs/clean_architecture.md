# Clean Architecture in flutter_bloc_app

This app uses feature-based clean architecture with **domain contracts at the
center**, **data implementations behind those contracts**, and **presentation
code depending on abstractions rather than concrete repositories**.

The app also has an **app shell** above the feature layers (`BootstrapCoordinator`,
`MyApp`, `AppScope`, router) and **shared/core infrastructure** beside them
(`lib/core/`, `lib/shared/`). This document explains how those parts fit
together without blurring layer responsibilities.

> **Related Documentation:**
>
> - [Architecture Details](architecture_details.md) - Diagrams, principles, BLoC rationale
> - [Lazy loading & state flow](architecture_lazy_loading_and_flow.md) - Deferred routes and offline-first sequence
> - [SOLID Principles](solid_principles.md) - How SOLID principles are applied throughout this architecture
> - [DRY Principles](dry_principles.md) - DRY consolidations and patterns
> - [Separation of Concerns](separation_of_concerns.md) - Responsibility boundaries across layers, DI, and shared services
> - [Modularity](modularity.md) - Dependency direction, core contracts, and feature composition
> - [Offline-First Architecture Case Study](engineering/offline_first_flutter_architecture_with_conflict_resolution.md) - How conflict resolution and background sync fit the data layer
> - [Code Quality](CODE_QUALITY.md) - Architecture compliance verification and code quality metrics
> - [Flutter Best Practices Review](flutter_best_practices_review.md) - Architecture review and best practices checklist

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
- **Core/shared** hold reusable infrastructure and utilities that should not be
  owned by a single feature.

## Layer Responsibilities

- **Domain** — Pure Dart contracts and models; no Flutter imports. Examples: `lib/features/counter/domain/counter_repository.dart`, `lib/features/remote_config/domain/remote_config_service.dart`, `lib/features/deeplink/domain/deep_link_parser.dart`.
- **Data** — Adapters that implement domain contracts and coordinate platforms, caching, and sync. Examples: `lib/features/counter/data/offline_first_counter_repository.dart` (Hive + optional remote), `lib/features/remote_config/data/offline_first_remote_config_repository.dart` (Firebase Remote Config + Hive cache), `lib/features/supabase_auth/data/supabase_auth_repository_impl.dart` (Supabase Auth SDK → domain `AuthUser`), `lib/features/deeplink/data/app_links_deep_link_service.dart` (App Links listener).
- **Presentation** — Cubits/Blocs and widgets that orchestrate user flows while depending only on domain abstractions. Canonical ViewModel path: `presentation/cubit/` (e.g. `remote_config/presentation/cubit/remote_config_cubit.dart`). Legacy root-level cubits (e.g. `counter/presentation/counter_cubit.dart`) remain until migrated — see [`architecture/reference_features.md`](architecture/reference_features.md).
- **Shared cross-cutting** — Reusable utilities that stay Flutter-agnostic when possible (`lib/shared/sync/`, `lib/shared/storage/`, `lib/shared/utils/`). Remote images go through `CachedNetworkImageWidget`, timers through `TimerService`, and persistence through `HiveService` (never call `Hive.openBox` directly). See [`SHARED_UTILITIES.md`](SHARED_UTILITIES.md) for detailed documentation of all shared utilities.
- **Dependency injection** — `lib/core/di/injector.dart` bootstraps everything via `registerAllDependencies()` in `lib/core/di/injector_registrations.dart`, wiring domain contracts to concrete implementations (often lazy singletons with dispose callbacks). Use `registerLazySingletonIfAbsent` helpers to keep DI idempotent.

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

At runtime, the **app shell** composes everything from above:

- `BootstrapCoordinator` initializes platform/services before `runApp`
- `MyApp` creates the router and top-level app object
- `AppScope` provides app-scope cubits and listeners
- feature routes build route-scoped cubits/blocs and pages

## What Sits Outside the Feature Layers

These directories are intentionally outside the per-feature `domain/data/presentation`
split:

- **`lib/app/`** — app shell, router, app-scope composition, route groups
- **`lib/core/`** — app-wide contracts, DI, bootstrap, constants, theme,
  diagnostics, and platform-wide helpers
- **`lib/shared/`** — reusable infrastructure, storage, sync, widgets, design
  tokens, and utilities used by multiple features

These folders are not "extra layers" between domain and data. They are support
and composition code around the feature layers.

## Example: Counter (offline-first, timer-driven)

- **Domain** — `lib/features/counter/domain/counter_repository.dart` exposes `load/save/watch` over `CounterSnapshot` (pure value object).
- **Data** — `lib/features/counter/data/offline_first_counter_repository.dart` wraps `HiveCounterRepository` for local persistence, optionally forwards writes to a remote `CounterRepository`, and enqueues sync operations via `PendingSyncRepository` + `SyncableRepositoryRegistry`.
- **Presentation** — `lib/features/counter/presentation/counter_cubit.dart` drives auto-decrement timers through `TimerService`, persists state through the domain contract, guards lifecycle (`isClosed` checks, `CubitExceptionHandler`), and updates UI widgets such as `lib/features/counter/presentation/pages/counter_page.dart` (which uses responsive padding and `PlatformAdaptive.filledButton`).

Key takeaways: business logic (count rules, sync flow) lives in the cubit + domain; storage and sync concerns stay in the data layer; widgets stay focused on layout.

## Example: Remote Config (read-heavy with cache)

- **Domain** — `lib/features/remote_config/domain/remote_config_service.dart` defines read/write methods without any Firebase types.
- **Data** — `lib/features/remote_config/data/offline_first_remote_config_repository.dart` implements the contract using a Firebase-backed `RemoteConfigRepository` plus a Hive cache (`RemoteConfigCacheRepository`). It registers with the sync registry so background sync can refresh values, and it tracks telemetry without leaking SDK details upward.
- **Presentation** — `lib/features/remote_config/presentation/cubit/remote_config_cubit.dart` exposes `initialize`, `fetchValues`, and `clearCache` commands. The cubit manages loading/error states and reads values only through the domain interface before the widgets render them.

This separation lets the cubit and UI remain testable without Firebase while the data layer swaps caching strategies freely.

## Example: Deep Links (routing stays in presentation)

- **Domain** — `lib/features/deeplink/domain/deep_link_parser.dart` and `lib/features/deeplink/domain/deep_link_target.dart` translate URIs into domain-level targets with no router knowledge.
- **Data** — `lib/features/deeplink/data/app_links_deep_link_service.dart` listens to platform links and hands raw URLs to the parser.
- **Presentation** — `lib/features/deeplink/presentation/deep_link_cubit.dart` consumes the domain service and uses `lib/features/deeplink/presentation/deep_link_target_extensions.dart` to map domain targets to `GoRouter` locations. Routing decisions remain in presentation, keeping domain free of navigation dependencies.

## Working Within the Architecture

- Start from the **app shell boundary** first: ask whether the change belongs
  in bootstrap/router/app-scope composition or inside a specific feature.
- Start with the **domain contract/model** under `lib/features/<feature>/domain/`.
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
  add networking, sync decisions, navigation policy, or unrelated state
  mutation inside `build()`.
- Centralize navigation ownership: map domain targets to GoRouter locations in
  presentation/app routing code; do not scatter raw route strings or
  `context.go` calls through reusable widgets.
- Optimize for future refactors: explicit constructor injection, minimal
  public APIs, stable names that explain intent, immutable state, and tests that
  assert behavior contracts rather than implementation shape.

## Review Checklist

- Domain files use pure Dart only (no `package:flutter` imports).
- Data layer implements domain contracts and stays free of presentation imports.
- Presentation depends on abstractions and does not construct repositories.
- App shell code (`lib/app/`, `lib/core/bootstrap/`, router) is used for
  composition, not for embedding feature business logic.
- Feature wiring happens in `lib/core/di/` via `registerLazySingletonIfAbsent`.
- Use constructor injection for cubits/repositories to keep dependencies explicit.
- New Hive repositories extend `HiveRepositoryBase` or `HiveSettingsRepository<T>`.
- Do not call `Hive.openBox` outside `lib/shared/storage/`.
- `setState` is reserved for UI-only toggles; business state lives in cubits.
- New user-visible features need an app entrypoint unless the owning doc says
  route-only.
- Async cubit operations use `CubitExceptionHandler`; clean up timers/streams in
  `close()`.

Example violation (domain):

```dart
// ❌ Do not import Flutter in domain
import 'package:flutter/material.dart';
```

Quick check:

```bash
./tool/check_no_hive_openbox.sh
```
