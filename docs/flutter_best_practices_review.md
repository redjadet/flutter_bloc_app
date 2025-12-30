# Flutter + Mobile Best Practices Review

Scope: quick audit of configuration, bootstrap, app shell, and representative
feature layers (counter, settings, auth, profile, shared utilities). Findings
focus on Flutter/mobile best practices, architecture hygiene, and UI
adaptiveness.

## Strengths Observed

- Strict static analysis and linting are enabled with a custom file-length
  constraint, encouraging maintainable file sizes and high signal linting.
  See `analysis_options.yaml`.
- Bootstrap sequence is explicit and defensive: platform init, secrets, app
  version, Firebase setup, DI wiring, and migrations are ordered and guarded.
  See `lib/core/bootstrap/bootstrap_coordinator.dart`.
- Clean architecture is consistent across features (domain/data/presentation),
  with Cubit-based state and immutable models. See `lib/features/counter/`,
  `lib/features/settings/`.
- Timer usage is centralized behind a service abstraction instead of raw
  `Timer` usage, aiding testability. See `lib/core/time/timer_service.dart`,
  `lib/features/counter/presentation/counter_cubit.dart`.
- Responsive and adaptive styling is centralized via extensions and a shared
  scope, and Material 3 theming is configured at the app level.
  See `lib/shared/extensions/responsive.dart`, `lib/app/app_scope.dart`,
  `lib/core/app_config.dart`.
- Localization is first-class with explicit delegates and locale resolution.
  See `lib/core/app_config.dart`.

## Opportunities / Risks

- Side effects in `build`: `AppScope.build` triggers DI configuration and
  background sync startup on every build. This risks duplicated work on hot
  reload or rebuilds and makes side effects harder to reason about. Consider
  moving to `initState` of a StatefulWidget or making the start calls strictly
  idempotent. See `lib/app/app_scope.dart`.
- Platform-adaptive widgets are used in many places, but some screens still
  instantiate raw Material buttons, which can drift from Cupertino behavior
  and app-wide button styling. Consider routing these through the shared
  adaptive wrappers or shared button styles for consistent look/feel and
  semantics:
  - `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`
  - `lib/features/auth/presentation/widgets/register_terms_section.dart`
  - `lib/features/auth/presentation/widgets/register_phone_field.dart`
  - `lib/features/profile/presentation/widgets/profile_action_buttons.dart`
- Figma-driven, absolute-position layouts are used in the logged-out flow.
  While the scale math helps, fixed positioning can still struggle with text
  scale, keyboard insets, and unusual aspect ratios. Consider validating
  against accessibility text sizes and device cutouts, and prefer layout
  primitives that can reflow. See
  `lib/features/auth/presentation/widgets/logged_out_page_body.dart` and
  `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`.
- Typography is customized in individual widgets (e.g., per-button
  `GoogleFonts.roboto`). If consistent typography is a goal, consider moving
  these into the Theme so text scale, contrast, and platform defaults stay
  centralized. See
  `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`.

## Clean Architecture Review

- Feature modules are consistently split into `domain/`, `data/`, and
  `presentation/`, with domain types free of Flutter imports.
  Example: `lib/features/search/domain/search_repository.dart`,
  `lib/features/chat/domain/chat_repository.dart`.
- Data implementations follow repository interfaces and include offline-first
  orchestration where appropriate (e.g., chat). See
  `lib/features/chat/data/offline_first_chat_repository.dart`.
- DI wiring is centralized under `lib/core/di/`, keeping construction separate
  from UI layers.
- Risk: a few presentation widgets fetch repositories via `GetIt` or call
  repo methods directly (e.g., cache controls, sync inspectors). This is
  sometimes acceptable for UI-only tooling, but it does bypass Cubit boundaries
  and can weaken the separation if it spreads.

## DRY Review

- Strong reuse is present via `HiveRepositoryBase` and
  `HiveSettingsRepository<T>` for persistence. See
  `lib/shared/storage/hive_repository_base.dart`,
  `lib/shared/storage/hive_settings_repository.dart`.
- Shared async/error handling is consolidated via `CubitExceptionHandler`,
  `StorageGuard`, `InitializationGuard`, and `BlocProviderHelpers`. See
  `lib/shared/utils/cubit_async_operations.dart`,
  `lib/shared/utils/bloc_provider_helpers.dart`.
- Opportunity: button styles and interaction patterns repeat in auth/profile
  widgets. If more screens follow the same Figma patterns, consider extracting
  shared styles/widgets to avoid drift.

## State Management Review

- Cubit is the primary state mechanism with immutable `freezed`/`Equatable`
  states and a shared `ViewStatus` model for UI state.
- Async workflows often use `CubitExceptionHandler` and guard emissions with
  `isClosed` checks (e.g., counter/search), reducing lifecycle errors.
  See `lib/features/counter/presentation/counter_cubit.dart`,
  `lib/features/search/presentation/search_cubit.dart`.
- Subscriptions are centralized via `CubitSubscriptionMixin` where used,
  improving cleanup patterns.
- Local UI state uses `setState` only for transient view concerns (e.g., loading
  spinners), which is appropriate.

## SOLID Principles Review

- SRP: Most files keep a narrow purpose (e.g., cubits orchestrate state, widgets
  handle layout, repositories encapsulate data access). The `Hive*Repository`
  base classes reinforce single-purpose storage behavior.
