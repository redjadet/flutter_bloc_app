# Flutter BLoC App — New Developer Guide

Welcome aboard! This document distills the essentials you need to navigate, extend, and validate this codebase with confidence.

## 1. Mental Model

- **Purpose**: Showcase a feature-rich Flutter app built around Cubits, clean architecture, and real-world integrations (Firebase Auth/Remote Config, WebSockets, GraphQL, Google Maps, Hugging Face, Whiteboard with CustomPainter, Markdown Editor with RenderObject, etc.).
- **Layers**: Domain → Data → Presentation. Domain stays Flutter-agnostic, Data fulfills contracts, Presentation wires Cubits/Widgets via `get_it`.
- **State Management**: Cubits with immutable (Freezed/Equatable) states. Widgets read via `BlocBuilder`/`BlocSelector` and stay focused on layout/theming/navigation.
- **DI & Startup**: `lib/core/di/injector.dart` registers everything into `getIt`. `main_*.dart` files choose the env, call `configureDependencies()`, then bootstrap `MyApp`. The DI code is organized into multiple files:
  - `injector.dart` - Main file with `configureDependencies()` and public API
  - `injector_registrations.dart` - All dependency registrations organized by category
  - `injector_factories.dart` - Factory functions for creating repositories
  - `injector_helpers.dart` - Helper functions for registration
- **Navigation**: `go_router` defined in `lib/app.dart` (`AppRoutes` in `lib/core/navigation/app_routes.dart`).

## 2. Repository Layout Highlights

| Path | What lives here |
| --- | --- |
| `lib/features/<feature>/domain` | Contracts, models, value objects (Flutter-free). |
| `lib/features/<feature>/data` | Repositories, DTOs, remote/local sources. |
| `lib/features/<feature>/presentation` | Cubits, pages, widgets, view models. |
| `lib/shared/` | Cross-cutting helpers: services, widgets, responsive/layout utils, platform adapters. |
| `lib/core/` | App-wide config (DI, logging, theme, routing, error handling). |
| `assets/` & `l10n/` | Images/fonts plus localization ARB files. |
| `test/` | Mirrors `lib/` with unit, bloc, widget, golden suites (see `temp_disabled_tests/` for flaky cases). |
| `tool/` | Utilities like `update_coverage_summary.dart`. |
| `figma-sync/` | Pulls assets/layout manifests from Figma when implementing provided designs. |

## 3. Application Flow

1. Entry (`main_dev.dart`, `main_prod.dart`, etc.) sets flavor configs and calls `bootstrap(const MyApp())`.
2. `configureDependencies()` registers shared services (timer, platform, logging), repositories, and cubits’ dependencies.
3. `MyApp` builds `AppScope` and a `MultiBlocProvider`. Each cubit calls `loadInitial()` in `initState` when deterministic startup work is needed. See DI Reference section below for example.
4. `GoRouter` resolves screens. Feature pages assemble their cubit(s) + widgets and delegate work to the injected repositories.

## 4. Feature Module Playbook

1. **Domain**: Define contracts (e.g., `CounterRepository`), models, and failures using Freezed/Equatable. Keep imports Dart-only.
2. **Data**: Implement the contracts (REST, Firebase, shared_preferences, etc.). Translate DTOs ↔ domain models inside this layer.
3. **Presentation**: Build Cubits and UI. Use `getIt` to inject dependencies via constructors; add view-specific helpers under `presentation/widgets/`.
4. **Registration**: Wire the concrete repository/service inside `configureDependencies()` so cubits receive it through DI.
5. **Timer Workflows**: Use `TimerService` (or `FakeTimerService` in tests) for periodic behavior—never create raw `Timer` instances in widgets or cubits.
6. **Platform Data**: Reach for `NativePlatformService` (MethodChannel-backed) instead of touching platform channels directly in features.

## 5. Key Building Blocks

- **Counter experience**: Lives under `lib/features/counter/`. Auto-decrement logic is driven by `TimerService`, and the state exposes derived values for countdown UI.
- **Settings**: `lib/features/settings/` owns theme/locale, exposing value objects (`AppLocale`, `ThemePreference`) so domain remains UI-free.
- **Whiteboard**: Located in `lib/features/example/presentation/widgets/whiteboard/`. Demonstrates low-level Flutter rendering using `CustomPainter` for canvas drawing. Features include stroke management, color selection, width presets, and undo/redo functionality. Accessible via the app bar overflow menu.
- **Markdown Editor**: Located in `lib/features/example/presentation/widgets/markdown_editor/`. Demonstrates custom `RenderObject` subclass (`MarkdownRenderObject`) for efficient text layout. Uses `markdown` package for parsing and supports GitHub Flavored Markdown. Accessible via the app bar overflow menu.
- **Networking**: GraphQL, WebSocket, REST integrations sit in their respective feature/data folders. Samples include `CountriesGraphqlRepository`, `EchoWebsocketRepository`, `HuggingfaceChatRepository`.
- **Authentication**: `lib/features/auth/` wraps Firebase Auth + FirebaseUI for sign-in/sign-up flows.
- **Remote Config & Feature Flags**: `RemoteConfigCubit` consumes `RemoteConfigService` to toggle runtime features.
  Recent updates expose `RemoteConfigLoading`/`RemoteConfigError` states and wrap calls in `CubitExceptionHandler`, so transient failures log nicely and expose retryable errors instead of crashing the cubit.
