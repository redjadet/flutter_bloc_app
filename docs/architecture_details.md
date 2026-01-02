# Architecture Details

This document captures the architecture diagram, key principles, state management rationale, and dependency flow patterns used throughout the app.

> **Related:** [Clean Architecture](clean_architecture.md) | [SOLID Principles](solid_principles.md) | [DRY Principles](dry_principles.md)

## Architecture Diagram

```mermaid
flowchart LR
  AppScope["AppScope<br/>(MultiBlocProvider + DeepLinkListener + Lazy sync bootstrap)"]

  subgraph Presentation
    Widgets["Widgets & Pages<br/>(ResponsiveScope, PlatformAdaptive, BlocSelector)"]
    FeatureCubits["Feature Cubits<br/>(Counter, Chat, Search, Profile, GraphQL, WebSocket, Calculator)"]
    InfraCubits["Infra Cubits<br/>(Theme, Locale, RemoteConfig, DeepLink, SyncStatus)"]
    Router["GoRouter / Navigation"]
  end

  subgraph Domain
    Contracts["Domain Contracts + Models<br/>(Repository interfaces, value objects)"]
  end

  subgraph Data
    OfflineRepos["OfflineFirst* Repositories<br/>(Counter, Chat, Search, Profile, RemoteConfig, GraphQL)"]
    CacheRepos["Hive Cache Repositories<br/>(Locale, Theme, Search, Profile, Remote Config)"]
    RemoteRepos["Remote APIs<br/>(HTTP/REST, GraphQL, HuggingFace, Firebase, Maps)"]
  end

  subgraph Sync
    PendingSync["PendingSyncRepository (Hive)"]
    Registry["SyncableRepositoryRegistry"]
    Coordinator["BackgroundSyncCoordinator"]
    NetworkStatus["NetworkStatusService"]
  end

  subgraph Services
    HiveService
    TimerService
    BiometricAuthenticator
    DeepLinkService
    RemoteConfigService
    NativePlatformService
    ErrorNotificationService
  end

  subgraph Shared
    ResponsiveExt["Responsive Extensions<br/>(spacing, typography, grids)"]
    ContextUtilsNode["Context/Navigation Utils<br/>(mounted guards, pop helpers)"]
    ErrorHandlingNode["ErrorHandling<br/>(snackbars, dialogs, loaders)"]
    BlocProviderHelpers["BlocProviderHelpers<br/>(async init safeguards)"]
  end

  Injector["Dependency Injection<br/>(get_it + injector_*.dart)"]

  AppScope --> Widgets
  AppScope --> FeatureCubits
  AppScope --> InfraCubits
  Widgets --> FeatureCubits
  Widgets --> InfraCubits
  Widgets --> ResponsiveExt
  Widgets --> Router
  FeatureCubits --> Contracts
  InfraCubits --> Contracts
  Contracts --> OfflineRepos
  Contracts --> CacheRepos
  Contracts --> RemoteRepos
  OfflineRepos --> PendingSync
  OfflineRepos --> CacheRepos
  OfflineRepos --> RemoteRepos
  CacheRepos --> HiveService
  OfflineRepos --> HiveService
  FeatureCubits --> TimerService
  InfraCubits --> ErrorNotificationService
  RemoteRepos --> RemoteConfigService
  RemoteRepos --> DeepLinkService
  RemoteRepos --> NativePlatformService
  PendingSync --> Coordinator
  Registry --> Coordinator
  NetworkStatus --> Coordinator
  Coordinator --> PendingSync
  Coordinator --> InfraCubits
  Injector --> AppScope
  Injector --> Services
  Injector --> OfflineRepos
  Injector --> CacheRepos
  Injector --> RemoteRepos
  ResponsiveExt -.-> Widgets
  ContextUtilsNode -.-> Widgets
  ErrorHandlingNode -.-> Widgets
  BlocProviderHelpers -.-> AppScope
```

## Key Principles

