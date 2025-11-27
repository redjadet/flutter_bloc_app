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

## Why pick Flutter over React Native for this codebase?

- Rendering, navigation, and localization already compose through Flutter-native tools (Material 3, `GoRouter`, `ScreenUtil`), so we lean on a cohesive widget tree instead of bridging to platform-specific navigation stacks (`lib/app.dart`).
- Strongly typed cubits, states, and domain models give us exhaustiveness and analyzer support that JavaScript/TypeScript cannot enforce the same way, reducing runtime regressions (`lib/features/counter/presentation/counter_cubit.dart`).
- Existing integrations rely on first-party FlutterFire, Google Maps, and platform channels with typed APIs; React Native equivalents would require mixing different community plugins and re-implementing DI bindings (`pubspec.yaml`, `core/di/injector.dart`).
- Bloc/widget tests run on the same Dart VM as production code, so deterministic fakes (e.g., `FakeTimerService`) and golden tests cover UI and logic without spawning multiple JS runtimes (`test/counter_cubit_test.dart`, `test/test_helpers.dart`).
- Custom render timing and countdown visuals are expressed with synchronous widget rebuilds and animation primitives; React Native would add asynchronous bridge hops that complicate the 1 s timer flow and persistence guarantees (`lib/features/counter/presentation/counter_cubit.dart`).

## Why does Flutter scale better than React Native when targeting iOS, Android, and desktop?

- Flutter ships a single rendering engine across mobile and desktop, so widget code (animations, layout, theming) behaves identically without re-implementing platform bridges for macOS/Windows/Linux (`lib/app.dart`, `lib/shared` widgets).
- Desktop targets reuse the same dependency injection graph and repositories used on mobile, keeping services like Firebase, timers, and WebSocket clients consistent everywhere (`core/di/injector.dart`, `lib/features/**`).
- Shared navigation via `GoRouter` lets deep links, authenticated routes, and feature flows stay aligned across every form factor—no need to juggle separate navigation stacks for desktop shells (`lib/app.dart`).
- The counter feature’s timer-driven UX runs on the Dart VM with deterministic `TimerService` abstractions, avoiding React Native’s reliance on platform message loops that vary more on desktop (`lib/features/counter/presentation/counter_cubit.dart`, `test/test_helpers.dart`).
- Flutter’s build pipeline already emits runners for macOS, Windows, and Linux from this repo; adding desktop bundles is primarily a config step, whereas React Native requires additional Electron or community-driven wrappers with their own maintenance burden (`macos/`, `windows/`, `linux/` project directories).

## How do chat history actions work after the recent splits?

`ChatCubit` now mixes in purpose-specific helpers: `_ChatCubitHistoryActions` (loading/clearing/deleting/resetting history), `_ChatCubitMessageActions` (sending prompts and persisting responses), and `_ChatCubitSelectionActions` (switching models or conversations). Shared utilities like `_persistHistory`, `_replaceConversation`, and `_resolveModelForConversation` live in `_ChatCubitHelpers`, so each mixin stays focused and testable.

## How does dependency injection wire the counter repositories?

Dependency injection is organized across multiple files in `core/di/`:

- `injector.dart` - Main file with `configureDependencies()` and public API
- `injector_registrations.dart` - All dependency registrations organized by category
- `injector_factories.dart` - Factory functions for creating repositories
- `injector_helpers.dart` - Helper functions for registration

`configureDependencies()` lazily registers repositories via `get_it`. For the counter feature, it tries the Firebase-backed `RealtimeDatabaseCounterRepository` when Firebase is available; otherwise it falls back to the Hive-based `HiveCounterRepository`. All repositories are registered as lazy singletons. In tests, helpers override `getIt` registrations or inject mock repositories directly into cubits.

## What linting and formatting routines should I run?

The project uses a **delivery checklist** that can be run with a single command: `./bin/checklist` (or `tool/delivery_checklist.sh`). This automatically runs:

1. `dart format .` - Code formatting
2. `flutter analyze` - Static analysis (includes native Dart 3.10 analyzer plugins like `file_length_lint`)
3. `tool/test_coverage.sh` - Runs tests with coverage and automatically updates coverage reports

**Optional:** To use just `checklist` without `./bin/`, add the `bin` directory to your PATH:

```bash
# Temporary (current session only)
export PATH="$PATH:$(pwd)/bin"

# Permanent (add to ~/.zshrc or ~/.bashrc)
export PATH="$PATH:/path/to/flutter_bloc_app/bin"
```

The `file_length_lint` rule is configured as a native Dart 3.10 analyzer plugin in `analysis_options.yaml` and runs automatically with `flutter analyze`. It checks for files exceeding 250 lines and issues warnings. See <https://dart.dev/tools/analyzer-plugins> for more information about analyzer plugins.

## Why keep golden/widget/bloc tests together?

Golden tests (e.g., `test/counter_page_golden_test.dart`) verify layout regressions for the counter UI. Widget tests (`chat_history_sheet_test.dart`) cover interactions such as clearing/deleting history without hitting real storage, and bloc/unit tests ensure repositories/cubits produce expected states. Running these in CI (and via the documented checklist) catches UI/state regressions early.