- **Deep Links**: `DeepLinkCubit` cooperates with `AppLinksDeepLinkService` to translate universal/custom links into router locations.
  The cubit also emits `DeepLinkLoading`/`DeepLinkError`, guards against overlapping `initialize()` calls, and exposes `retryInitialize()` so stream errors tear down safely and restart deterministically.
- **Cross-cutting Services**: `lib/shared/services/` hosts timer, logging, biometric auth, native platform adapters, etc. Prefer extending these instead of introducing ad-hoc singletons.
- **Offline-First Architecture**: The app implements a complete offline-first pattern across all core features. See `docs/offline_first/` for detailed documentation.
  - **Background Sync**: `BackgroundSyncCoordinator` automatically syncs pending operations when online (60s interval)
  - **Sync Status**: `SyncStatusCubit` tracks network status and sync state; widgets consume via `BlocSelector`
  - **Pending Queue**: `PendingSyncRepository` stores operations that failed while offline; coordinator processes them when online
  - **Repository Pattern**: Features implement `SyncableRepository` interface with `pullRemote()` and `processOperation()` methods
  - **Sync Metadata**: Domain models include `synchronized`, `lastSyncedAt`, and `changeId` fields for conflict resolution
  - **UI Indicators**: Sync banners (`CounterSyncBanner`, `ChatSyncBanner`, etc.) show offline/syncing/pending states
  - **Adoption Guide**: See `docs/offline_first/adoption_guide.md` for step-by-step instructions on adding offline-first to new features

## 6. Development Workflow

Follow the delivery checklist before merging or publishing builds:

1. `flutter pub get`
2. Codegen when needed (`dart run build_runner build --delete-conflicting-outputs`)
3. **Run delivery checklist:** `./bin/checklist` (or `tool/delivery_checklist.sh`)
   - This runs steps 3-5 automatically: `dart format .` → `flutter analyze` → `tool/test_coverage.sh`
   - **Optional:** To use just `checklist` without `./bin/`, add the `bin` directory to your PATH
4. `flutter build ios --simulator` (only when iOS build risk exists)

**Note:** The delivery checklist script (`./bin/checklist`) automatically runs:

- `flutter pub get` - Ensures dependencies (and analyzer config) resolve correctly
- `dart format .` - Code formatting
- `flutter analyze` - Static analysis (includes native Dart 3.10 analyzer plugins like `file_length_lint`)
- `tool/test_coverage.sh` - Runs tests with coverage and automatically updates coverage reports

Tips:

- Keep files <250 LOC; extract helpers into `shared/` or dedicated widgets when approaching the limit.
- Run `flutter analyze` to catch repository-specific analyzer plugins (e.g., file length, forbidden imports).
- `flutter test --coverage` populates `coverage/lcov.info`; the summary script updates any dashboards/PR comments.

## 7. Testing Strategy

- **Unit & Bloc tests**: Use `bloc_test` + fake repositories/services. Counter, GraphQL, WebSocket, Remote Config cubits all have samples to copy.
- **Widget/Golden tests**: Live under `test/features/.../presentation`. Use `golden_toolkit` for deterministic layout tests and seed localization/theme providers as needed.
- **Common Bugs Prevention tests**: Located in `test/shared/common_bugs_prevention_test.dart`, these regression tests verify defensive patterns (context lifecycle checks, cubit disposal guards, stream cleanup, etc.). Automatically included when running `./bin/checklist` or `tool/test_coverage.sh`.
- **Timer-dependent tests**: Inject `FakeTimerService` and advance time with `tick(n)` instead of waiting on real timers.
- **Network image tests**: When testing widgets that use `CachedNetworkImageWidget`, use `pump()` instead of `pumpAndSettle()` to avoid timeouts. Network requests never complete in test environments, so `pumpAndSettle()` will wait indefinitely. Use `await tester.pump()` followed by `await tester.pump(const Duration(milliseconds: 100))` if needed for async operations.
- **Auth & Platform fakes**: `MockFirebaseAuth`, mock `NativePlatformService`, `FakeTimerService`, and other utilities live in `test/mocks/` or feature-specific folders.
- **Skips**: Temporary skips sit in `temp_disabled_tests/`; remove them once flakes are resolved.

## 8. Tooling & Productivity

