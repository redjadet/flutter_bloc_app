# AGENTS Guide — Flutter BLoC App

Keep the architecture clean, tests green, and generated files up to date. Follow the checklist, then check the references when needed.

## Daily Checklist

1. `dart format .`
2. `flutter analyze`
3. `flutter test`
4. If freezed/json_serializable changes → `dart run build_runner build --delete-conflicting-outputs`

## Core Rules

- Uphold Clean Architecture: **Domain → Data → Presentation** only.
- MVP split: Widgets (View) ↔︎ Cubits (Presenter) ↔︎ Repositories/Models.
- Apply SOLID + Clean Code (expressive naming, small units, limited side effects).
- UI-only state stays in `presentation/*`; domain models remain UI-agnostic.
- Compose small widgets; use `TimerService` for timed behaviour (`FakeTimerService` in tests).
- Add or update tests with every behavioural change.

## Project Map

- `lib/features/<feature>/{domain,data,presentation}` — feature packages.
- `lib/core/` — DI (`injector.dart`), time utilities, constants.
- `lib/shared/` — reusable widgets, logger, platform helpers.
- `test/` — mirrors features: bloc, widget, golden, auth, fakes.

## Typical Workflow

1. Adjust domain contracts/models.
2. Implement/update repositories in data layer and register via `get_it`.
3. Extend Cubits/Blocs in presentation; inject dependencies.
4. Build UI with focused widgets; keep business logic in cubits/domain.
5. Write/refresh unit–bloc–widget–golden tests (use fakes for determinism).

## Testing Focus

- Bloc flows with `bloc_test`.
- Widget + golden regressions (Countdown, CounterDisplay, etc.).
- Auth flows with `MockFirebaseAuth`, `mock_exceptions`.
- Deterministic time: `FakeTimerService` (`fake.tick(n)`).

## Command Reference

```bash
flutter pub get
dart format .
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## DI & Data Swap Example

```dart
Future<void> runAppWithFlavor(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorManager.set(flavor);
  await PlatformInit.initialize();
  await configureDependencies();
  runApp(const MyApp());
}

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

```dart
abstract class CounterRepository {
  Future<CounterSnapshot> load();
  Future<void> save(CounterSnapshot snapshot);
}

class RestCounterRepository implements CounterRepository {
  @override
  Future<CounterSnapshot> load() async => const CounterSnapshot(count: 0);

  @override
  Future<void> save(CounterSnapshot snapshot) async {}
}

getIt.unregister<CounterRepository>();
getIt.registerLazySingleton<CounterRepository>(() => RestCounterRepository());
```

## Extras

- Auto-decrement interval = 5s; counter never goes negative.
- Supported locales: see `MaterialApp.supportedLocales`.
- Platform info comes from `NativePlatformService` (MethodChannel).