**Test Coverage:** The project maintains **85.34% line coverage** (6186/7249 lines). Files that don't require tests are automatically excluded from coverage reports:

- Mock repositories (test utilities themselves)
- Simple data classes (Freezed classes, simple Equatable classes)
- Configuration files (files with only constants)
- Debug utilities (performance profiler files)
- Platform-specific widgets (map widgets requiring native testing)
- Part files (tested via parent file)
- Files with `// coverage:ignore-file` comment

See `coverage/coverage_summary.md` for the full breakdown.

## How is local storage handled in this app?

All local persistence goes through **Hive** (encrypted local database), which replaced SharedPreferences. The app uses:

- `HiveService` - Core service wrapping `Hive.initFlutter()` and ensuring every box is opened with an `AES256Cipher`
- `HiveKeyManager` - Generates and manages encryption keys stored in `flutter_secure_storage`
- `HiveRepositoryBase` - Base class for Hive-backed repositories providing common functionality
- `SharedPreferencesMigrationService` - Automatically migrates legacy SharedPreferences data to Hive on first launch

**Important:** Never call `Hive.openBox` directly. Always use `HiveService` and extend `HiveRepositoryBase` for new repositories.

## How does offline-first work in this app?

The app implements a complete offline-first architecture following Flutter's best practices. All core features work seamlessly offline:

- **Background Sync**: `BackgroundSyncCoordinator` automatically syncs pending operations every 60 seconds when online
- **Pending Queue**: `PendingSyncRepository` stores operations that failed while offline; they're automatically processed when connectivity returns
- **Sync Status**: `SyncStatusCubit` tracks network status and sync state; UI widgets show offline/syncing/pending indicators
- **Repository Pattern**: Features implement `OfflineFirst<Feature>Repository` that wraps local (Hive) and remote repositories
- **Sync Metadata**: Domain models include `synchronized`, `lastSyncedAt`, and `changeId` fields for conflict resolution
- **Strategies**:
  - **Write-first** (Counter, Chat): Operations are queued when offline, synced when online
  - **Cache-first** (Search, Profile, Remote Config, GraphQL): Cached data served immediately, refreshed in background when online

See `docs/offline_first/` for detailed documentation and `docs/offline_first/adoption_guide.md` for adding offline-first to new features.

## How are remote images cached?

Remote images are automatically cached using the `cached_network_image` package. Use `CachedNetworkImageWidget` from `lib/shared/widgets/` for network images. It provides:

- Automatic caching of downloaded images
- Loading placeholder support
- Error handling with fallback widget
- Memory-efficient image loading with configurable cache dimensions

`FancyShimmerImage` (used in search/profile/example pages) already includes caching via `cached_network_image` under the hood.

**Testing Note:** When testing widgets that use `CachedNetworkImageWidget`, use `pump()` instead of `pumpAndSettle()` to avoid timeouts. Network requests never complete in test environments, so `pumpAndSettle()` will wait indefinitely.

## How can I profile performance in this app?

The app includes a `PerformanceProfiler` utility (`lib/shared/utils/performance_profiler.dart`) for tracking widget rebuilds and frame performance:

```dart
// Track widget rebuilds
PerformanceProfiler.trackWidget('MyWidget', () => MyWidget());

// Track frame operations
PerformanceProfiler.trackFrame(() {
  // Expensive operation
});

// Print report
PerformanceProfiler.printReport();
```

The profiler is enabled by default in `kDebugMode` and can be controlled via `PerformanceProfiler.setEnabled(enabled: true/false)`.

Additionally, a **Performance Overlay** can be enabled via the `ENABLE_PERFORMANCE_OVERLAY` environment variable:

```bash
flutter run --dart-define=ENABLE_PERFORMANCE_OVERLAY=true
```

The overlay shows frame rendering times, GPU vs CPU time, and visual indication of performance issues. See `docs/PERFORMANCE_PROFILING.md` for detailed information.

## What happens if localization files are deleted during iOS builds?

The app includes a pre-build script (`tool/ensure_localizations.dart`) that automatically regenerates localization files before iOS builds. This script runs automatically in Xcode build phases and ensures that `app_localizations*.dart` files are always present, even after `flutter clean`.

**Note:** After running `flutter clean`, always run `flutter pub get` before `flutter run` to ensure localization files are regenerated.

## How is the dependency injection code organized?

The DI code is split into multiple files for better maintainability:

- `lib/core/di/injector.dart` - Main entry point with `configureDependencies()` and public API (61 lines)
- `lib/core/di/injector_registrations.dart` - All dependency registrations organized by category
- `lib/core/di/injector_factories.dart` - Factory functions for creating repositories (e.g., `_createCounterRepository`)
- `lib/core/di/injector_helpers.dart` - Helper functions (e.g., `registerLazySingletonIfAbsent`)

This organization keeps the main file focused and makes it easier to find and maintain specific registrations.
