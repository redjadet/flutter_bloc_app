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
   - Example: `EchoWebsocketRepository` (WebSocket), `http.Client` (HTTP connections)
   - **Why:** Ensures connections are properly closed

3. **Holds StreamControllers**
   - Example: `EchoWebsocketRepository` (message and state controllers)
   - **Why:** Prevents memory leaks from unclosed controllers

4. **Manages Timers or Periodic Operations**
   - Example: Repositories with background polling or periodic updates
   - **Why:** Stops timers to prevent unnecessary work

### Memory pressure and cache trim (enterprise / high-traffic)

For high-traffic or memory-constrained environments, consider reacting to **memory pressure** (e.g. Flutter or platform callbacks when the system is under pressure) by trimming in-memory caches. Caches that are good candidates for trim-on-pressure include: search cache, profile cache, image cache (e.g. `CachedNetworkImage` provider), and any repository that holds large in-memory lists. Prefer a single entry point (e.g. a service or bootstrap callback) that calls `trim()` or equivalent on cache abstractions; document eviction policy and trim behavior here or in a short memory doc. This is optional and not required for normal usage.

### ❌ Repositories That Don't Need Dispose

Most repositories **don't need** a `dispose()` method:

- **Stateless repositories** (e.g., `HiveLocaleRepository`, `HiveThemeRepository`)
- **Simple CRUD repositories** that only use Hive boxes (managed by `HiveService`)
- **Mock repositories** used for testing
- **Repositories that only call external APIs** without maintaining connections

## Examples

### Example 1: WebSocket Repository (Needs Dispose)

```dart
class EchoWebsocketRepository implements WebsocketRepository {
  StreamController<WebsocketMessage> _messagesController;
  StreamSubscription<dynamic>? _channelSubscription;
  WebSocketChannel? _channel;

  @override
  Future<void> dispose() async {
    // Cancel pending connection attempts
    _connectionCompleter?.completeError(...);

    // Close WebSocket connection
    await disconnect();

    // Close stream controllers
    await _messagesController.close();
    await _stateController.close();
  }
}
```

**Why dispose is needed:**

- Closes WebSocket connection
- Cancels active subscriptions
- Closes stream controllers to prevent memory leaks

### Example 2: Remote Config Repository (Needs Dispose)

```dart
class RemoteConfigRepository implements RemoteConfigRepository {
  StreamSubscription<RemoteConfigUpdate>? _configUpdatesSubscription;

  Future<void> dispose() async {
    await _configUpdatesSubscription?.cancel();
    _configUpdatesSubscription = null;
    _isInitialized = false;
  }
}
```

**Why dispose is needed:**

- Cancels Firebase Remote Config update subscriptions
- Prevents memory leaks from active listeners

### Example 3: Hive Repository (No Dispose Needed)

```dart
class HiveLocaleRepository extends HiveRepositoryBase implements LocaleRepository {
  // No dispose method needed

  @override
  Future<void> saveLocale(Locale locale) async {
    final box = await getBox();
    await box.put('locale', locale.languageCode);
  }
}
```

**Why dispose is not needed:**

- Stateless repository
- Hive boxes are managed by `HiveService`
- No subscriptions or connections to clean up

## Registering Dispose Callbacks

When registering a repository with a dispose method, use the `dispose` parameter:

```dart
_registerLazySingletonIfAbsent<WebsocketRepository>(
  EchoWebsocketRepository.new,
  dispose: (final repository) => repository.dispose(), // ✅ Register dispose callback
);
```

## Testing Considerations

### In Tests

When writing tests, always reset GetIt to ensure clean state:

```dart
setUp(() async {
  await getIt.reset(dispose: true); // ✅ Calls all dispose callbacks
  await configureDependencies();
});
```

### Testing Dispose Methods

Test that dispose methods work correctly:

```dart
test('dispose closes WebSocket connection', () async {
  final repository = EchoWebsocketRepository();
  await repository.connect();

  await repository.dispose();

  expect(repository.currentState.status, WebsocketStatus.disconnected);
  // Verify connections are closed, subscriptions cancelled, etc.
});
```

## Best Practices

1. **Always implement dispose for repositories with subscriptions or connections**
2. **Make dispose idempotent** - calling it multiple times should be safe
3. **Use `await` for async cleanup operations** in dispose methods
4. **Cancel subscriptions before closing controllers** to avoid errors
5. **Set references to null after cleanup** to help garbage collection
6. **Document why dispose is needed** in repository class comments

## Summary

- **Most repositories don't need dispose** - only those with subscriptions, connections, or controllers
- **Register dispose callbacks** in `lib/core/di/injector_registrations.dart` for repositories that need cleanup (called from `configureDependencies()`)
- **Always reset GetIt in tests** to ensure proper cleanup
- **Make dispose methods idempotent** and handle errors gracefully
