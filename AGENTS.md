# AGENTS — Flutter BLoC App

Keep work lean, clean, and tested.

## Quick Checklist

1. `dart format .`
2. `flutter analyze`
3. `flutter test`
4. If Freezed/JSON models changed → `dart run build_runner build --delete-conflicting-outputs`

## Architecture Rules

- Enforce **Clean Architecture**: Domain → Data → Presentation only.
- Follow MVP: Widgets (View) ↔ Cubits (Presenter) ↔ Repositories/Models.
- Apply SOLID & Clean Code: expressive names, small units, limited side effects.
- UI-only state stays under `presentation/*`; domain models remain UI agnostic.
- Use `TimerService` (& `FakeTimerService` in tests) for timed behaviour.

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

## Commands

```bash
flutter pub get
dart format .
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
flutter run
```

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
