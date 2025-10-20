# AGENTS — Flutter BLoC App

Keep work lean, clean, and tested.

## Quick Checklist

1. `flutter pub get`
2. `dart format .`
3. `flutter analyze`
4. `flutter test --coverage`
5. `flutter build ios --simulator`
6. `dart run tool/update_coverage_summary.dart`
7. If Freezed/JSON models changed → `dart run build_runner build --delete-conflicting-outputs`

## Architecture Rules

- Enforce **Clean Architecture**: Domain → Data → Presentation only.
- Follow MVP: Widgets (View) ↔ Cubits (Presenter) ↔ Repositories/Models.
- Apply SOLID & Clean Code: expressive names, small units, limited side effects.
- UI-only state stays under `presentation/*`; domain models remain UI agnostic.
- Use `TimerService` (& `FakeTimerService` in tests) for timed behaviour.

## Code Rules

- Honor layer boundaries: domain stays Flutter-agnostic; data implements domain contracts only; presentation depends on abstractions, never concrete data sources.
- Keep business logic inside domain use cases or cubits; widgets are limited to view concerns (layout, theming, navigation hooks).
- Register every repository/service in `get_it`; avoid `new`ing dependencies in widgets or cubits unless they are pure value objects.
- Make all cubit states immutable and `Equatable`/`freezed`; expose derived values with getters instead of mutable fields.
- Ban unhandled `async` work: await futures, avoid `async void` outside callbacks, and route errors through domain failures or `ErrorHandling` helpers.
- Guard architecture with imports: no `../../data` or `../../presentation` jumps; shared utilities live under `lib/shared/` only when cross-cutting.
- Timer or clock logic must pass through `TimerService` (or `FakeTimerService` in tests) to keep flows deterministic.
- Any new feature ships with matching `bloc_test` coverage and, when UI surfaces change, widget/golden tests; keep coverage scripts up to date.
- Respect lint configuration: fix violations instead of disabling rules; if ignoring is unavoidable, annotate with a TODO and owner.
- Adhere to size limits: keep hand-written files under ~250 lines—extract widgets/helpers once you approach the threshold.
- Resolve markdown lint warnings before wrapping up a task so future runs start clean.

## Workflow

1. Update domain contracts/models.
2. Implement data repositories and register via `get_it`.
3. Extend Cubits/Blocs; inject dependencies.
4. Build UI with focused widgets; keep business rules in cubits/domain.
5. Add or update unit/bloc/widget/golden tests; use fakes for determinism.

## Testing Focus

- `bloc_test` for state flows.
- Widget/golden coverage for UI regressions (CountdownBar, CounterDisplay, etc.).
- Auth flows with `MockFirebaseAuth` + `mock_exceptions`.
- Deterministic time: `FakeTimerService().tick(n)`.
- Abort any test run exceeding 3 minutes and investigate stuck timers, unawaited futures, or hanging platform calls before rerunning.
- Cover platform contracts: update `NativePlatformService` fakes alongside channel changes and add integration coverage for new platform behaviour.

## DI Snippet

```dart
return MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => CounterCubit(
        repository: getIt<CounterRepository>(),
        timerService: getIt(),
      )..loadInitial(),
    ),
    BlocProvider(
      create: (_) => ThemeCubit(
        repository: getIt<ThemeRepository>(),
      )..loadInitial(),
    ),
  ],
  child: ...,
);
```

## Notes

- Auto-decrement interval = 5 s; counter never goes below 0.
- Supported locales: `MaterialApp.supportedLocales`.
- Platform info comes from `NativePlatformService` (MethodChannel).
- Counter UI widgets now live under `lib/features/counter/presentation/widgets/` (exported via `features/counter.dart`).
- Theme & locale contracts + cubits reside in `lib/features/settings/`; keep `lib/shared/` for cross-cutting utilities only.
- After modifying tests, rerun coverage (`flutter test --coverage` + `dart run tool/update_coverage_summary.dart`) to keep reports current.
- Keep hand-written `.dart` files under ~250 lines; split out widgets/helpers when approaching the limit (ignore generated and localization files).
