# SOLID in flutter_bloc_app

This app follows Clean Architecture (Domain → Data → Presentation) and uses Cubits/Repositories with dependency injection. Below is a quick map of how SOLID shows up in the codebase with concrete references.

> **Related Documentation:**
>
> - [Clean Architecture](clean_architecture.md) - Overall architecture overview and layer responsibilities
> - [Code Quality](CODE_QUALITY.md) - Comprehensive SOLID principles analysis with verification results
> - [Architecture Details](architecture_details.md) - Architecture diagrams and dependency flow
> - [Offline-First Architecture Case Study](engineering/offline_first_flutter_architecture_with_conflict_resolution.md) - Example of repository-level composition without leaking sync logic upward
> - [Flutter Best Practices Review](flutter_best_practices_review.md) - SOLID principles review section

## Single Responsibility

- Classes/modules should have one reason to change.

- `CounterCubit` orchestrates counter state and persistence only; timer abstractions live in `TimerService`, and persistence sits behind `CounterRepository`.
- `ConnectivityNetworkStatusService` wraps connectivity changes and debouncing; it does not handle UI or sync decisions.
- `ProfileCacheControlsSection` renders cache controls; the repository dependency is injected so the widget stays UI-only.

## Open/Closed

- Open for extension, closed for modification.

- Repositories extend feature contracts (e.g., `CounterRepository`, `ProfileRepository`) so new storage backends can be added without changing consumers.
- `SyncableRepositoryRegistry` allows adding new sync-capable repos without modifying the coordinator’s core logic.

## Liskov Substitution

- Subtypes must be usable anywhere their base type is expected without breaking behavior.

- Interfaces like `NetworkStatusService`, `TimerService`, and feature repositories have fake/mock implementations in tests that can drop in for production types without changing behavior expectations.
- Cubits depend on abstractions (`CounterRepository`, `TimerService`) so any compliant implementation can be substituted.

## Interface Segregation

- Clients should not depend on methods they do not use.

- Feature domains define lean interfaces (e.g., `CounterRepository` with `load`, `save`, `watch`) instead of forcing unrelated methods.
- Timer abstractions split periodic vs one-shot operations (`periodic`, `runOnce`) to avoid leaking broader `Timer` APIs.

## Dependency Inversion

- Depend on abstractions, not concrete implementations.

- All services are wired through `getIt` (feature-specific registration files in `lib/core/di/`), depending on interfaces (e.g., `NetworkStatusService`, `TimerService`, repositories) rather than concrete classes.
- DI registrations are organized by feature (`register_chat_services.dart`, `register_profile_services.dart`, etc.) to improve SRP and maintainability.
- UI layers receive dependencies via constructors (e.g., `ProfileCacheControlsSection`, page providers) or DI factory functions, keeping Flutter widgets free of new allocations of data sources.
- App-shell composition points (`BootstrapCoordinator`, router, `AppScope`) can
  resolve and wire implementations, but lower-level feature code should still
  depend on abstractions.

## How SOLID Shows Up in Practice

### Strengths

- **SRP:** Core orchestration components isolate concerns behind services.
  `BackgroundSyncCoordinator` delegates scheduling to `TimerService`, connectivity
  to `NetworkStatusService`, and persistence to `PendingSyncRepository`. DI
  registrations are split into feature-specific files
  (`register_chat_services.dart`, `register_profile_services.dart`, etc.).
- **OCP:** Reusable base repositories (`HiveSettingsRepository<T>`,
  `HiveRepositoryBase`) and generic factory helpers (`createRemoteRepositoryOrNull`)
  let new storage backends and offline-first repositories plug in without editing
  existing consumers.
- **LSP:** Production services are substitutable with fakes in tests
  (`FakeTimerService`, mock repositories) without behavior changes.
- **ISP:** Feature interfaces remain small and focused — e.g. `ChatRepository`
  only exposes `sendMessage`; `ChatHistoryRepository` only exposes load/save.
- **DIP:** Most cubits and pages receive interfaces via constructors and `getIt`.
  Settings presentation depends on cache interfaces, not concrete Hive classes.
  `OfflineFirstChatRepository` delegates sync payloads to
  `ChatSyncOperationFactory` and local persistence to
  `ChatLocalConversationUpdater`.

### Areas to Watch

- **Presentation → data-layer imports:** Periodically verify no new data-layer
  imports creep into presentation code:
  `rg "features/.*/data" lib/features -g"*presentation*.dart"`
- **App shell overreach:** Keep `lib/app/` and bootstrap code focused on
  composition. If route files or `AppScope` start accumulating feature business
  rules, SOLID boundaries are slipping.
- **Offline-first repository growth:** When a new offline-first repository gains
  multiple responsibilities, extract collaborators early (same pattern as Chat).

## Practical patterns to keep

- Keep domain types Flutter-agnostic; platform/UI utilities stay under `lib/shared/`.
- Prefer constructor injection (or DI factories) for widgets/cubits; avoid calling `getIt` inside widgets except at composition boundaries.
- When adding services that schedule work or touch hardware, create an interface + fake and register via `getIt` to preserve DIP and testability.
- New features should expose small, focused contracts and inject collaborators rather than passing global state.

## Review Checklist

- Constructors accept abstractions (interfaces) rather than concrete types.
- New data sources implement the domain repository interface instead of expanding existing classes.
- DI registrations bind interfaces to implementations in feature-specific files under `lib/core/di/` (e.g., `register_chat_services.dart`, `register_profile_services.dart`).
- UI widgets avoid `getIt` lookups except at composition boundaries.
- Avoid adding optional methods to existing interfaces; create new interfaces if needed.
- Use generic factory helpers (`createRemoteRepositoryOrNull`) for consistent error handling when creating remote repositories.
