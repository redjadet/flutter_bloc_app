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

## Current Findings (Codebase Review)

### Strengths

- **SRP:** Core orchestration components isolate concerns behind services. Example: `BackgroundSyncCoordinator` delegates scheduling to `TimerService`, connectivity checks to `NetworkStatusService`, and persistence to `PendingSyncRepository` (`lib/shared/sync/background_sync_coordinator.dart`).
- **OCP:** Reusable base repositories allow adding settings or cache types without editing existing consumers. Example: `HiveSettingsRepository<T>` and `HiveRepositoryBase` (`lib/shared/storage/hive_settings_repository.dart`, `lib/shared/storage/hive_repository_base.dart`).
- **LSP:** Production services are substitutable with fakes in tests (e.g., `FakeTimerService` used across cubit/widget tests) without behavior changes (`test/test_helpers.dart`).
- **ISP:** Feature interfaces remain small and focused (e.g., `ChatRepository` only exposes `sendMessage`, `ChatHistoryRepository` only load/save) (`lib/features/chat/domain/chat_repository.dart`, `lib/features/chat/domain/chat_history_repository.dart`).
- **DIP:** Most cubits and pages receive interfaces via constructors and `getIt`, keeping widget layers decoupled from concrete implementations (`lib/app/app_scope.dart`, `lib/app/router/routes.dart`).

### Opportunities

- **DIP (presentation depending on data-layer types):** Addressed for settings cache widgets by introducing cache interfaces and injecting them from DI. Continue to watch for new data-layer imports in presentation (`lib/features/settings/presentation/pages/settings_page.dart`, `lib/features/settings/presentation/widgets/graphql_cache_controls_section.dart`, `lib/features/settings/presentation/widgets/profile_cache_controls_section.dart`).
- **SRP (offline-first repositories doing multiple jobs):** `OfflineFirstChatRepository` handles remote calls, local persistence, sync operation creation, and registry registration in one class (`lib/features/chat/data/offline_first_chat_repository.dart`). This is cohesive but makes the class harder to evolve or test in isolation.

## Action Checklist (SOLID Improvements)

- **Critical:** Introduce small cache interfaces in domain/shared and use them in presentation.
- **Critical Instructions:** Define lean interfaces (e.g., `GraphqlCacheRepository`, `ProfileCacheRepository`) with only the methods needed by UI widgets; place them in a domain/shared module (not in data), and update `lib/features/settings/presentation/pages/settings_page.dart`, `lib/features/settings/presentation/widgets/graphql_cache_controls_section.dart`, and `lib/features/settings/presentation/widgets/profile_cache_controls_section.dart` to depend on interfaces only.
- **Critical Acceptance Criteria:** Presentation files no longer import from `lib/features/**/data`, interface types are the only repository types used by cache widgets, and analysis passes.
- **Critical Verification Commands:** `rg \"features/.*/data\" lib/features -g\"*presentation*.dart\"`, `rg \"GraphqlDemoCacheRepository|HiveProfileCacheRepository\" lib/features -g\"*presentation*.dart\"`, and `flutter analyze`.
- **Critical Status:** Implemented (cache interfaces added; settings presentation now depends on interfaces; DI routes resolve interfaces).
- **High:** Bind new interfaces in DI and resolve them at composition boundaries.
- **High Instructions:** Register interface-to-implementation mappings in `lib/core/di/injector_registrations.dart` (or `lib/core/di/register_http_services.dart` if applicable), and update `lib/app/router/routes.dart` to request interfaces from `getIt` rather than concrete cache repository classes. Keep interface registrations near similar service registrations for discoverability.
- **High Acceptance Criteria:** DI resolves interface types successfully; route builders and page constructors do not reference concrete cache repository classes.
- **High Verification Commands:** `rg \"GraphqlDemoCacheRepository|ProfileCacheRepository\" lib/app/router/routes.dart`, `rg \"register.*<GraphqlCacheRepository>|register.*<ProfileCacheRepository\" lib/core/di -g\"*.dart\"`, and `flutter test test/core/di/injector_test.dart`.
- **High:** Extract offline-first responsibilities to tighten SRP in chat data layer.
- **High Instructions:** Split `lib/features/chat/data/offline_first_chat_repository.dart` into smaller collaborators (e.g., `ChatSyncOperationFactory` for sync payloads, `ChatLocalConversationUpdater` for local persistence and merge logic). Inject collaborators so `OfflineFirstChatRepository` focuses on orchestration and delegates persistence/mapping.
- **High Acceptance Criteria:** `OfflineFirstChatRepository` delegates sync payload creation and local persistence; new collaborators have focused unit tests; method bodies are shorter and more readable.
- **High Verification Commands:** `rg \"ChatSyncOperationFactory|ChatLocalConversationUpdater\" lib/features/chat -g\"*.dart\"` and `rg \"OfflineFirstChatRepository\" -n lib/features/chat/data/offline_first_chat_repository.dart`.
- **Medium:** Audit presentation entrypoints for concrete data-layer types.
- **Medium Instructions:** Search `lib/features/**/presentation` for imports from `lib/features/**/data` and replace dependencies with domain/shared interfaces; update DI bindings where needed. Allow exceptions only for tooling/debug widgets.
- **Medium Acceptance Criteria:** No presentation modules import data-layer classes unless explicitly exempted; interface usage is consistent across feature pages and widgets.
- **Medium Verification Commands:** `rg \"features/.*/data\" lib/features -g\"*presentation*.dart\"` and `rg \"// check-ignore\" lib/features -g\"*presentation*.dart\"`.
- **Low:** Add SOLID review items to dev checklists/templates.
- **Low Instructions:** Update `docs/flutter_best_practices_review.md` or `docs/new_developer_guide.md` with a brief checklist item that calls out interface-driven boundaries and disallows presentation-level data-layer imports.
- **Low Acceptance Criteria:** Documentation includes a clear, one-line SOLID verification step and references the interface-first rule.
- **Low Verification Commands:** `rg \"SOLID\" docs/flutter_best_practices_review.md docs/new_developer_guide.md` and `rg \"interface\" docs/flutter_best_practices_review.md docs/new_developer_guide.md`.

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
