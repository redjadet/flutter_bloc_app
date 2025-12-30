# Flutter + Mobile Best Practices Review

**Scope:** Quick audit of configuration, bootstrap, app shell, and representative feature layers (counter, settings, auth, profile, shared utilities). Findings focus on Flutter/mobile best practices, architecture hygiene, and UI adaptiveness.

## Table of Contents

- [Strengths Observed](#strengths-observed)
- [Opportunities / Risks](#opportunities--risks)
- [Architecture Reviews](#architecture-reviews)
  - [Clean Architecture](#clean-architecture-review)
  - [DRY Principles](#dry-review)
  - [State Management](#state-management-review)
  - [SOLID Principles](#solid-principles-review)
- [Unified Action Checklist](#unified-action-checklist)
  - [High Priority](#high-priority)
  - [Medium Priority](#medium-priority)
  - [Low Priority](#low-priority)

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

## Architecture Reviews

### Clean Architecture Review

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

### DRY Review

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

### State Management Review

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

### SOLID Principles Review

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

## Unified Action Checklist

This checklist organizes actionable improvements by priority. Each item includes acceptance criteria, verification steps, and dependencies.

**Legend:**

- **Effort:** XS (<0.5d) | S (0.5-1d) | M (1-2d) | L (2-5d)
- **Status:** ⬜ Not Started | 🟡 In Progress | ✅ Complete | ⏸️ Blocked

### High Priority

These items address potential bugs, performance issues, or architectural violations that could cause production problems.

#### 1. AppShell: Fix Side Effects in `build()` Method

**Owner:** Mobile Platform
**Effort:** M (1-2 days)
**Status:** ⬜
**Files:** `lib/app/app_scope.dart`

**Problem:** `AppScope.build()` triggers DI configuration and background sync startup on every build, risking duplicate work on hot reload/rebuilds.

**Solution:**

1. Convert `AppScope` from `StatelessWidget` to `StatefulWidget`
2. Move `ensureConfigured()` and `syncCoordinator.start()` to `initState()`
3. Add idempotency guards (static flag or DI-level "started" check)
4. Ensure `dispose()` properly cleans up if needed

**Acceptance Criteria:**

- [ ] `AppScope` is a `StatefulWidget` with `initState()` lifecycle
- [ ] `ensureConfigured()` and `syncCoordinator.start()` called only once per widget lifecycle
- [ ] Widget test verifies coordinator start count is 1 after multiple rebuilds
- [ ] Hot reload doesn't trigger duplicate initialization
- [ ] All existing tests pass

**Test Requirements:**

- Add `test/app/app_scope_test.dart` with rebuild verification
- Mock `BackgroundSyncCoordinator` and verify `start()` called exactly once
- Test hot reload scenario (rebuild widget multiple times)

**Verification:**

```bash
flutter test test/app/app_scope_test.dart
flutter run --hot-reload  # Verify no duplicate initialization logs
```

---

#### 2. Architecture: Enforce Flutter-Agnostic Domain Layer

**Owner:** Platform
**Effort:** XS (<0.5 day)
**Status:** ⬜
**Files:** `lib/core/di/injector.dart`, `lib/core/di/injector_registrations.dart`, `lib/core/di/injector_factories.dart`

**Problem:** Risk of domain types importing Flutter, breaking clean architecture boundaries.

**Solution:**

1. Add PR checklist item: "Domain imports must be Dart-only (no `package:flutter`)"
2. Document enforcement in project guidelines or `docs/clean_architecture.md`
3. Add code review guidance referencing DI registration patterns

**Acceptance Criteria:**

- [ ] PR template or checklist includes domain layer validation
- [ ] Documentation updated with enforcement guidance
- [ ] Review process includes domain import check
- [ ] Example violations documented for reference

**Verification:**

```bash
# Search for Flutter imports in domain layer
grep -r "package:flutter" lib/features/*/domain/ || echo "No violations found"
```

---

#### 3. Data Layer: Enforce `HiveRepositoryBase` Usage

**Owner:** Platform
**Effort:** XS (<0.5 day)
**Status:** ⬜
**Files:** `lib/shared/storage/hive_repository_base.dart`, `lib/shared/storage/hive_settings_repository.dart`

**Problem:** Direct `Hive.openBox()` usage bypasses centralized Hive management.

**Solution:**

1. Document requirement: new Hive repos must extend `HiveRepositoryBase` or `HiveSettingsRepository<T>`
2. Add grep/lint check for `Hive.openBox(` outside `lib/shared/storage/`
3. Update project guidelines with enforcement guidance

**Acceptance Criteria:**

- [ ] Documentation updated with Hive repository requirements
- [ ] Lint/search script identifies violations
- [ ] Review process checks for base class usage
- [ ] Existing violations documented (if any)

**Verification:**

```bash
# Find direct Hive.openBox usage
grep -r "Hive\.openBox" lib/features/ lib/core/ | grep -v "lib/shared/storage" || echo "No violations"
```

---

#### 4. State: Guard Async Emissions with `isClosed` Checks

**Owner:** Feature Dev
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:** All cubit files, `lib/shared/utils/cubit_subscription_mixin.dart`

**Problem:** Async callbacks can emit after cubit is closed, causing errors.

**Solution:**

1. Audit all cubits for async operations without `isClosed` guards
2. Add `isClosed` checks before all `emit()` calls in async callbacks
3. Use `CubitSubscriptionMixin` for stream subscriptions
4. Ensure `close()` cancels all timers/streams

**Acceptance Criteria:**

- [ ] All async `emit()` calls guarded with `if (isClosed) return;`
- [ ] Subscriptions use `CubitSubscriptionMixin` or manual cleanup in `close()`
- [ ] `close()` cancels all timers, streams, and completers
- [ ] Widget tests verify no emissions after disposal

**Test Requirements:**

- Add test that disposes cubit during async operation
- Verify no exceptions from post-disposal emissions

**Verification:**

```bash
flutter test --concurrency=1  # Catch race conditions
flutter analyze  # Check for unguarded emits
```

---

#### 5. State: Keep App State in Cubits, Reserve `setState` for UI-Only

**Owner:** Feature Dev
**Effort:** XS (<0.5 day)
**Status:** ⬜
**Files:** All presentation widgets

**Problem:** Business logic state mixed with UI state reduces testability and separation.

**Solution:**

1. Audit widgets for non-trivial state in `setState`
2. Move business logic state to cubits
3. Keep `setState` only for transient UI concerns (loading spinners, form focus)
4. Update documentation with examples

**Acceptance Criteria:**

- [ ] No business logic state in `setState` blocks
- [ ] `setState` used only for UI-only toggles (loading, focus, visibility)
- [ ] Documentation updated with state management guidelines
- [ ] Examples added to `docs/` or project guidelines

**Verification:**

```bash
# Search for setState usage (manual review needed)
grep -r "setState" lib/features/*/presentation/
```

---

### Medium Priority

These items improve code quality, maintainability, and reduce technical debt.

#### 6. Architecture: Avoid Direct `GetIt` Access in Presentation

**Owner:** Feature Dev
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:**

- `lib/features/settings/presentation/widgets/graphql_cache_controls_section.dart`
- `lib/features/counter/presentation/widgets/counter_sync_queue_inspector_button.dart`

**Problem:** Direct `GetIt` access bypasses cubit boundaries and weakens separation.

**Solution:**

1. Audit all presentation widgets for direct `GetIt` usage
2. Inject dependencies via constructors or cubits
3. Document exception for debug/tooling widgets
4. Migrate affected widgets to use cubits or constructor injection

**Acceptance Criteria:**

- [ ] All non-tooling widgets use constructor injection or cubits
- [ ] Debug widgets documented as exception
- [ ] No `GetIt` calls in production presentation code (except documented exceptions)
- [ ] Tests updated to use injected dependencies

**Verification:**

```bash
grep -r "getIt<" lib/features/*/presentation/ | grep -v "test" | grep -v "debug"
```

---

#### 7. State: Use `TimerService` for All Timers

**Owner:** Feature Dev
**Effort:** XS (<0.5 day)
**Status:** ⬜
**Files:** All cubits and widgets, `lib/core/time/timer_service.dart`

**Problem:** Direct `Timer` usage makes tests non-deterministic.

**Solution:**

1. Search for direct `Timer` usage
2. Replace with `TimerService` or `TimerDisposable`
3. Update tests to use `FakeTimerService`
4. Document pattern in project guidelines

**Acceptance Criteria:**

- [ ] No direct `Timer` usage in feature code
- [ ] All timers use `TimerService` abstraction
- [ ] Tests use `FakeTimerService` for deterministic behavior
- [ ] Documentation updated with timer patterns

**Verification:**

```bash
grep -r "Timer(" lib/features/ lib/core/ | grep -v "TimerService" | grep -v "test"
```

---

Additional medium-priority items focus on consistency, UX, and developer experience.

#### 8. UI Foundations: Route Buttons Through `PlatformAdaptive`

**Owner:** Design Systems
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:**

- `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`
- `lib/features/auth/presentation/widgets/register_terms_section.dart`
- `lib/features/auth/presentation/widgets/register_phone_field.dart`
- `lib/features/profile/presentation/widgets/profile_action_buttons.dart`

**Problem:** Raw Material buttons drift from Cupertino behavior and app-wide styling.

**Solution:**

1. Create `lib/shared/widgets/common_buttons.dart` if needed
2. Replace `ElevatedButton`/`OutlinedButton`/`TextButton` with `PlatformAdaptive.*` wrappers
3. Extract shared button styles to helper file
4. Update all affected widgets

**Acceptance Criteria:**

- [ ] All buttons use `PlatformAdaptive.filledButton`, `PlatformAdaptive.button`, or `PlatformAdaptive.textButton`
- [ ] Button styles extracted to shared helper
- [ ] iOS/Android behavior consistent across app
- [ ] Widget tests verify platform-adaptive behavior
- [ ] Visual regression tests pass

**Test Requirements:**

- Widget tests for iOS vs Android button rendering
- Golden tests if applicable

**Verification:**

```bash
# Find remaining Material buttons
grep -r "ElevatedButton\|OutlinedButton\|TextButton" lib/features/*/presentation/ | grep -v "PlatformAdaptive" | grep -v "test"
flutter test
```

---

#### 9. UX/Accessibility: Fix Fixed-Position Layout Issues

**Owner:** QA + Design
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:**

- `lib/features/auth/presentation/widgets/logged_out_page_body.dart`
- `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`

**Problem:** Fixed positioning struggles with text scale, keyboard insets, and device cutouts.

**Solution:**

1. Test with text scale >= 1.3
2. Test in landscape orientation
3. Test on devices with notches/cutouts
4. Replace fixed offsets with flexible constraints or safe-area padding
5. Add keyboard insets handling

**Acceptance Criteria:**

- [ ] Layout works with text scale 1.0-2.0
- [ ] No clipped content in landscape
- [ ] Safe area padding respects device cutouts
- [ ] Keyboard doesn't obscure content
- [ ] Accessibility audit passes

**Test Requirements:**

- Manual testing on iOS/Android with various text scales
- Device testing with notches
- Keyboard interaction testing

**Verification:**

```bash
# Manual testing checklist
# - [ ] Text scale 1.0, 1.3, 1.5, 2.0
# - [ ] Portrait and landscape
# - [ ] iPhone with notch, Android with cutout
# - [ ] Keyboard open/close
```

---

#### 10. State: Route Async Error Handling Through `CubitExceptionHandler`

**Owner:** Feature Dev
**Effort:** XS (<0.5 day)
**Status:** ⬜
**Files:** All cubits, `lib/shared/utils/cubit_async_operations.dart`

**Problem:** Ad-hoc try/catch blocks duplicate error handling logic.

**Solution:**

1. Audit cubits for ad-hoc try/catch
2. Replace with `CubitExceptionHandler` usage
3. Ensure `ViewStatus` transitions are consistent
4. Verify `isClosed` checks in error paths

**Acceptance Criteria:**

- [ ] All async cubit operations use `CubitExceptionHandler`
- [ ] Error states use consistent `ViewStatus` transitions
- [ ] `isClosed` checks in all error callbacks
- [ ] Documentation updated with error handling pattern

**Verification:**

```bash
# Find ad-hoc try/catch in cubits
grep -r "try {" lib/features/*/presentation/cubit/ | grep -v "CubitExceptionHandler"
```

---

#### 11. SOLID: Enforce Constructor Injection of Abstractions

**Owner:** Platform
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:** `lib/core/di/`, all feature constructors

**Problem:** Concrete dependencies reduce testability and violate DIP.

**Solution:**

1. Add review guidance: constructors take interfaces, not implementations
2. Audit DI registrations for concrete types
3. Split classes that combine orchestration, storage, and UI concerns
4. Update project guidelines with SOLID enforcement

**Acceptance Criteria:**

- [ ] All constructors accept interfaces/abstractions
- [ ] DI registrations use interface types
- [ ] Multi-responsibility classes split
- [ ] Review checklist includes SOLID checks

**Verification:**

```bash
# Review DI registrations (manual)
# Check for concrete types in constructors
```

---

#### 12. SOLID: Implement Repository Interfaces for New Data Sources

**Owner:** Feature Dev
**Effort:** XS (<0.5 day)
**Status:** ⬜
**Files:** All repository implementations

**Problem:** Extending existing classes instead of implementing interfaces reduces flexibility.

**Solution:**

1. Document pattern: new data sources implement domain interfaces
2. Avoid adding optional methods to existing interfaces
3. Create new repository implementations per data source
4. Register in DI via interfaces

**Acceptance Criteria:**

- [ ] New repos implement domain interfaces
- [ ] No optional methods added to existing interfaces
- [ ] Each data source has separate implementation
- [ ] DI registrations use interface types

**Verification:**

- Code review process
- Reference `lib/features/*/domain/*_repository.dart` patterns

---

### Low Priority

These items are nice-to-have improvements that can be addressed when time permits.

#### 13. UI Foundations: Consolidate Typography into Theme

**Owner:** Design Systems
**Effort:** S (0.5-1 day)
**Status:** ⬜
**Files:** `lib/core/app_config.dart`, `lib/features/auth/presentation/widgets/logged_out_action_buttons.dart`

**Problem:** Per-widget `GoogleFonts` usage reduces consistency and text scaling support.

**Solution:**

1. Move custom `GoogleFonts` usage into Theme `TextTheme`
2. Update widgets to use `Theme.of(context).textTheme.*`
3. Ensure text scale factors work correctly
4. Update theme configuration

**Acceptance Criteria:**

- [ ] No per-widget `GoogleFonts` declarations
- [ ] Typography defined in `AppConfig` theme
- [ ] Text scale factors work correctly
- [ ] Consistent typography across app

**Verification:**

```bash
grep -r "GoogleFonts\." lib/features/*/presentation/ | grep -v "test"
```

---

## Implementation Notes

### Dependencies

- **Item 1** (AppScope) should be completed first as it affects app initialization
- **Item 8** (PlatformAdaptive buttons) can be done in parallel with **Item 9** (Accessibility)
- **Item 4** (isClosed guards) should be done before **Item 10** (Error handling)
- **Item 3** (Hive base classes) should be done before creating new repositories

### Testing Strategy

- Run `./bin/checklist` after each item
- Add regression tests for critical fixes (Items 1, 4, 5)
- Update golden tests if UI changes (Items 8, 9, 13)
- Verify coverage impact with `dart run tool/update_coverage_summary.dart`

### Tracking Progress

Update status emoji (⬜ 🟡 ✅ ⏸️) in this document as items progress. Consider using a project management tool for detailed tracking.
