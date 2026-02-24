# Flutter BLoC App — New Developer Guide

Welcome aboard! This document is the fastest path to getting the app running locally, understanding the architecture, and shipping changes safely.

## Contents

- [Quickstart (first 30 minutes)](#quickstart-first-30-minutes)
- [Mental model](#1-mental-model)
- [Repo layout highlights](#2-repository-layout-highlights)
- [Application flow](#3-application-flow)
- [Feature module playbook](#4-feature-module-playbook)
- [Key building blocks](#5-key-building-blocks)
- [Development workflow](#6-development-workflow)
- [Testing strategy](#7-testing-strategy)
- [Tooling & productivity](#8-tooling--productivity)
- [Responsive & adaptive UI guidelines](#85-responsive--adaptive-ui-guidelines)
- [Adding a new feature (cheat sheet)](#9-adding-a-new-feature-cheat-sheet)
- [How do you approach adding new logic to production?](#95-how-do-you-approach-adding-new-logic-to-production)
- [Common troubleshooting](#10-common-troubleshooting)
- [DI reference example](#11-di-reference-example)
- [Best-practice validation scripts](#12-bestpractice-validation-scripts)
- [What to read next](#13-what-to-read-next)

## Quickstart (first 30 minutes)

### Prerequisites

- **Flutter SDK**: Use the version pinned by the repo/tooling (for example, in internal project documentation or CI configuration).
- **Platform toolchains**:
  - iOS: Xcode + CocoaPods
  - Android: Android Studio + SDKs
  - Optional: Chrome (web), a desktop target (macOS/windows/linux) if you intend to run there

### Platform-Specific Setup

**Android:**

1. Place `google-services.json` in `android/app/` (Firebase config, gitignored)
2. Add Google Maps API key to `android/app/src/main/AndroidManifest.xml` if using maps feature
3. Run `flutter build apk` to verify Android build works

**iOS:**

1. Place `GoogleService-Info.plist` in `ios/Runner/` (Firebase config, gitignored)
2. Run `cd ios && pod install && cd ..` after `flutter pub get`
3. For device deployment with personal Apple ID, use development entitlements:

   ```bash
   ./tool/ios_entitlements.sh development
   ```

4. For Ad Hoc/App Store builds (requires paid Apple Developer account):

   ```bash
   ./tool/ios_entitlements.sh distribution
   ```

   For automated builds, use [Fastlane](deployment.md#fastlane-ios-lanes-ad-hoc-testflight-app-store): `bundle exec fastlane ios adhoc` (Ad Hoc IPA), `ios testflight` (upload to TestFlight), or `ios appstore` (upload to App Store Connect).

> **Note:** Some packages are platform-specific. See [tech_stack.md](tech_stack.md#platform-specific-dependencies) for details on `apple_maps_flutter` (iOS-only), `window_manager` (desktop-only), etc.

### Get dependencies

```bash
flutter pub get
```

### Run the app (pick a flavor)

This repo supports multiple entrypoints (for example `main_dev.dart`, `main_prod.dart`). Run the one you need:

```bash
flutter run -t lib/main_dev.dart
```

### Run the project’s quality gates locally

This is the “one command” check that formats, analyzes, runs validation scripts, and runs tests/coverage:

```bash
./bin/checklist
```

### Common codegen (when you touch Freezed/JSON/etc.)

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 1. Mental Model

- **Purpose**: Showcase a feature-rich Flutter app built around Cubits, clean architecture, and real-world integrations (Firebase Auth/Remote Config, WebSockets, GraphQL, Google Maps, Hugging Face, GenUI AI-generated UI, Whiteboard with CustomPainter, Markdown Editor with RenderObject, etc.).
- **Layers**: Domain → Data → Presentation. Domain stays Flutter-agnostic, Data fulfills contracts, Presentation wires Cubits/Widgets via `get_it`.
- **State Management**: Cubits with immutable (Freezed/Equatable) states. Widgets read via `BlocBuilder`/`BlocSelector` and stay focused on layout/theming/navigation. **Type-safe extensions** (`context.cubit<T>()`, `TypeSafeBlocSelector`, etc.) provide compile-time safety. See [Compile-Time Safety Guide](compile_time_safety.md).
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
| `lib/shared/` | Cross-cutting helpers: services, widgets, **components** (design primitives), responsive/layout utils, platform adapters. |
| `lib/core/` | App-wide config: DI, theme (`core/theme/`), constants (`core/constants/`), extensions (`core/extensions/`), routing, error handling. |
| `assets/` & `l10n/` | Images/fonts plus localization ARB files. |
| `test/` | Mirrors `lib/` with unit, bloc, widget, golden suites (see `temp_disabled_tests/` for flaky cases). |
| `tool/` | Utilities like `update_coverage_summary.dart`. |
| `figma-sync/` | Pulls assets/layout manifests from Figma when implementing provided designs. |

## 3. Application Flow

1. Entry (`main_dev.dart`, `main_prod.dart`, etc.) sets flavor configs and calls `bootstrap(const MyApp())`.
2. `configureDependencies()` registers shared services (timer, platform, logging), repositories, and cubits’ dependencies.
3. `MyApp` builds `AppScope` and a `MultiBlocProvider`. Most feature cubits (including Counter) are now created at the route level and call `loadInitial()` when deterministic startup work is needed. See DI Reference section below for example.
4. `GoRouter` resolves screens. Feature pages assemble their cubit(s) + widgets and delegate work to the injected repositories.

### Deferred Feature Loading

This codebase uses **deferred imports** to reduce initial app bundle size and improve startup time. Heavy features are loaded on-demand when users navigate to them.

**Note:** This differs from **Deferred Components** (an Android-specific feature for Play Store dynamic feature modules). This app uses deferred imports, which work across all platforms without requiring Android-specific setup.

**Currently deferred features:**

- Google Maps (heavy native SDK dependencies)
- Markdown Editor (custom RenderObject implementation)
- Charts (data visualization libraries)
- WebSocket (real-time communication libraries)

**Note:** GenUI Demo is not deferred because it uses lightweight SDK dependencies and is intended for quick access during development.

**Add new deferred routes like this:**

```dart
import 'package:flutter_bloc_app/app/router/deferred_pages/your_feature_page.dart'
    deferred as your_feature_page;

GoRoute(
  path: AppRoutes.yourFeaturePath,
  name: AppRoutes.yourFeature,
  builder: (context, state) => DeferredPage(
    loadLibrary: your_feature_page.loadLibrary,
    builder: (context) => your_feature_page.buildYourFeaturePage(context, state),
  ),
),
```

**Key requirements:**

1. Create a library file in `lib/app/router/deferred_pages/your_feature_page.dart` with a `library;` declaration
2. Export a builder function (e.g., `buildYourFeaturePage()`) that returns the page widget
3. Use `deferred as` import syntax in `routes.dart`
4. Wrap the route builder with `DeferredPage` widget

**How it works:**

- Deferred imports split code into separate chunks that load on-demand
- When a user navigates to a deferred route, the library is loaded asynchronously
- `DeferredPage` widget shows a loading indicator during library load
- Once loaded, the feature code is available for the remainder of the app session
- Reduces initial bundle size (estimated 9-17 MB saved) and speeds up cold start

**Advanced: Deferred Components (Android-only)**
For Android apps distributed via Play Store, you can use **Deferred Components** for even more advanced code splitting:

- Features downloaded as dynamic feature modules from Play Store
- Requires configuration in `pubspec.yaml` under `flutter.deferred-components`
- Uses `DeferredComponent` utility class instead of `loadLibrary()`
- See [Flutter Deferred Components documentation](https://docs.flutter.dev/perf/deferred-components) for details

> **See also:** [Lazy Loading Review](lazy_loading_review.md) for a deeper dive into deferred imports and best practices.

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
- **Networking**: GraphQL, WebSocket, REST integrations sit in their respective feature/data folders. Samples include `CountriesGraphqlRepository`, `EchoWebsocketRepository`, `HuggingfaceChatRepository`, `GenUiDemoAgentImpl`.
- **Authentication**: `lib/features/auth/` wraps Firebase Auth + FirebaseUI for sign-in/sign-up flows.
- **Remote Config & Feature Flags**: `RemoteConfigCubit` consumes `RemoteConfigService` to toggle runtime features and initializes lazily via `ensureInitialized()` when a feature needs values.
  Recent updates expose `RemoteConfigLoading`/`RemoteConfigError` states and wrap calls in `CubitExceptionHandler`, so transient failures log nicely and expose retryable errors instead of crashing the cubit.
- **Deep Links**: `DeepLinkCubit` cooperates with `AppLinksDeepLinkService` to translate universal/custom links into router locations.
  The cubit also emits `DeepLinkLoading`/`DeepLinkError`, guards against overlapping `initialize()` calls, and exposes `retryInitialize()` so stream errors tear down safely and restart deterministically.
- **Cross-cutting Services**: `lib/shared/services/` hosts timer, logging, biometric auth, native platform adapters, etc. Prefer extending these instead of introducing ad-hoc singletons.
- **Offline-First Architecture**: The app implements a complete offline-first pattern across all core features. See `docs/offline_first/` for detailed documentation.
  - **Background Sync**: `BackgroundSyncCoordinator` syncs pending operations when online (60s interval) and starts on demand via `SyncStatusCubit.ensureStarted()`
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

### Quality Gates

The delivery checklist script (`./bin/checklist`) automatically runs:

- `flutter pub get` - Ensures dependencies (and analyzer config) resolve correctly
- `dart format .` - Code formatting
- `flutter analyze` - Static analysis (includes native Dart 3.10 analyzer plugins like `file_length_lint`)
- `tool/test_coverage.sh` - Runs tests with coverage and automatically updates coverage reports

**Run the full checklist before commits:**

```bash
./bin/checklist
```

This runs formatting, analysis, validation scripts, and coverage. The validation scripts provide automated guards for architecture, UI/UX, async safety, performance, and memory hygiene. See [Validation Scripts Documentation](validation_scripts.md) for what each script checks and how to suppress false positives when necessary.

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
- **Localization**: Update ARB files in `lib/l10n/app_*.arb` (en, tr, de, fr, es), run `flutter gen-l10n`, and access strings through `context.l10n`. Never hard-code user-facing strings; always use localization keys.
- **Image caching**: Use `CachedNetworkImageWidget` from `lib/shared/widgets/` for remote images. It provides automatic caching, loading placeholders, error handling, and memory optimization. `FancyShimmerImage` (used in search/profile/example pages) already includes caching via `cached_network_image` under the hood.

## 8.5. Responsive & Adaptive UI Guidelines

The app follows mobile-first responsive design principles with platform-adaptive components. See `docs/ui_ux_responsive_review.md` for comprehensive UI/UX guidelines.

### Responsive System

Import `package:flutter_bloc_app/shared/extensions/responsive.dart` to access responsive helpers:

**Spacing:**

- `context.responsiveGapXS/S/M/L` - Vertical gaps (scaled by device)
- `context.responsiveHorizontalGapS/M/L` - Horizontal gaps
- `context.pageHorizontalPadding` / `context.pageVerticalPadding` - Page-level padding
- `context.pagePadding` - Full page padding (includes safe-area and keyboard insets)
- `context.responsiveCardPadding` / `context.responsiveCardMargin` - Card spacing

**Layout:**

- `context.contentMaxWidth` - Maximum content width (560/720/840 for mobile/tablet/desktop)
- `context.responsiveBorderRadius` / `context.responsiveCardRadius` - Border radii
- `context.responsiveElevation` / `context.responsiveCardElevation` - Material elevation
- `context.calculateGridLayout()` - Responsive grid calculations
- `context.createResponsiveGridDelegate()` - SliverGrid delegate

**Typography:**

- `context.responsiveFontSize` - Base font size (14/16/16)
- `context.responsiveHeadlineSize` - Headlines (24/32/32)
- `context.responsiveTitleSize` - Titles (20/24/24)
- `context.responsiveBodySize` - Body text (14/16/16)
- `context.responsiveCaptionSize` - Captions (12/14/14)
- `context.responsiveIconSize` - Icon sizes (20/24/24)

**Example:**

```dart
Padding(
  padding: context.pageHorizontalPaddingInsets,
  child: Column(
    children: [
      Text('Title', style: TextStyle(fontSize: context.responsiveTitleSize)),
      SizedBox(height: context.responsiveGapM),
      Text('Body', style: TextStyle(fontSize: context.responsiveBodySize)),
    ],
  ),
)
```

### Platform-Adaptive Components

Always use platform-adaptive helpers instead of raw Material widgets:

**Buttons:**

- `PlatformAdaptive.filledButton()` - Filled button (CupertinoButton.filled on iOS, FilledButton on Android)
- `PlatformAdaptive.outlinedButton()` - Outlined button (CupertinoButton on iOS, OutlinedButton on Android)
- `PlatformAdaptive.textButton()` - Text button (CupertinoButton on iOS, TextButton on Android)
- `PlatformAdaptive.button()` - Generic button (CupertinoButton on iOS, ElevatedButton on Android)

**Dialogs:**

- `PlatformAdaptive.dialogAction()` - Dialog action button
- Always use `showAdaptiveDialog()` instead of `showDialog()`

**Loading Indicators:**

- `CommonLoadingWidget` - Platform-adaptive (CupertinoActivityIndicator on iOS, CircularProgressIndicator on Android)
- `CommonLoadingButton` - Button with platform-adaptive loading indicator

**Example:**

```dart
PlatformAdaptive.filledButton(
  context: context,
  onPressed: () {},
  child: Text(l10n.submitButton),
)
```

### Theme-Aware Colors

**Never use hard-coded colors.** Always use `Theme.of(context).colorScheme`:

- **Text:** `colorScheme.onSurface`, `colorScheme.onSurfaceVariant`
- **Backgrounds:** `colorScheme.surface`, `colorScheme.surfaceContainerHighest`
- **Borders:** `colorScheme.outline`, `colorScheme.outlineVariant`
- **Primary:** `colorScheme.primary`, `colorScheme.onPrimary`
- **Errors:** `colorScheme.error`, `colorScheme.onError`, `colorScheme.errorContainer`

**Example:**

```dart
final theme = Theme.of(context);
final colors = theme.colorScheme;
Container(
  color: colors.surface,
  child: Text(
    'Hello',
    style: TextStyle(color: colors.onSurface),
  ),
)
```

### Safe Area & Keyboard Handling

**CommonPageLayout** automatically handles safe-area and keyboard insets. For custom layouts:

- Use `context.pagePadding` which includes safe-area and keyboard insets
- Or wrap with `SafeArea` and add `MediaQuery.viewInsetsOf(context).bottom` for keyboard
- Use `AnimatedPadding` for smooth keyboard transitions

**Example:**

```dart
// Good: CommonPageLayout handles this automatically
CommonPageLayout(
  title: 'My Page',
  body: MyContent(),
)

// Custom layout with safe area
SafeArea(
  child: Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: MyContent(),
  ),
)
```

### Text Scaling & Accessibility

- Flutter automatically scales text via `MediaQuery.textScalerOf(context)`
- Use flexible layouts (Column, CustomScrollView) that adapt to text size
- Avoid fixed heights on text containers; use `minHeight` or flexible constraints
- Test with text scale 1.3+ (iOS Dynamic Type Largest, Android Font Size Largest)
- Minimum tap targets: 44x44 (iOS), 48x48 (Android)

**Example:**

```dart
// Good: Flexible layout
Column(
  children: [
    Text('Title', style: theme.textTheme.headlineSmall),
    Text('Body', style: theme.textTheme.bodyMedium),
  ],
)

// Avoid: Fixed heights that break with large text
Container(
  height: 50, // ❌ Breaks with large text
  child: Text('Content'),
)
```

### Shared Layout Components

- **CommonPageLayout**: Consistent page shell with safe-area-aware padding, app bar, and responsive constraints
- **CommonAppBar**: Platform-adaptive app bar with consistent navigation
- **CommonErrorView**: Error display with platform-adaptive retry button
- **CommonLoadingWidget**: Platform-adaptive loading indicator
- **CommonStatusView**: Status messages (loading, error, empty states)

**Example:**

```dart
CommonPageLayout(
  title: l10n.myPageTitle,
  body: Column(
    children: [
      // Your content here
    ],
  ),
)
```

### Testing Responsive/Adaptive UI

- **Text scaling tests**: Use `MediaQueryData(textScaler: TextScaler.linear(1.3))` in widget tests
- **Platform tests**: Test both Material and Cupertino themes
- **Safe area tests**: Test with different safe-area insets
- **Device coverage**: Test on compact (iPhone SE), standard (iPhone 14 Pro), and tablet (iPad Pro) sizes

**Example:**

```dart
testWidgets('scales text at 1.3x', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
      child: MaterialApp(home: MyWidget()),
    ),
  );
  // Assertions...
});
```

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
6. **UI/UX requirements**:
   - Use `CommonPageLayout` for consistent page structure
   - Use `PlatformAdaptive` helpers for buttons/dialogs (never raw Material buttons)
   - Use `context.responsive*` helpers for spacing/sizing (no hard-coded values)
   - Use `Theme.of(context).colorScheme` for colors (never `Colors.black/white/grey`)
   - Use `context.l10n.*` for all user-facing strings (never hard-coded English)
   - Ensure safe-area and keyboard handling (use `CommonPageLayout` or handle manually)
   - Test with text scale 1.3+ and verify no overflow
7. Register DI bindings (repository, cubit factories if needed).
8. Add tests: repository unit tests, cubit bloc tests, widget/golden coverage, and text scaling tests.
9. Wire navigation via `AppRoutes` + `GoRouter` in `lib/app.dart`.
10. Update docs/README if the feature is user-facing.
11. **For offline-first**: Document in `docs/offline_first/<feature>.md` following existing patterns.

## 9.5. How do you approach adding new logic to production?

This section answers the question from two angles: **this project’s workflow** and **general best practices** for any production codebase.

### In this project

1. **Understand before changing**
   - Locate the right layer: domain (contracts, models), data (repositories, DTOs), or presentation (cubits, widgets). See [Feature module playbook](#4-feature-module-playbook) and [Repository layout](#2-repository-layout-highlights).
   - Read existing code in that feature and related tests. Follow established patterns (e.g. `CubitExceptionHandler`, `TimerService`, type-safe `context.cubit<T>()`).
   - Check `docs/architecture_details.md` and `docs/clean_architecture.md` so new logic respects boundaries (e.g. no Flutter in domain, no direct `GetIt` in presentation).

2. **Add logic in the right place**
   - **Domain**: New business rules, contracts, or value objects (Dart-only, no Flutter).
   - **Data**: New or extended repository methods, DTOs, and mapping; use shared services (`ResilientHttpClient`, `HiveService`, `TimerService`) where applicable.
   - **Presentation**: New or updated cubit methods and state; keep widgets focused on layout/theming/navigation and lifecycle-safe (e.g. `context.mounted` after `await`, `isClosed` before `emit()`).

3. **Wire and validate**
   - Register new dependencies in `lib/core/di/` (e.g. `injector_registrations.dart`). Use `registerLazySingletonIfAbsent` for singletons.
   - Add or extend tests (unit, bloc, widget/golden as needed). Preserve or improve coverage.
   - Run the quality gate: **`./bin/checklist`** (format, analyze, validation scripts, tests/coverage). Fix any reported violations before merging.
   - For user-facing or risky changes, run the relevant app flows manually (e.g. the affected feature and navigation).

4. **Lifecycle and safety**
   - After every `await` in cubits: guard `emit()` with `if (isClosed) return;`. In widgets: guard use of `context` with `if (!context.mounted) return;` and `setState` with `if (!mounted) return;`.
   - Do not call `context.l10n` or `Theme.of(context)` inside `BlocProvider`/`Provider` `create` or in `initState`; read inherited values in `build()` and pass them in.
   - Use `CubitSubscriptionMixin` and `registerSubscription()` for stream subscriptions; use `TimerService` (or `FakeTimerService` in tests) for delays instead of raw `Timer`/`Future.delayed` where cancellation matters.

5. **Document and ship**
   - Update docs if you add a new feature or change behavior (e.g. `docs/feature_implementation_guide.md`, `docs/offline_first/` for offline features).
   - Review your diff before commit; keep changes as small and focused as possible for the goal.

### General best practices (any production app)

1. **Understand first**
   - Read the code you’re changing and its tests. Identify dependencies and side effects.
   - Follow existing patterns and conventions instead of introducing new styles or layers unless there’s a documented reason.

2. **Minimize risk**
   - Prefer small, reviewable changes. Break large work into incremental PRs.
   - Add or update tests for new behavior (and for bug fixes, add a regression test).
   - Use feature flags or configuration where appropriate so new logic can be toggled or rolled back without a full release.

3. **Respect boundaries**
   - Keep architecture layers clear: business logic out of UI, data access behind abstractions, no bypassing of dependency injection or shared services where they’re the standard.

4. **Validate before merge**
   - Run the project’s full quality pipeline (lint, analyze, tests, any automated guards). Fix failures; don’t merge on “it works on my machine” alone.
   - Do a quick manual check of affected flows when the change is user-facing or touches critical paths.

5. **Make changes reversible**
   - Avoid one-way data migrations or destructive changes without a rollback plan. Prefer backward-compatible APIs and feature flags so you can disable or revert new logic if needed.

**Summary:** In this app, “adding new logic” means placing it in the correct layer, following existing patterns and lifecycle rules, wiring it through DI, testing it, and running `./bin/checklist` before merge. In general, it means understanding the codebase, making small and testable changes, respecting architecture, running full validation, and keeping the option to roll back.

## 10. Common Troubleshooting

- **Stuck timers or async flows**: Ensure the cubit is disposed or the `TimerService` subscription is canceled in `close()`.
- **Remote Config not updating**: Confirm Firebase project settings match the current flavor (`main_dev.dart`, etc.) and that `RemoteConfigCubit`'s `refreshInterval` isn't throttling updates.
- **GraphQL/WebSocket issues**: Check the environment constants in `lib/core/config` and confirm the emulator/network allows outbound connections.
- **Maps API keys**: For Android, add to `android/app/src/main/AndroidManifest.xml`; for iOS, configure `ios/Runner/AppDelegate.swift` + `Info.plist`. The app gracefully falls back to Apple Maps when Google keys are missing.
- **GenUI Demo API key**: Requires `GEMINI_API_KEY` via `--dart-define=GEMINI_API_KEY=...` (recommended) or a local, git-ignored secrets mechanism used by `SecretConfig` (see the feature’s README/docs if present). Get your key from [Google AI Studio](https://makersuite.google.com/app/apikey). The app should show a user-facing error if the key is missing.
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

#### UI/UX Best Practices

- ✅ **Hard-coded colors**: Never use `Colors.black`, `Colors.white`, `Colors.grey`; always use `Theme.of(context).colorScheme`
- ✅ **Hard-coded strings**: Never hard-code user-facing text; always use `context.l10n.*` from ARB files
- ✅ **Raw Material buttons**: Never use `ElevatedButton`, `OutlinedButton`, `TextButton` directly; use `PlatformAdaptive.*` helpers
- ✅ **Fixed spacing/sizing**: Never use hard-coded pixel values; use `context.responsive*` helpers
- ✅ **Safe area**: Always handle safe-area insets (use `CommonPageLayout` or `SafeArea` + keyboard insets)
- ✅ **Text scaling**: Test layouts with text scale 1.3+; use flexible constraints, avoid fixed heights
- ✅ **Platform adaptation**: Use `PlatformAdaptive` helpers for buttons, dialogs, loading indicators

**Quick verification**: Run `./bin/checklist` before committing to catch formatting, analysis, and test issues.

## 11. DI Reference Example

```dart
MultiBlocProvider(providers: [
  BlocProvider(create: (_) => CounterCubit(repository: getIt<CounterRepository>(), timerService: getIt<TimerService>())..loadInitial()),
  BlocProvider(create: (_) => ThemeCubit(repository: getIt<ThemeRepository>())..loadInitial()),
], child: ...)
```

**Pattern:** Lazy singletons via `registerLazySingletonIfAbsent` (single instance, on-demand init, thread-safe). See `lib/core/di/injector.dart` for the main entry point.

## 12. Best‑Practice Validation Scripts

The delivery checklist runs automated checks to prevent common architecture and
Flutter hygiene regressions. Each script targets a high‑impact class of issues
that is easy to miss during review but costly to fix later.

Scripts and intent:

- `tool/check_flutter_domain_imports.sh` — Keeps Domain Dart‑only (no Flutter UI
  imports) to preserve clean architecture boundaries.
- `tool/check_material_buttons.sh` — Enforces platform‑adaptive buttons in
  presentation instead of raw Material buttons.
- `tool/check_no_hive_openbox.sh` — Blocks direct `Hive.openBox` usage so
  encryption/migration stay centralized via `HiveService`.
- `tool/check_raw_timer.sh` — Requires `TimerService` for testable, deterministic
  timing.
- `tool/check_direct_getit.sh` — Prevents direct `GetIt` access in presentation
  widgets; dependencies should be injected.
- `tool/check_raw_dialogs.sh` — Enforces `showAdaptiveDialog` over raw dialog APIs.
- `tool/check_raw_network_images.sh` — Enforces `CachedNetworkImageWidget` for
  remote images.
- `tool/check_raw_print.sh` — Blocks raw `print()` usage; use `AppLogger`.
- `tool/check_side_effects_build.sh` — Heuristic scan for side effects in
  `build()` (does not fail the checklist on its own).
- `tool/check_solid_presentation_data_imports.sh` — Blocks presentation imports
  of data-layer types.
- `tool/check_solid_data_presentation_imports.sh` — Blocks data-layer imports of
  presentation.
- `tool/check_perf_shrinkwrap_lists.sh` — Flags `shrinkWrap: true` in
  presentation lists.
- `tool/check_perf_nonbuilder_lists.sh` — Flags non-builder lists/grids in
  presentation.
- `tool/check_perf_missing_repaint_boundary.sh` — Flags heavy widgets missing
  `RepaintBoundary` (heuristic).
- `tool/check_memory_unclosed_streams.sh` — Flags `StreamController` without
  `.close()` (heuristic).
- `tool/check_memory_missing_dispose.sh` — Flags controllers without
  `dispose()` in State classes (heuristic).

Allowlisting exceptions:

If a specific line must violate a check (e.g., user‑initiated async callback),
add an inline comment on the same line or the line above:

```dart
// check-ignore: user action triggers async work
unawaited(cubit.flush());
```

Ignored entries are reported with the reason so exceptions remain explicit and
reviewable.

## 13. What to Read Next

### Essential Reading

- **`README.md`**: Feature tour + architecture diagram
- **`CODE_QUALITY.md`**: Comprehensive code quality analysis, architecture findings, and quality/resilience notes
- **`ui_ux_responsive_review.md`**: Comprehensive UI/UX guidelines, responsive design patterns, platform-adaptive components, accessibility best practices
- **`feature_overview.md`**: Complete catalog of features and capabilities

### Architecture & Design

- **`architecture_details.md`**: High-level architecture diagrams, principles, and state management flow
- **`clean_architecture.md`**: Practical guide with layer responsibilities, examples, and review checklist
- **`solid_principles.md`**: Detailed SOLID principles with codebase examples
- **`dry_principles.md`**: DRY consolidations and patterns

### Development Guides

- **`compile_time_safety.md`**: Complete guide to type-safe BLoC/Cubit patterns
- **`freezed_usage_analysis.md`**: Where Freezed is used and **why use Freezed with BLoC** (immutability, equality, sealed unions, copyWith)
- **`equatable_to_freezed_conversion.md`**: Step-by-step conversion from Equatable to Freezed
- **`flutter_best_practices_review.md`**: Best practices audit with action checklist
- **`validation_scripts.md`**: Automated validation scripts and their purposes

### Platform-Specific

- **`universal_links/`**: Universal links setup
- **`figma/`**: Figma integration guides
- **`offline_first/`**: Offline-first architecture patterns

Stay disciplined with the guardrails, keep tests deterministic, and reach for shared services before adding new singletons. Welcome to the team!
