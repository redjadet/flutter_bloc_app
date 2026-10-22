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
[Shared Utilities And Package Ownership](engineering/SHARED_UTILITIES.md).

## Architecture skeleton

**Clean Architecture** is the feature skeleton. Dependency rule:
`Presentation -> Domain <- Data`. Domain never depends on presentation or data.

**Folder tree, MVVM-presentation-only, Cubit placement, and forbidden parallel
layers** (`application/`, `infrastructure/`, `viewmodels/`): canonical in
[`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md)
§ Skeleton. Multi-port orchestration: [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md).

Presentation ViewModels call **domain** (repository or use case), never concrete
data classes, DTOs, or SDK types.

## Mental Model

Use this model when placing code:

- **App shell** starts the app, configures DI, owns top-level routing, and
  provides app-scope state.
- **Presentation** owns widgets, pages, and **Cubit/BLoC state management**
  (`presentation/cubit/`) for route- and app-scoped user flows.
- **Domain** owns repository/service contracts, pure models, and reusable pure
  business policies.
- **Data** implements domain contracts and owns storage, HTTP/SDKs, and
  sync/merge orchestration. Pure reusable business decisions, including merge
  eligibility, live in domain policies that data invokes.
- **Workspace packages** hold reusable infrastructure and utilities that should not be
  owned by a single feature (`packages/*`).

## Workspace packages

Packages own reusable capabilities; [`engineering/SHARED_UTILITIES.md`](engineering/SHARED_UTILITIES.md)
is the package ownership table. [`modularity.md`](modularity.md) owns allowed
dependency direction. Packages never import `apps/mobile` or
`package:flutter_bloc_app`; `bash tool/check_package_dependency_dag.sh` enforces
the current DAG.

## Layer Responsibilities

- **Domain** — Pure Dart contracts and models; no Flutter imports. Examples: `apps/mobile/lib/features/counter/domain/counter_repository.dart`, `apps/mobile/lib/features/remote_config/domain/remote_config_service.dart`, `apps/mobile/lib/features/deeplink/domain/deep_link_parser.dart`.
- **Data** — Adapters that implement domain contracts and coordinate platforms,
  caching, persistence, retry, and sync. Data applies domain policies at every
  relevant I/O path; it does not duplicate reusable business decisions.
  Examples: `apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart`
  (Hive + optional remote), `apps/mobile/lib/features/remote_config/data/offline_first_remote_config_repository.dart`
  (Firebase Remote Config + Hive cache), `apps/mobile/lib/features/supabase_auth/data/supabase_auth_repository_impl.dart`
  (Supabase Auth SDK → domain `AuthUser`), `apps/mobile/lib/features/deeplink/data/app_links_deep_link_service.dart`
  (App Links listener).
- **Presentation** — Cubits/Blocs and widgets that orchestrate user flows while depending only on domain abstractions. Canonical ViewModel path: `presentation/cubit/` (e.g. `remote_config/presentation/cubit/remote_config_cubit.dart`, `counter/presentation/cubit/counter_cubit.dart`). Remaining legacy root-level cubits are listed in [`architecture/reference_features.md`](architecture/reference_features.md).
- **Shared cross-cutting** — Reusable infrastructure lives in packages (`packages/storage`, `packages/networking`, `packages/design_system`, `packages/utilities`, `packages/app_shared_flutter`). Remote images go through `CachedNetworkImageWidget`, timers through `TimerService`, and persistence through `HiveService` (never call `Hive.openBox` directly). See [`engineering/SHARED_UTILITIES.md`](engineering/SHARED_UTILITIES.md) for detailed documentation of shared utilities.
- **Dependency injection** — The app shell **registers** services via
  `apps/mobile/lib/app/composition/injector_registrations.dart` and feature
  registrars under `apps/mobile/lib/app/composition/features/`. The
  **composition root** (`AppCompositionRoot`) resolves those registrations into
  `AppScopeDependencies` and typed route factories so router/pages do not call
  `getIt` directly.

  **Ownership (GetIt Flavor 3 mitigations):**

  | Lifetime | Mechanism | Examples |
  | --- | --- | --- |
  | App-wide singleton | GetIt lazy singleton; pass `dispose:` when the type owns streams/connections | repositories, Dio, sync coordinator |
  | Route / screen | `BlocProvider` / `RouteScopedPage` | feature cubits |
  | Scoped non-singleton | Factory callback on a typed route factory; dispose with cubit | realtime market repository |
  | Forbidden | `getIt` in `features/*/presentation/**` | leaf widgets — inject via constructors |

  Presentation uses **constructor injection** only. `tool/check_direct_getit.sh`
  enforces no `getIt<` / `getIt.` access under presentation (demo folders
  excluded). Tests tear down with `getIt.reset(dispose: true)`.

  **Exception:** `BackendAvailability` stays a GetIt **factory**
  (`fromBootstrap`) so each resolve re-reads live backend flags after deferred
  Firebase/Supabase bootstrap — not a stable singleton.

  Do not adopt Riverpod or `injectable` as DI for this app. Do not adopt
  BlocSignal (`bloc_signals` / `bloc_signals_flutter`) as DI **or** as a second
  state-management stack — keep constructor injection + `flutter_bloc` tree
  scope + GetIt composition ([ADR 0007](adr/0007-blocsignal-evaluation.md)).

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

## Mapping to Flutter's official architecture guide

Flutter's [app architecture guide](https://docs.flutter.dev/app-architecture/guide)
names the same roles differently. Use this table when reading external advice:

| Flutter guide | This repo | Notes |
| --- | --- | --- |
| View | `presentation/pages/`, `presentation/widgets/` | Only show/hide flags, animation, layout, simple routing. |
| View model (+ commands) | Cubit/BLoC in `presentation/cubit/` | Cubit methods play the role of commands. |
| Use case (optional domain layer) | `domain/use_cases/` (optional) | Same rule: add one only for multi-repository, complex, or reused logic ([policy](architecture/use_case_dto_policy.md)). |
| Repository (source of truth) | Domain contract + `data/` implementation | Guide calls abstract repositories "strongly recommend"; here the contract is required. |
| Service (stateless, one per data source) | `*DataSource` leaves, SDK adapters, `packages/networking` | Hold no app state. |
| Domain model vs API model | Domain model in `domain/`, DTO in `data/` | Guide marks separate API models "conditional, large apps"; the DTO rule here applies when shapes can drift. |

Deliberate differences from the guide: the domain **contract** layer is
mandatory here (Clean Architecture dependency inversion), while the guide treats
the whole domain layer as optional; state management is `flutter_bloc`, not
`ChangeNotifier`; DI is GetIt composition plus constructor injection, not
`provider`; folders are feature-first for all layers, while the guide's case
study groups `ui/` by feature and `data/` by type.

Rules taken from the guide that apply unchanged:

- **Repositories don't know each other.** Combine data from two domain
  repositories in a Cubit or a domain use case. Facades that wrap leaves of the
  same contract (offline-first, auth-aware, composite) are fine: in the guide's
  terms those leaves are services, even where legacy names still say
  `*Repository` ([naming table](architecture/use_case_dto_policy.md#repository-vs-leaf-datasource-naming)).
- **Unidirectional data flow.** Data moves data → domain → presentation; user
  events go back through Cubit methods.
- **Blocs don't listen to blocs** ([bloc architecture](https://bloclibrary.dev/architecture/)).
  Connect them through a `BlocListener` in presentation or a shared reactive
  repository stream.

### Error flow across layers

Dart exceptions are unchecked, so a missed `catch` can crash a flow (see the
guide's [Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result)).
This repo uses two shapes; pick one per contract and don't mix them inside it:

- **Typed throw + Cubit catch** (most features): data maps SDK/transport errors
  to domain or `package:utilities` failures (for example `HttpRequestFailure`);
  Cubits run async work through `CubitExceptionHandler` and emit failure state.
- **`Result<T>` / `Failure`** from `package:core` (for example the IoT BLE
  contracts): use it when callers must branch on expected failures; unwrap with
  an exhaustive `switch`.

Either way, SDK exception types never cross into domain contracts or Cubit
state ([error mapping](architecture/use_case_dto_policy.md#error-mapping)).

### Presentation reads no app singletons

Presentation must not import `app/bootstrap/**` or `app/config/**` (except
`backend_availability.dart`) to read static flags such as
`FirebaseBootstrapService.isFirebaseInitialized` or `FlavorManager.I`. The
router or composition root resolves those values and passes them to pages and
Cubits through constructors. `tool/check_clean_architecture_imports.sh` enforces
this.

## SOLID decision rule

Agents must preserve Clean Architecture and apply SOLID to every new or changed
production type. Treat a violation as a stop condition, not a later cleanup.
Detailed rules and examples: [`solid_principles.md`](architecture/solid_principles.md).
Review against [`review/architecture_checklist.md`](review/architecture_checklist.md)
before accepting a feature or boundary-sensitive change.

At runtime, the **app shell** composes everything from above:

- `BootstrapCoordinator` initializes platform/services and registers DI before
  `runApp`
- `AppCompositionRoot.createApp` builds `GoRouter`, resolves
  `AppScopeDependencies`, and constructs `MyApp`
- `AppScope` provides app-scope cubits and listeners from injected dependencies
- Feature routes receive typed factories (`CoreRouteFactory`,
  `AuxiliaryRouteFactory`, `DemoRouteFactory`) and build route-scoped
  cubits/blocs and pages without service-locator lookups

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
- Keep offline-first I/O and orchestration in the **data layer**; presentation
  can show pending state, while repositories and shared sync infrastructure own
  queueing, replay, ordering, persistence, retry, and policy invocation. Put a
  reusable pure conflict/eligibility decision in **domain** and invoke it from
  every data path that can merge or overwrite state.
- Add tests per layer: pure unit tests for domain/data, `bloc_test` for cubits, widget/golden tests for UI; run `./bin/checklist` before shipping.

## AI-Friendly Architecture Rules

Review questions before accepting generated feature/refactor code:

- Model a **system**, not a screen (entrypoint, domain contract, data adapter,
  cubit, routes, tests discoverable without unrelated modules).
- Pass **capabilities** (narrow ports/callbacks), not full cubits/repos, across
  reusable UI. Lowest honest owner for shared behavior; avoid `Utils`/`Base*`
  buckets.
- **Widgets stay dumb** / derived view data in cubit getters: full agent rule in
  [`agent_knowledge_base_details.md`](agent_knowledge_base_details.md)
  § Business logic must be separated from UI; widget placement in
  [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md)
  § Reusable presentation widgets.
- Centralize GoRouter ownership in presentation/app routing; no raw
  `context.go` / route strings in reusable widgets.
- Prefer explicit DI, small public APIs, immutable state, behavior-contract tests.
- Before implementation, answer the protected-rule, owner, partial-failure, and
  enforcement-radius questions in
  [`architecture/reduce_surprise_patterns.md`](architecture/reduce_surprise_patterns.md)
  § Decision-first feature frame.

## Review and validation

Use [`review/architecture_checklist.md`](review/architecture_checklist.md) for
review questions and [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md)
for folder gates. Run `bash tool/check_clean_architecture_imports.sh`,
`bash tool/check_feature_modularity_leaks.sh`, and
`bash tool/check_package_dependency_dag.sh`; `./bin/checklist` owns full proof.
