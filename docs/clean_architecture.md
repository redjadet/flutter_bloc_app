# Clean Architecture in flutter_bloc_app

This app follows a strict Domain → Data → Presentation pipeline backed by `get_it` dependency injection. The notes below explain how the layers stay isolated here, plus concrete examples you can copy when adding new features.

> **Related:** See [`solid_principles.md`](solid_principles.md) for how SOLID principles are applied throughout this architecture.

## Layer Responsibilities

- **Domain** — Pure Dart contracts and models; no Flutter imports. Examples: `lib/features/counter/domain/counter_repository.dart`, `lib/features/remote_config/domain/remote_config_service.dart`, `lib/features/deeplink/domain/deep_link_parser.dart`.
- **Data** — Adapters that implement domain contracts and coordinate platforms, caching, and sync. Examples: `lib/features/counter/data/offline_first_counter_repository.dart` (Hive + optional remote), `lib/features/remote_config/data/offline_first_remote_config_repository.dart` (Firebase Remote Config + Hive cache), `lib/features/deeplink/data/app_links_deep_link_service.dart` (App Links listener).
- **Presentation** — Cubits/Blocs and widgets that orchestrate user flows while depending only on domain abstractions. Examples: `lib/features/counter/presentation/counter_cubit.dart`, `lib/features/remote_config/presentation/cubit/remote_config_cubit.dart`, `lib/features/deeplink/presentation/deep_link_listener.dart`.
- **Shared cross-cutting** — Reusable utilities that stay Flutter-agnostic when possible (`lib/shared/sync/`, `lib/shared/storage/`, `lib/shared/utils/`). Remote images go through `CachedNetworkImageWidget`, timers through `TimerService`, and persistence through `HiveService` (never call `Hive.openBox` directly). See [`SHARED_UTILITIES.md`](SHARED_UTILITIES.md) for detailed documentation of all shared utilities.
- **Dependency injection** — `lib/core/di/injector.dart` bootstraps everything via `registerAllDependencies()` in `lib/core/di/injector_registrations.dart`, wiring domain contracts to concrete implementations (often lazy singletons with dispose callbacks). Use `registerLazySingletonIfAbsent` helpers to keep DI idempotent.

## How Dependencies Flow

1. **Domain contracts** define the API a feature needs.
2. **Data implementations** satisfy the contract and keep platform specifics hidden.
3. **DI** binds the interface to the implementation so presentation code only sees the abstraction.
4. **Cubits/Blocs** depend on the contract, enforce business rules, and emit immutable states.
5. **Widgets** render states with responsive + platform-adaptive components and delegate work back to cubits.

The direction is one-way: Presentation → Domain → Data. Domain never imports Presentation/Data, and Data never imports Presentation. Shared utilities are referenced where needed but avoid UI concerns unless they live under `shared/ui/`.

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

- Start with the **domain contract/model** under `lib/features/<feature>/domain/`.
- Implement the contract in **data** (local/remote/offline-first) and register it in DI (`injector_registrations.dart` or `injector_factories.dart`).
- Build a **Cubit/Bloc** that depends only on the domain contract, uses `CubitExceptionHandler` for async work, and respects lifecycle guards.
- Create **responsive, platform-adaptive widgets** that invoke cubit methods and render `Equatable`/`freezed` states. Avoid putting business logic in widgets.
- For persistence or timers, rely on shared abstractions (`HiveService`, `SharedPreferencesMigrationService`, `TimerService`, `NetworkStatusService`) to keep layers consistent and testable.
- Add tests per layer: pure unit tests for domain/data, `bloc_test` for cubits, widget/golden tests for UI; run `./bin/checklist` before shipping.

## Review Checklist

- Domain files use pure Dart only (no `package:flutter` imports).
- Data layer implements domain contracts and stays free of presentation imports.
- Presentation depends on abstractions and does not construct repositories.
- Feature wiring happens in `lib/core/di/` via `registerLazySingletonIfAbsent`.
- Use constructor injection for cubits/repositories to keep dependencies explicit.
- New Hive repositories extend `HiveRepositoryBase` or `HiveSettingsRepository<T>`.
- Do not call `Hive.openBox` outside `lib/shared/storage/`.
- `setState` is reserved for UI-only toggles; business state lives in cubits.
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
