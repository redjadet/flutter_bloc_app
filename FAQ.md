# FAQ

## How does the counter UI update when the count changes?

Pressing the `+` button triggers `CounterActions.increment()`, which calls `CounterCubit.increment()`. The cubit emits a new `CounterState.success` via `_emitCountUpdate`, persists the snapshot, and keeps the countdown ticker alive. `CounterDisplay` listens through a `BlocSelector`, so only the counter-specific widgets rebuild—`CounterValueText` animates the new value, the status chip/countdown visuals update, and the now-idle snack bar listener hides errors when the count moves above zero.

## Why is the snack bar dismissed when the counter goes above zero?

`CounterPage` includes a `BlocListener` that watches for the state change `count: 0 → >0`. As soon as that transition happens, it calls `ScaffoldMessenger.of(context).hideCurrentSnackBar()`. This ensures “cannot go below zero” warnings clear immediately once the user increments.

## Why is Flutter used instead of writing separate native apps?

- A single app shell keeps routing, authentication, theming, and localization in one code path, so iOS and Android stay aligned without duplicating platform scaffolding (`lib/app.dart`).
- Feature logic sits in platform-agnostic cubits and repositories, letting both platforms reuse timer-driven counters, persistence, and error handling (`lib/features/counter/presentation/counter_cubit.dart`).
- Shared dependencies (Firebase, maps, sockets) are configured once and versioned together, avoiding drift between native stacks (`pubspec.yaml`).
- Tests exercise the same Bloc flows and persistence behavior once, guaranteeing consistent results on every platform without parallel XCTest/Instrumented suites (`test/counter_cubit_test.dart`).
- Cross-cutting tooling—dependency injection, flavor management, responsive layout—already wraps platform services in reusable layers, so new features land simultaneously across devices (`lib/app.dart`).

## How do chat history actions work after the recent splits?

`ChatCubit` now mixes in purpose-specific helpers: `_ChatCubitHistoryActions` (loading/clearing/deleting/resetting history), `_ChatCubitMessageActions` (sending prompts and persisting responses), and `_ChatCubitSelectionActions` (switching models or conversations). Shared utilities like `_persistHistory`, `_replaceConversation`, and `_resolveModelForConversation` live in `_ChatCubitHelpers`, so each mixin stays focused and testable.

## How does dependency injection wire the counter repositories?

`core/di/injector.dart` lazily registers repositories via `get_it`. For the counter feature, it tries the Firebase-backed repository when Firebase is available; otherwise it falls back to the SharedPreferences implementation. In tests, helpers override `getIt` registrations or inject mock repositories directly into cubits.

## What linting and formatting routines should I run?

The project uses standard `flutter analyze`, `dart format .`, and a custom lint (`dart run custom_lint`) that checks for long files (>250 lines) in production code. Tests and tooling are excluded from the custom lint, but core feature files are expected to stay under the limit. Running all three commands before committing keeps warnings and formatting consistent.

## Why keep golden/widget/bloc tests together?

Golden tests (e.g., `test/counter_page_golden_test.dart`) verify layout regressions for the counter UI. Widget tests (`chat_history_sheet_test.dart`) cover interactions such as clearing/deleting history without hitting real storage, and bloc/unit tests ensure repositories/cubits produce expected states. Running these in CI (and via the documented checklist) catches UI/state regressions early.