- Clean boundaries: widgets depend on cubits, cubits depend on domain contracts
- Feature cubits (including Counter) are created at route scope to minimize startup work
- Presentation uses responsive helpers and `PlatformAdaptive.*` components
- DI and bootstrap centralized in `injector*.dart` and `AppScope`
- Offline-first repositories coordinate cache, remote, and sync queues
- Deferred route loading keeps heavy features out of the initial bundle
- Lazy startup: background sync and remote config initialize on first use
- Lifecycle safety via `CubitExceptionHandler`, `CubitSubscriptionMixin`,
  `CubitStateEmissionMixin`, and mounted checks

## State Management Rationale (Why BLoC)

- Predictable, replayable state transitions (events in, state out)
- Business rules isolated from widgets for unit/bloc testing
- `BlocSelector` limits rebuild scope for performance
- Immutable states reduce accidental side effects
- **Compile-time safety** via type-safe extensions and widgets (see [Compile-Time Safety Usage Guide](compile_time_safety_usage.md))

> **For detailed comparison with Riverpod and comprehensive rationale, see [State Management Choice](state_management_choice.md)**

## Lazy Loading Patterns

This codebase implements comprehensive lazy loading strategies to optimize startup time and bundle size:

### Deferred Routes

Heavy features are loaded via `DeferredPage` + `deferred as` imports in `lib/app/router/routes.dart`. These features ship outside the initial bundle and load on-demand when the user navigates to them:

- **Google Maps** - Heavy native SDK dependencies
- **Markdown Editor** - Custom RenderObject implementation
- **Charts** - Data visualization libraries
- **WebSocket** - Real-time communication libraries

```dart
GoRoute(
  path: AppRoutes.googleMapsPath,
  name: AppRoutes.googleMaps,
  builder: (context, state) => DeferredPage(
    loadLibrary: google_maps_page.loadLibrary,
    builder: (context) => google_maps_page.buildGoogleMapsPage(),
  ),
),
```

**Impact:** Significant reduction in initial app bundle size (estimated 9-17 MB saved) and faster startup time.

### On-Demand Services

- **BackgroundSyncCoordinator**: Starts via `SyncStatusCubit.ensureStarted()` when first sync-dependent feature is accessed
- **RemoteConfigCubit**: Initializes via `RemoteConfigCubit.ensureInitialized()` only when a feature requests config values
- **Dependency Injection**: All services use lazy singletons (`registerLazySingletonIfAbsent`) - instances created only on first access

### Route-Level Cubit Initialization

Most feature-specific cubits (Chat, Maps, GraphQL, Profile, WebSocket) are created at route level rather than app scope, reducing memory footprint for unused features.

> **See also:** [Lazy Loading Review](../analysis/lazy_loading_late_review.md) for comprehensive analysis, implementation details, and best practices.

## State Management Flow

```mermaid
sequenceDiagram
  participant AppScope
  participant DI
  participant User
  participant View
  participant SharedUtils
  participant Cubit
  participant Repository
  participant Cache
  participant Remote
  participant SyncLayer
  participant Services

  AppScope->>DI: ensureConfigured() + registerAllDependencies()
  AppScope->>SyncLayer: seed SyncStatusCubit (starts background sync on demand)
  AppScope->>Cubit: create via BlocProviderHelpers.withAsyncInit()
  AppScope->>View: wrap with ResponsiveScope + DeepLinkListener + GoRouter
  User->>View: Trigger interaction (tap, navigation, lifecycle)
  View->>SharedUtils: Apply responsive spacing + mounted/nav guards
  SharedUtils-->>View: Guarded callbacks (ContextUtils, NavigationUtils)
  View->>Cubit: Invoke feature action (load, fetch, increment)
  Cubit->>Repository: Call domain contract via DI
  Repository->>Cache: Read/write via HiveService + cache repos
  Repository->>Remote: HTTP/GraphQL/HuggingFace/Firebase/RemoteConfig/DeepLink
  Repository->>SyncLayer: Queue offline ops in PendingSyncRepository
  SyncLayer-->>Repository: Flush queued writes when online (TimerService-driven)
  Remote-->>Repository: Data/errors (normalized via CubitExceptionHandler)
  Repository-->>Cubit: Domain models or failures
  Cubit-->>View: Emit new Equatable/freezed state
  View->>SharedUtils: Surface errors/toasts via ErrorHandling/NavigationUtils
  SharedUtils-->>User: UI updates, dialogs, snackbars
```
