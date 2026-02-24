import 'dart:async';

/// Centralized holder for [StreamSubscription]s with a single [dispose] that
/// cancels all and marks the manager disposed.
///
/// Use in repositories, services, or any non-Cubit type that holds stream
/// subscriptions and must cancel them on dispose. [register] after creating a
/// subscription; call [dispose] when the owner is disposed. Check [isDisposed]
/// before creating or registering new subscriptions (e.g. in delayed restart
/// callbacks) to avoid creating subscriptions after dispose.
///
/// If [register] is called when [isDisposed] is true, the given subscription
/// is cancelled immediately so it does not leak.
///
/// Example:
/// ```dart
/// final _subs = SubscriptionManager();
///
/// void _startWatch() {
///   if (_subs.isDisposed) return;
///   final sub = stream.listen(...);
///   _subs.register(sub);
/// }
///
/// Future<void> dispose() async {
///   await _subs.dispose();
/// }
/// ```
class SubscriptionManager {
  bool _disposed = false;
  final Set<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>{};

  /// True after [dispose] has been called. Check before creating/registering
  /// new subscriptions (e.g. in restart logic).
  bool get isDisposed => _disposed;

  /// Registers a subscription to be cancelled when [dispose] is called.
  /// If already [isDisposed], [subscription] is cancelled immediately.
  void register(final StreamSubscription<dynamic>? subscription) {
    if (_disposed) {
      unawaited(subscription?.cancel());
      return;
    }
    if (subscription != null) {
      _subscriptions.add(subscription);
    }
  }

  /// Unregisters a subscription that has been cancelled independently.
  ///
  /// This keeps the manager's internal set bounded for owners that frequently
  /// recreate subscriptions during runtime (e.g. restartable stream watches).
  void unregister(final StreamSubscription<dynamic>? subscription) {
    if (subscription == null) {
      return;
    }
    _subscriptions.remove(subscription);
  }

  /// Marks the manager disposed and cancels all registered subscriptions.
  /// Safe to call multiple times; subsequent calls no-op.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final Set<StreamSubscription<dynamic>> copy =
        Set<StreamSubscription<dynamic>>.from(_subscriptions);
    _subscriptions.clear();
    for (final sub in copy) {
      await sub.cancel();
    }
  }
}
