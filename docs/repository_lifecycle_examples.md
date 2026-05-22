# Repository lifecycle — examples and testing

Continued from [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md).

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
    _configUpdatesSubscription = null;
    await _subscriptionManager.dispose();
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