- OCP: Repository interfaces and offline-first adapters allow extension via new
  implementations without changing calling code (e.g., chat/search repositories).
- LSP: Abstractions are largely contract-safe (repos return domain types, cubits
  expose consistent state), though some presentation widgets directly access
  concrete repos, which can reduce substitutability if expanded.
- ISP: Interfaces remain lean (e.g., `SearchRepository`, `ThemeRepository`),
  keeping consumers focused on required behavior.
- DIP: Dependency injection is centralized, and most features depend on
  abstractions. Minor drift exists where widgets use `GetIt` directly for
  concrete repos.

## Unified Action Checklist (Owners + Effort + Priority)

- AppShell (Owner: Mobile Platform) — Refactor `AppScope` startup side effects
  to run once (or enforce idempotency) and add a regression test if needed.
  Move `ensureConfigured()` and `syncCoordinator.start()` to a `StatefulWidget`
  `initState`, or gate them behind a static/DI-level "started" flag; add a
  widget test to ensure multiple rebuilds do not re-trigger work.
  Effort: M (1-2 days) | Priority: High
- UI Foundations (Owner: Design Systems) — Route auth/profile buttons through
  `PlatformAdaptive.*` or shared styles; extract shared widgets once patterns
  repeat across 3+ screens.
  Replace direct `ElevatedButton`/`OutlinedButton` usage with shared helpers or
  `PlatformAdaptive` wrappers; factor button styles into a single helper file
  and migrate affected widgets in auth/profile.
  Effort: S (0.5-1 day) | Priority: Medium
- UX/Accessibility (Owner: QA + Design) — Accessibility pass on fixed-position
  logged-out layout: large text, keyboard insets, and cutouts.
  Validate with text scale >= 1.3, landscape, and devices with notches; adjust
  layout to avoid clipped content (e.g., replace fixed offsets with flexible
  constraints or add safe-area padding).
  Effort: S (0.5-1 day) | Priority: Medium
- UI Foundations (Owner: Design Systems) — Consolidate per-widget fonts into
  theme typography for consistency and scaling.
  Move custom `GoogleFonts` usage into Theme `TextTheme`, then update widgets
  to use theme styles instead of per-widget font declarations.
  Effort: S (0.5-1 day) | Priority: Low
- Architecture (Owner: Platform) — Keep new domain types Flutter-agnostic and
  wire feature construction through `lib/core/di/`.
  Add a lightweight checklist for PRs: domain imports must be Dart-only, and
  constructors should be wired in `injector_*` files rather than widgets.
  Effort: XS (<0.5 day) | Priority: High
- Architecture (Owner: Feature Dev) — Avoid direct `GetIt` access in
  presentation widgets unless tooling-only; prefer cubit/repo abstraction
  boundaries.
  Inject dependencies via widget constructors or cubits; limit direct `GetIt`
  access to debug tooling widgets and document the exception.
  Effort: S (0.5-1 day) | Priority: Medium
- Data Layer (Owner: Platform) — Use `HiveRepositoryBase` or
  `HiveSettingsRepository<T>` for new Hive-backed repositories.
  New Hive repos should extend the base classes and use `HiveService.openBox`;
  disallow direct `Hive.openBox` usage in feature code.
  Effort: XS (<0.5 day) | Priority: High
- State Layer (Owner: Feature Dev) — Route async error handling through
  `CubitExceptionHandler` or shared guards.
  Replace ad-hoc try/catch in cubits with `CubitExceptionHandler` and standard
  `ViewStatus` transitions; ensure onError paths handle `isClosed`.
  Effort: XS (<0.5 day) | Priority: Medium
- State (Owner: Feature Dev) — Keep app state in cubits; reserve `setState`
  for UI-only concerns.
  Move non-trivial state into cubits and keep `setState` to simple UI toggles;
  update docs or samples if new patterns appear.
  Effort: XS (<0.5 day) | Priority: High
- State (Owner: Feature Dev) — Guard async emissions with `isClosed` checks and
  cancel subscriptions in `close()` (or use `CubitSubscriptionMixin`).
  Add `isClosed` checks in async callbacks and consolidate subscriptions via
  `CubitSubscriptionMixin`; ensure `close()` cancels timers/streams.
  Effort: S (0.5-1 day) | Priority: High
- State (Owner: Feature Dev) — Use `TimerService` for debouncing/timers.
  Replace direct `Timer` usage with `TimerService` or `TimerDisposable` to keep
  tests deterministic and use fake timers in tests.
  Effort: XS (<0.5 day) | Priority: Medium
- SOLID (Owner: Platform) — Enforce constructor injection of abstractions and
  split multi-responsibility classes when they combine orchestration, storage,
  and UI concerns.
  Add review guidance: constructors take interfaces, not implementations, and
  split classes that both orchestrate flows and perform storage or UI updates.
  Effort: S (0.5-1 day) | Priority: Medium
- SOLID (Owner: Feature Dev) — Add new data sources by implementing domain
  repository interfaces rather than extending existing classes.
  Create a new repository implementation per data source and register it in
  DI; avoid adding optional methods to existing interfaces.
  Effort: XS (<0.5 day) | Priority: Medium
