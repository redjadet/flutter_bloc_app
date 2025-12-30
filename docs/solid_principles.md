# SOLID in flutter_bloc_app

This app follows Clean Architecture (Domain → Data → Presentation) and uses Cubits/Repositories with dependency injection. Below is a quick map of how SOLID shows up in the codebase with concrete references.

> **Related:** See [`clean_architecture.md`](clean_architecture.md) for the overall architecture overview and layer responsibilities.

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

- All services are wired through `getIt` (`injector_registrations.dart`), depending on interfaces (e.g., `NetworkStatusService`, `TimerService`, repositories) rather than concrete classes.
- UI layers receive dependencies via constructors (e.g., `ProfileCacheControlsSection`, page providers) or DI factory functions, keeping Flutter widgets free of new allocations of data sources.

## Practical patterns to keep

- Keep domain types Flutter-agnostic; platform/UI utilities stay under `lib/shared/`.
- Prefer constructor injection (or DI factories) for widgets/cubits; avoid calling `getIt` inside widgets except at composition boundaries.
- When adding services that schedule work or touch hardware, create an interface + fake and register via `getIt` to preserve DIP and testability.
- New features should expose small, focused contracts and inject collaborators rather than passing global state.

## Review Checklist

- Constructors accept abstractions (interfaces) rather than concrete types.
- New data sources implement the domain repository interface instead of expanding existing classes.
- DI registrations bind interfaces to implementations in `lib/core/di/`.
- UI widgets avoid `getIt` lookups except at composition boundaries.
- Avoid adding optional methods to existing interfaces; create new interfaces if needed.
