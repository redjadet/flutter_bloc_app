# Repository Lifecycle and Dispose Methods

## Overview

This document explains the repository lifecycle in the Flutter BLoC app and when to use `dispose` methods for cleanup.

## Repository Lifecycle

### Standard Repository Pattern

Most repositories in this app follow a simple lifecycle:

1. **Creation:** Repository is created during dependency injection setup (`configureDependencies()`)
2. **Usage:** Repository is accessed via `getIt<RepositoryType>()` throughout the app
3. **Cleanup:** Repository is disposed when `getIt.reset()` is called (typically during tests or app shutdown)

### Singleton Pattern

All repositories are registered as **lazy singletons** in the dependency injection system:

- **Main file:** `lib/core/di/injector.dart` - Contains `configureDependencies()` and public API
- **Registrations:** `lib/core/di/injector_registrations.dart` - Contains all dependency registrations organized by category
- **Factories:** `lib/core/di/injector_factories.dart` - Contains factory functions for creating repositories
- **Helpers:** `lib/core/di/injector_helpers.dart` - Contains helper functions for registration

- **Single instance:** Only one instance exists throughout the app lifecycle
- **Lazy initialization:** Instance is created only when first requested
- **Shared state:** All parts of the app use the same repository instance

## When to Implement Dispose Methods

### ✅ Repositories That Need Dispose

Implement a `dispose()` method if your repository:

1. **Manages Stream Subscriptions**
   - Example: `EchoWebsocketRepository`, `RemoteConfigRepository`
   - **Why:** Prevents memory leaks from active subscriptions

2. **Maintains Network Connections**
   - Example: `EchoWebsocketRepository` (WebSocket), shared `Dio` instance (HTTP)
   - **Why:** Ensures connections are properly closed

3. **Holds StreamControllers**
   - Example: `EchoWebsocketRepository` (message and state controllers)
   - **Why:** Prevents memory leaks from unclosed controllers

4. **Manages Timers or Periodic Operations**
   - Example: Repositories with background polling or periodic updates
   - **Why:** Stops timers to prevent unnecessary work

### Shared lifecycle helpers

Prefer the repo’s shared lifecycle helpers instead of ad hoc sets/lists of
subscriptions or timers:

- `DisposableBag`: the underlying shared primitive for cancellable/closable
  resources.
- `SubscriptionManager`: thin repository/service facade for tracked
  `StreamSubscription`s.
- `TimerHandleManager`: thin repository/service facade for tracked
  `TimerDisposable` handles.
- `CubitSubscriptionMixin`: cubit-facing facade for tracked subscriptions and
  timers on `close()`.

`SubscriptionManager` and `TimerHandleManager` intentionally preserve their
type-specific APIs, but their cleanup behavior is centralized through
`DisposableBag`. Prefer these helpers over custom lifecycle bookkeeping unless a
class has a very specific ownership model that they do not fit.

### Memory pressure and cache trim (enterprise / high-traffic)

For high-traffic or memory-constrained environments, consider reacting to **memory pressure** (e.g. Flutter or platform callbacks when the system is under pressure) by trimming in-memory caches. Caches that are good candidates for trim-on-pressure include: search cache, profile cache, image cache (e.g. `CachedNetworkImage` provider), and any repository that holds large in-memory lists. Prefer a single entry point (e.g. a service or bootstrap callback) that calls `trim()` or equivalent on cache abstractions; document eviction policy and trim behavior here or in a short memory doc. This is optional and not required for normal usage.

This repo now routes automatic memory trimming through `AppScope` and a shared
memory service. Use that centralized path for app-wide memory pressure and
background trimming rather than adding per-feature `didHaveMemoryPressure()`
handlers. Runtime trimming should prefer in-memory caches and bounded image
caches; persistent offline-first data remains under explicit feature cache
policies.

### ❌ Repositories That Don't Need Dispose

Most repositories **don't need** a `dispose()` method:

- **Stateless repositories** (e.g., `HiveLocaleRepository`, `HiveThemeRepository`)
- **Simple CRUD repositories** that only use Hive boxes (managed by `HiveService`)
- **Mock repositories** used for testing
- **Repositories that only call external APIs** without maintaining connections

Continued in [`repository_lifecycle_examples.md`](repository_lifecycle_examples.md).
