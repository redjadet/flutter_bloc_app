import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/disposable_bag.dart';

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
  final DisposableBag _disposables = DisposableBag();

  /// True after [dispose] has been called. Check before creating/registering
  /// new subscriptions (e.g. in restart logic).
  bool get isDisposed => _disposables.isDisposed;

  /// Registers a subscription to be cancelled when [dispose] is called.
  /// If already [isDisposed], [subscription] is cancelled immediately.
  T register<T extends StreamSubscription<dynamic>?>(final T subscription) {
    if (_disposables.isDisposed) {
      unawaited(subscription?.cancel());
      return subscription;
    }
    _disposables.trackSubscription<StreamSubscription<dynamic>?>(subscription);
    return subscription;
  }

  /// Unregisters a subscription that has been cancelled independently.
  ///
  /// This keeps the manager's internal set bounded for owners that frequently
  /// recreate subscriptions during runtime (e.g. restartable stream watches).
  void unregister(final StreamSubscription<dynamic>? subscription) {
    _disposables.untrackSubscription(subscription);
  }

  /// Cancels a registered subscription and removes it from the tracked set.
  Future<void> cancelRegistered(
    final StreamSubscription<dynamic>? subscription,
  ) async {
    if (subscription == null) {
      return;
    }
    unregister(subscription);
    await subscription.cancel();
  }

  /// Cancels all registered subscriptions while keeping the manager reusable.
  Future<void> clear() async {
    await _disposables.clear();
  }

  /// Marks the manager disposed and cancels all registered subscriptions.
  /// Safe to call multiple times; subsequent calls no-op.
  Future<void> dispose() async {
    await _disposables.dispose();
  }
}
