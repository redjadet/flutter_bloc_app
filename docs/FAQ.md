# FAQ

## Flutter Version & Latest Updates

### What Flutter version does this app use?

This app uses **Flutter 3.38.6** with **Dart 3.10.7**. The codebase follows Flutter 3.38 best practices, including:

- **Impeller Rendering Engine**: Optimized rendering for smoother animations and reduced latency on iOS and Android
- **Material 3 Support**: Full Material Design 3 implementation with `ColorScheme.fromSeed`
- **Enhanced Desktop Support**: Multi-window support and improved platform-specific features
- **WebAssembly (Wasm) Support**: Enhanced web performance with reduced load times

### What are the key improvements in Flutter 3.38?

- **Performance**: Impeller rendering engine improvements for smoother animations
- **Theme System**: Enhanced control over Material theme data, including `TabBarThemeData.indicatorColor`
- **Deprecations**: Streamlined framework with deprecated APIs replaced (e.g., `SystemContextMenuController.show` → new context menu mechanism)
- **AI Integration**: Firebase AI Logic (formerly Vert.Ex AI) for seamless AI feature integration
- **Desktop**: Multi-window support, improved keyboard/pointer interactions, native UI components

See the [official Flutter 3.38 release notes](https://docs.flutter.dev/release/whats-new) for complete details.

## Common Flutter Questions

### How do I choose the right state management solution?

This app uses **BLoC/Cubit** pattern via `flutter_bloc` because:

- **Predictable State**: Immutable states with `Equatable`/`freezed` ensure predictable state transitions
- **Testability**: Business logic isolated in cubits enables fast unit/bloc tests without widget pumps
- **Performance**: `BlocSelector` minimizes rebuilds by selecting only needed state slices
- **Scalability**: Clean separation between UI and business logic scales well for large apps

For smaller apps, `setState` may suffice, but for production apps with complex state, BLoC/Cubit provides better maintainability and testability.

### How do I handle platform differences in Flutter?

This app uses **platform-adaptive components** to handle iOS/Android differences:

- **Buttons**: Use `PlatformAdaptive.filledButton/outlinedButton/textButton` instead of raw Material buttons
- **Dialogs**: Use `showAdaptiveDialog()` which shows `CupertinoAlertDialog` on iOS and `AlertDialog` on Android
- **Loading Indicators**: `CommonLoadingWidget` automatically uses `CupertinoActivityIndicator` on iOS and `CircularProgressIndicator` on Android
- **Platform Channels**: Use `NativePlatformService` for platform-specific APIs when needed

See `lib/shared/utils/platform_adaptive.dart` for implementation details.

### How do I optimize Flutter app performance?

This app implements several performance optimizations:

1. **Widget Rebuilds**: Use `BlocSelector` instead of `BlocBuilder` to minimize rebuilds
2. **RepaintBoundary**: Wrap expensive widgets (e.g., charts, custom painters) in `RepaintBoundary`
3. **Image Caching**: Use `CachedNetworkImageWidget` for automatic image caching
4. **Lazy List Rendering**: Use `ListView.builder` for large lists instead of `ListView`
5. **Deferred Imports**: Heavy features (Google Maps, Markdown Editor, Charts, WebSocket) load on-demand via deferred imports
6. **Lazy Dependency Injection**: All services use lazy singletons - instances created only on first access
7. **Route-Level Initialization**: Feature cubits created at route level, not app scope
8. **On-Demand Services**: BackgroundSyncCoordinator and RemoteConfigCubit start/initialize only when needed
9. **Isolate JSON Decoding**: Large JSON payloads (>8KB) decoded in isolates via `decodeJsonMap()`/`decodeJsonList()` to prevent UI stalls
10. **Performance Profiling**: Built-in `PerformanceProfiler` tracks widget rebuilds and frame performance
11. **Const Constructors**: Use `const` widgets wherever possible to reduce rebuilds

**Common Mistakes to Avoid:**

- ❌ Performing expensive operations in `build()` method
- ❌ Using `setState` for business logic (use cubits instead)
- ❌ Not disposing controllers/subscriptions
- ❌ Hard-coding dimensions instead of using responsive helpers
- ❌ Eager initialization of heavy services or features
- ❌ Creating feature cubits at app scope when they're only needed on specific routes

**See also:**

- `docs/CODE_QUALITY_ANALYSIS.md` - Detailed performance guidelines
- `analysis/lazy_loading_late_review.md` - Comprehensive lazy loading analysis and deferred imports explanation
- `docs/compute_isolate_review.md` - Compute/isolate usage guide for JSON decoding and CPU-intensive operations

### How do I make my Flutter app responsive?

This app uses a **centralized responsive system**:

- **Spacing**: `context.responsiveGapS/M/L/XL` for consistent spacing
- **Typography**: `context.responsiveHeadlineSize/TitleSize/BodySize` for scalable text
- **Layout**: `context.contentMaxWidth` and `context.pagePadding` for consistent page structure
- **Grids**: `context.calculateGridLayout()` and `context.gridColumns` for adaptive grids
- **Safe Areas**: `CommonPageLayout` handles safe-area and keyboard insets automatically

**Best Practices:**

- ✅ Use `LayoutBuilder` for responsive breakpoints
- ✅ Test with text scale 1.3+ to ensure no overflow
- ✅ Use flexible layouts (`Column`, `Row`, `Expanded`) instead of fixed positions
- ✅ Never hard-code pixel values; use responsive helpers

See `docs/ui_ux_responsive_review.md` for comprehensive responsive design guidelines.

### How do I handle errors and retries in Flutter?

This app uses a **layered error handling approach**:

1. **Domain Layer**: Domain failures (e.g., `CounterFailure`) represent business logic errors
2. **Data Layer**: Repository methods return `Result<T>` or throw domain failures
3. **Presentation Layer**: `CubitExceptionHandler` wraps async operations and maps errors to `ViewStatus.error`
4. **UI Layer**: `CommonErrorView` displays errors with retry buttons using `PlatformAdaptive` components

**Error Handling Pattern:**

```dart
try {
  final result = await repository.fetchData();
  emit(state.copyWith(status: ViewStatus.success, data: result));
} catch (e) {
  CubitExceptionHandler.handleError(this, e, (error) {
    emit(state.copyWith(status: ViewStatus.error, error: error));
  });
}
```

See `lib/shared/utils/cubit_exception_handler.dart` for implementation details.

### How do I test Flutter apps effectively?

This app maintains **75% test coverage** with multiple test types:

1. **Unit Tests**: Test isolated functions and classes
2. **Bloc Tests**: Test state flows with `bloc_test` package
3. **Widget Tests**: Test UI components and interactions
4. **Golden Tests**: Visual regression testing for UI layouts
5. **Common Bugs Prevention Tests**: Regression tests for lifecycle, disposal, async guards

**Testing Best Practices:**

- Use `FakeTimerService().tick(n)` for time-dependent tests
- Use `pump()` instead of `pumpAndSettle()` for `CachedNetworkImageWidget` tests
- Initialize Hive in `setUpAll` for repository tests
- Use `MockFirebaseAuth` + `mock_exceptions` for auth flows
- Test with text scale 1.3+ for accessibility

See `test/shared/common_bugs_prevention_test.dart` for common pitfalls to avoid.

### How do I structure a Flutter project?

This app follows **Clean Architecture** with feature-based organization:

```text
lib/
├── features/          # Feature modules
│   └── <feature>/
│       ├── domain/    # Contracts, models (Flutter-free)
│       ├── data/      # Repositories, DTOs, remote/local sources
│       └── presentation/  # Cubits, pages, widgets
├── core/              # App-wide config (DI, logging, theme, routing)
├── shared/            # Cross-cutting utilities (services, widgets, extensions)
└── l10n/              # Localization files
```

**Key Principles:**

- Domain layer is Flutter-agnostic (no `package:flutter` imports)
- Data layer implements domain contracts
- Presentation layer depends only on domain abstractions
- Shared utilities are reusable across features

See `docs/clean_architecture.md` for detailed architecture guidelines.

### How do I handle localization in Flutter?

This app supports **5 locales** (EN, TR, DE, FR, ES) with automatic generation:

1. **ARB Files**: Define strings in `lib/l10n/app_*.arb` files
2. **Auto-Generation**: Run `flutter pub get` to regenerate `AppLocalizations`
3. **Usage**: Use `context.l10n.*` in widgets (never hard-code strings)
4. **iOS Integration**: Pre-build script ensures localization files exist before iOS builds

**Best Practices:**

- ✅ Never hard-code user-facing strings
- ✅ Use `context.l10n.*` for all UI text
- ✅ Run `flutter gen-l10n` after manual ARB edits
- ✅ Always run `flutter pub get` after `flutter clean`

See `docs/new_developer_guide.md` for localization workflow details.

### How do I handle offline-first architecture?

This app implements a **complete offline-first architecture**:

- **Background Sync**: `BackgroundSyncCoordinator` syncs pending operations every 60 seconds
- **Pending Queue**: `PendingSyncRepository` stores failed operations for retry
- **Sync Strategies**:
  - **Write-first** (Counter, Chat): Queue operations when offline, sync when online
  - **Cache-first** (Search, Profile, Remote Config): Serve cached data immediately, refresh in background
- **Sync Status**: `SyncStatusCubit` tracks network status and sync state

See `docs/offline_first/` for detailed offline-first documentation.

### What are common Flutter mistakes to avoid?

Based on Flutter best practices and this codebase's patterns:

1. **❌ Side Effects in `build()`**: Never perform async operations, network calls, or file I/O in `build()`. Use `initState()` or cubits instead.
2. **❌ Hard-Coded Colors**: Always use `Theme.of(context).colorScheme` instead of `Colors.black/white/grey`.
3. **❌ Hard-Coded Strings**: Always use `context.l10n.*` instead of hard-coded English strings.
4. **❌ Raw Material Buttons**: Use `PlatformAdaptive.*` helpers instead of `ElevatedButton`/`OutlinedButton`.
5. **❌ Fixed Dimensions**: Use responsive helpers (`context.responsive*`) instead of hard-coded pixels.
6. **❌ Direct Hive Access**: Never call `Hive.openBox` directly; use `HiveService` and extend `HiveRepositoryBase`.
7. **❌ Raw Timers**: Use `TimerService` instead of raw `Timer` for testability.
8. **❌ Missing Cleanup**: Always cancel streams/timers in `close()` and dispose controllers.

See `docs/new_developer_guide.md` for the complete common bugs checklist.

## Codebase-Specific Questions

### How does the counter UI update when the count changes?

Pressing the `+` button triggers `CounterActions.increment()`, which calls `CounterCubit.increment()`. The cubit emits a new `CounterState.success` via `_emitCountUpdate`, persists the snapshot, and keeps the countdown ticker alive. `CounterDisplay` listens through a `BlocSelector`, so only the counter-specific widgets rebuild—`CounterValueText` animates the new value, the status chip/countdown visuals update, and the now-idle snack bar listener hides errors when the count moves above zero.

### Why is the snack bar dismissed when the counter goes above zero?

`CounterPage` includes a `BlocListener` that watches for the state change `count: 0 → >0`. As soon as that transition happens, it calls `ScaffoldMessenger.of(context).hideCurrentSnackBar()`. This ensures “cannot go below zero” warnings clear immediately once the user increments.

### Why is Flutter used instead of writing separate native apps?

- A single app shell keeps routing, authentication, theming, and localization in one code path, so iOS and Android stay aligned without duplicating platform scaffolding (`lib/app.dart`).
- Feature logic sits in platform-agnostic cubits and repositories, letting both platforms reuse timer-driven counters, persistence, and error handling (`lib/features/counter/presentation/counter_cubit.dart`).
- Shared dependencies (Firebase, maps, sockets) are configured once and versioned together, avoiding drift between native stacks (`pubspec.yaml`).
- Tests exercise the same Bloc flows and persistence behavior once, guaranteeing consistent results on every platform without parallel XCTest/Instrumented suites (`test/counter_cubit_test.dart`).
- Cross-cutting tooling—dependency injection, flavor management, responsive layout—already wraps platform services in reusable layers, so new features land simultaneously across devices (`lib/app.dart`).

### Why pick Flutter over React Native for this codebase?

- Rendering, navigation, and localization already compose through Flutter-native tools (Material 3, `GoRouter`, `ScreenUtil`), so we lean on a cohesive widget tree instead of bridging to platform-specific navigation stacks (`lib/app.dart`).
- Strongly typed cubits, states, and domain models give us exhaustiveness and analyzer support that JavaScript/TypeScript cannot enforce the same way, reducing runtime regressions (`lib/features/counter/presentation/counter_cubit.dart`).
- Existing integrations rely on first-party FlutterFire, Google Maps, and platform channels with typed APIs; React Native equivalents would require mixing different community plugins and re-implementing DI bindings (`pubspec.yaml`, `core/di/injector.dart`).
- Bloc/widget tests run on the same Dart VM as production code, so deterministic fakes (e.g., `FakeTimerService`) and golden tests cover UI and logic without spawning multiple JS runtimes (`test/counter_cubit_test.dart`, `test/test_helpers.dart`).
- Custom render timing and countdown visuals are expressed with synchronous widget rebuilds and animation primitives; React Native would add asynchronous bridge hops that complicate the 1 s timer flow and persistence guarantees (`lib/features/counter/presentation/counter_cubit.dart`).

### Why does Flutter scale better than React Native when targeting iOS, Android, and desktop?

- Flutter ships a single rendering engine across mobile and desktop, so widget code (animations, layout, theming) behaves identically without re-implementing platform bridges for macOS/Windows/Linux (`lib/app.dart`, `lib/shared` widgets).
- Desktop targets reuse the same dependency injection graph and repositories used on mobile, keeping services like Firebase, timers, and WebSocket clients consistent everywhere (`core/di/injector.dart`, `lib/features/**`).
- Shared navigation via `GoRouter` lets deep links, authenticated routes, and feature flows stay aligned across every form factor—no need to juggle separate navigation stacks for desktop shells (`lib/app.dart`).
- The counter feature’s timer-driven UX runs on the Dart VM with deterministic `TimerService` abstractions, avoiding React Native’s reliance on platform message loops that vary more on desktop (`lib/features/counter/presentation/counter_cubit.dart`, `test/test_helpers.dart`).
- Flutter’s build pipeline already emits runners for macOS, Windows, and Linux from this repo; adding desktop bundles is primarily a config step, whereas React Native requires additional Electron or community-driven wrappers with their own maintenance burden (`macos/`, `windows/`, `linux/` project directories).

### How do chat history actions work after the recent splits?

`ChatCubit` now mixes in purpose-specific helpers: `_ChatCubitHistoryActions` (loading/clearing/deleting/resetting history), `_ChatCubitMessageActions` (sending prompts and persisting responses), and `_ChatCubitSelectionActions` (switching models or conversations). Shared utilities like `_persistHistory`, `_replaceConversation`, and `_resolveModelForConversation` live in `_ChatCubitHelpers`, so each mixin stays focused and testable.

### How does dependency injection wire the counter repositories?

Dependency injection is organized across multiple files in `core/di/`:

- `injector.dart` - Main file with `configureDependencies()` and public API
- `injector_registrations.dart` - All dependency registrations organized by category
- `injector_factories.dart` - Factory functions for creating repositories
- `injector_helpers.dart` - Helper functions for registration

`configureDependencies()` lazily registers repositories via `get_it`. For the counter feature, it tries the Firebase-backed `RealtimeDatabaseCounterRepository` when Firebase is available; otherwise it falls back to the Hive-based `HiveCounterRepository`. All repositories are registered as lazy singletons. In tests, helpers override `getIt` registrations or inject mock repositories directly into cubits.

### What linting and formatting routines should I run?

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

### Why keep golden/widget/bloc tests together?

Golden tests (e.g., `test/counter_page_golden_test.dart`) verify layout regressions for the counter UI. Widget tests (`chat_history_sheet_test.dart`) cover interactions such as clearing/deleting history without hitting real storage, and bloc/unit tests ensure repositories/cubits produce expected states. Running these in CI (and via the documented checklist) catches UI/state regressions early.

**Test Coverage:** The project maintains **75% line coverage** (6186/7249 lines). Files that don't require tests are automatically excluded from coverage reports:

- Mock repositories (test utilities themselves)
- Simple data classes (Freezed classes, simple Equatable classes)
- Configuration files (files with only constants)
- Debug utilities (performance profiler files)
- Platform-specific widgets (map widgets requiring native testing)
- Part files (tested via parent file)
- Files with `// coverage:ignore-file` comment

See `coverage/coverage_summary.md` for the full breakdown.

### How is local storage handled in this app?

All local persistence goes through **Hive** (encrypted local database), which replaced SharedPreferences. The app uses:

- `HiveService` - Core service wrapping `Hive.initFlutter()` and ensuring every box is opened with an `AES256Cipher`
- `HiveKeyManager` - Generates and manages encryption keys stored in `flutter_secure_storage`
- `HiveRepositoryBase` - Base class for Hive-backed repositories providing common functionality
- `SharedPreferencesMigrationService` - Automatically migrates legacy SharedPreferences data to Hive on first launch

**Important:** Never call `Hive.openBox` directly. Always use `HiveService` and extend `HiveRepositoryBase` for new repositories.

### How does offline-first work in this app?

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

### How are remote images cached?

Remote images are automatically cached using the `cached_network_image` package. Use `CachedNetworkImageWidget` from `lib/shared/widgets/` for network images. It provides:

- Automatic caching of downloaded images
- Loading placeholder support
- Error handling with fallback widget
- Memory-efficient image loading with configurable cache dimensions

`FancyShimmerImage` (used in search/profile/example pages) already includes caching via `cached_network_image` under the hood.

**Testing Note:** When testing widgets that use `CachedNetworkImageWidget`, use `pump()` instead of `pumpAndSettle()` to avoid timeouts. Network requests never complete in test environments, so `pumpAndSettle()` will wait indefinitely.

### How can I profile performance in this app?

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

The overlay shows frame rendering times, GPU vs CPU time, and visual indication of performance issues. See `docs/CODE_QUALITY_ANALYSIS.md` for detailed information.

### What happens if localization files are deleted during iOS builds?

The app includes a pre-build script (`tool/ensure_localizations.dart`) that automatically regenerates localization files before iOS builds. This script runs automatically in Xcode build phases and ensures that `app_localizations*.dart` files are always present, even after `flutter clean`.

**Note:** After running `flutter clean`, always run `flutter pub get` before `flutter run` to ensure localization files are regenerated.

### How is the dependency injection code organized?

The DI code is split into multiple files for better maintainability:

- `lib/core/di/injector.dart` - Main entry point with `configureDependencies()` and public API (61 lines)
- `lib/core/di/injector_registrations.dart` - All dependency registrations organized by category
- `lib/core/di/injector_factories.dart` - Factory functions for creating repositories (e.g., `_createCounterRepository`)
- `lib/core/di/injector_helpers.dart` - Helper functions (e.g., `registerLazySingletonIfAbsent`)

This organization keeps the main file focused and makes it easier to find and maintain specific registrations.

## UI/UX & Responsive Design

### How does the app handle responsive design?

This app uses a **centralized responsive system** with extensions in `lib/shared/extensions/responsive.dart`:

- **Spacing Helpers**: `context.responsiveGapS/M/L/XL` for consistent spacing across screen sizes
- **Typography Helpers**: `context.responsiveHeadlineSize/TitleSize/BodySize` for scalable text
- **Layout Helpers**: `context.contentMaxWidth` and `context.pagePadding` for consistent page structure
- **Grid Helpers**: `context.calculateGridLayout()` and `context.gridColumns` for adaptive grids
- **Safe Area**: `CommonPageLayout` automatically handles safe-area and keyboard insets

All layouts are tested with text scale 1.3+ to ensure accessibility compliance.

### How does the app handle platform-adaptive UI?

This app uses **platform-adaptive components** to provide native-feeling UI on both iOS and Android:

- **Buttons**: `PlatformAdaptive.filledButton/outlinedButton/textButton` automatically adapt to platform conventions
- **Dialogs**: `showAdaptiveDialog()` shows `CupertinoAlertDialog` on iOS and `AlertDialog` on Android
- **Loading Indicators**: `CommonLoadingWidget` uses `CupertinoActivityIndicator` on iOS and `CircularProgressIndicator` on Android
- **Theme Colors**: All colors use `Theme.of(context).colorScheme` for consistent dark mode and Material 3 support

**Important**: Never use raw Material buttons (`ElevatedButton`, `OutlinedButton`, `TextButton`). Always use `PlatformAdaptive.*` helpers.

### How does the app handle theme-aware colors?

All colors in this app use **theme-aware color schemes**:

- ✅ `Theme.of(context).colorScheme.onSurface` for text
- ✅ `Theme.of(context).colorScheme.surface` for backgrounds
- ✅ `Theme.of(context).colorScheme.primary` for primary actions
- ❌ Never use `Colors.black`, `Colors.white`, or `Colors.grey` directly

This ensures consistent dark mode support and Material 3 compliance across all screens.

### How does the app handle safe areas and keyboard?

The app uses `CommonPageLayout` which automatically handles:

- **Safe Area Insets**: Content never overlaps iOS gesture bars or Android cutouts
- **Keyboard Insets**: Bottom padding adjusts when keyboard appears
- **Animated Transitions**: Smooth padding transitions when keyboard shows/hides

For custom layouts, use `context.pagePadding` or manually handle `MediaQuery.paddingOf(context)` and `MediaQuery.viewInsetsOf(context)`.

### How does the app handle text scaling and accessibility?

All layouts are designed to handle **text scale 1.3+**:

- **Flexible Layouts**: Use `Column`, `Row`, `Expanded`, `Flexible` instead of fixed positions
- **Responsive Typography**: Use `context.responsive*Size` helpers that scale with text scale
- **Scrollable Content**: Use `SingleChildScrollView` for overflow protection
- **Minimum Tap Targets**: 44x44 (iOS) and 48x48 (Android) minimum tap targets

The app includes smoke tests (`test/shared/widgets/text_scaling_smoke_test.dart`) to verify text scaling compliance.

### How does the app handle localization?

The app supports **5 locales** (EN, TR, DE, FR, ES) with complete localization:

- **ARB Files**: All strings defined in `lib/l10n/app_*.arb` files
- **Auto-Generation**: `flutter pub get` automatically regenerates `AppLocalizations`
- **Usage**: Always use `context.l10n.*` in widgets (never hard-code strings)
- **iOS Integration**: Pre-build script ensures localization files exist before iOS builds

**Important**: Never hard-code user-facing strings. Always use `context.l10n.*` for all UI text.

See `docs/ui_ux_responsive_review.md` for comprehensive UI/UX guidelines.