- **Figma pipeline**: When asked to implement a `Frame_Node`, configure `figma-sync/.env`, run `npm install`, then `npm run fetch`. Place outputs under `assets/figma/<Frame>_<Node>/` and update `pubspec.yaml`. Follow `layout_manifest.json` stacking order and use `ResilientSvgAssetImage` for rasterized SVGs.
- **Secrets**: Use `SecretConfig` to load secure config. Never check real secrets into source; rely on `--dart-define` or secure storage.
- **Logging**: Use `AppLogger` (registered in DI) instead of `print`.
- **Lint rationale**: `prefer_final_parameters` keeps method inputs immutable, improving readability, reducing accidental reassignment during refactors, and making data flow easier to audit. Performance gains are modest, but immutable parameters can enable clearer intent and reduce defensive copies in hot paths.
- **Linting philosophy**: We lean on Very Good Analysis for baseline safety and keep project rules focused on clarity and maintainability. `type_annotate_public_apis` makes public surfaces explicit for reviewers and tooling. The file-length lint (250 LOC) encourages smaller units that are easier to test and can reduce rebuild scope in large widgets.
- **Performance-oriented linting**: VGV enforces `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `avoid_unnecessary_containers`, `use_colored_box`, and `no_logic_in_create_state`. These reduce widget tree depth, keep builds lightweight, and make rebuild costs more predictable.
- **Error handling**: Route recoverable errors through domain failures or `ErrorHandling` helpers; surface user-facing errors via localized messages.
- **Localization**: Update ARB files in `l10n/arb/`, run `flutter gen-l10n`, and access strings through `context.l10n`.
- **Image caching**: Use `CachedNetworkImageWidget` from `lib/shared/widgets/` for remote images. It provides automatic caching, loading placeholders, error handling, and memory optimization. `FancyShimmerImage` (used in search/profile/example pages) already includes caching via `cached_network_image` under the hood.

## 9. Adding a New Feature (Cheat Sheet)

1. Create `lib/features/<feature>/domain|data|presentation` folders.
2. Define domain contracts/models (Freezed classes go in `domain/models`).
3. Implement data sources (REST, Firebase, etc.), map DTOs to domain entities.
4. **For offline-first features**: Follow `docs/offline_first/adoption_guide.md`:
   - Add sync metadata to domain models (`synchronized`, `lastSyncedAt`, `changeId`)
   - Create local cache repository (Hive-backed)
   - Implement `OfflineFirst<Feature>Repository` with `SyncableRepository` interface
   - Register in `SyncableRepositoryRegistry` (auto-registers on construction)
   - Add sync status UI (banner widget) using `SyncStatusCubit`
5. Build Cubit + state (immutable), add widgets/pages.
6. Register DI bindings (repository, cubit factories if needed).
7. Add tests: repository unit tests, cubit bloc tests, and widget/golden coverage.
8. Wire navigation via `AppRoutes` + `GoRouter` in `lib/app.dart`.
9. Update docs/README if the feature is user-facing.
10. **For offline-first**: Document in `docs/offline_first/<feature>.md` following existing patterns.

## 10. Common Troubleshooting

- **Stuck timers or async flows**: Ensure the cubit is disposed or the `TimerService` subscription is canceled in `close()`.
- **Remote Config not updating**: Confirm Firebase project settings match the current flavor (`main_dev.dart`, etc.) and that `RemoteConfigCubit`'s `refreshInterval` isn't throttling updates.
- **GraphQL/WebSocket issues**: Check the environment constants in `lib/core/config` and confirm the emulator/network allows outbound connections.
- **Maps API keys**: For Android, add to `android/app/src/main/AndroidManifest.xml`; for iOS, configure `ios/Runner/AppDelegate.swift` + `Info.plist`. The app gracefully falls back to Apple Maps when Google keys are missing.
- **Coverage script fails**: Ensure `lcov` file exists (run tests with `--coverage`) and that `dart run tool/update_coverage_summary.dart` runs from repo root.
- **Firebase upgrades break iOS build**: After bumping Firebase packages, run the clean sweep Firebase recommends so the simulator doesn't load stale pods:

  ```bash
  flutter clean
  cd ios
  rm -rf Pods Podfile.lock
  pod repo update
  pod install
  cd ..
  flutter pub get
  rm -rf ~/Library/Developer/Xcode/DerivedData # optional but fixes module cache issues
  flutter run
  ```

  This clears cached frameworks so duplicate symbol/module errors like `FLTFirebaseDatabasePlugin has different definitions` disappear.

### Common Bugs to Avoid

Before finishing any task, verify these common bug patterns:

#### Context & Widget Lifecycle

- ✅ **Async operations with context**: Check `context.mounted` after `await` before using `context` (navigation, reading cubits, showing dialogs)

  ```dart
  await someAsyncOperation();
  if (!context.mounted) return;
  Navigator.of(context).pop();
  ```

- ✅ **addPostFrameCallback**: Check `context.mounted` or `mounted` before using context/controllers

  ```dart
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!context.mounted || !controller.hasClients) return;
    await controller.animateTo(...);
  });
  ```

- ✅ **Future.delayed callbacks**: Check `context.mounted` or `isClosed` before using context/emitting state

  ```dart
  Future.delayed(duration, () {
    if (!context.mounted) return;
    // Use context
  });
  ```

- ✅ **Unawaited navigation**: Check `context.mounted` before `unawaited` navigation calls

  ```dart
  void _navigateToRoute(BuildContext context) {
    if (!context.mounted) return;
    unawaited(context.pushNamed(route));
  }
  ```

#### Cubit/Bloc State Management

- ✅ **Emit after close**: Check `isClosed` before all `emit()` calls, especially in:
  - Stream subscription callbacks (`listen`, `onData`, `onError`)
  - Timer callbacks (`Timer`, `TimerService.periodic`)
  - Async operation callbacks (`onSuccess`, `onError` in `CubitExceptionHandler`)
  - `Future.delayed` callbacks

  ```dart
  void _onIncomingMessage(final Message message) {
    if (isClosed) return;
    emit(state.appendMessage(message));
  }
  ```

- ✅ **Multiple emit calls**: Check `isClosed` between consecutive `emit()` calls

  ```dart
  void _handleUri(final Uri uri) {
    if (isClosed) return;
    emit(DeepLinkNavigate(target, origin));
    if (isClosed) return;
    emit(const DeepLinkIdle());
  }
  ```

- ✅ **Stream subscriptions**: Ensure subscriptions are properly cancelled in `close()` method

  ```dart
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
  ```

- ✅ **Race conditions**: Nullify subscription reference before cancelling to prevent race conditions

  ```dart
  final StreamSubscription? oldSubscription = _subscription;
  _subscription = null;
  unawaited(oldSubscription?.cancel());
  ```

#### Switch Statements

- ✅ **Missing breaks**: Ensure switch cases have proper `break` statements to prevent fall-through (unless intentional)

  ```dart
  switch (state) {
    case StateA:
      doSomething();
      break; // Required unless fall-through is intentional
    case StateB:
      doSomethingElse();
  }
  ```

#### Completers & Futures

- ✅ **Multiple completions**: Check `isCompleted` before completing a `Completer` to prevent errors

  ```dart
  if (!completer.isCompleted) {
    completer.complete(value);
  }
  ```

- ✅ **Completer cleanup**: Complete or cancel completers in `dispose()`/`close()` methods

  ```dart
  _completer?.completeError(StateError('Cancelled'));
  _completer = null;
  ```

#### Navigation

- ✅ **Navigation after async**: Check `context.mounted` before navigation operations after `await`

  ```dart
  await someOperation();
  if (!context.mounted) return;
  await context.push(route);
  ```

#### Platform-Specific Dialogs

- ✅ **iOS dialog buttons**: Use `showAdaptiveDialog` with explicit `CupertinoAlertDialog` on iOS, not just `AlertDialog.adaptive`

  ```dart
  final bool isCupertino = PlatformAdaptive.isCupertino(context);
  await showAdaptiveDialog(
    context: context,
    builder: (dialogContext) {
      if (isCupertino) {
        return CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('OK'),
            ),
          ],
        );
      }
      return AlertDialog(...);
    },
  );
  ```

#### Resource Cleanup

- ✅ **StreamControllers**: Ensure `StreamController` is closed in `dispose()`/`close()` methods
- ✅ **Timers**: Ensure timers are cancelled/disposed in `close()` methods
- ✅ **Listeners**: Remove listeners in `dispose()` methods

**Quick verification**: Run `./bin/checklist` before committing to catch formatting, analysis, and test issues.

## 11. DI Reference Example

```dart
MultiBlocProvider(providers: [
  BlocProvider(create: (_) => CounterCubit(repository: getIt<CounterRepository>(), timerService: getIt<TimerService>())..loadInitial()),
  BlocProvider(create: (_) => ThemeCubit(repository: getIt<ThemeRepository>())..loadInitial()),
], child: ...)
```

**Pattern:** Lazy singletons via `registerLazySingletonIfAbsent` (single instance, on-demand init, thread-safe). See `lib/core/di/injector.dart` for the main entry point.

## 12. What to Read Next

- `README.md`: Feature tour + architecture diagram.
- `docs/CODE_QUALITY_ANALYSIS.md`: Architecture findings and related quality/resilience notes.
- `docs/` (e.g., `docs/universal_links/`, `docs/figma/...`): Platform-specific guides.

Stay disciplined with the guardrails, keep tests deterministic, and reach for shared services before adding new singletons. Welcome to the team!
