import 'dart:async';

import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository_watch_state.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/subscription_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Helper class for managing Hive box watch subscriptions and stream emissions.
///
/// Handles the complexity of watching Hive box changes and emitting snapshots
/// to stream listeners, including error handling and concurrent operation prevention.
class HiveCounterRepositoryWatchHelper {
  HiveCounterRepositoryWatchHelper({
    required this.loadSnapshot,
    required this.emptySnapshot,
    required this.getBox,
  }) : _watchState = HiveCounterRepositoryWatchState(
         loadSnapshot: loadSnapshot,
         emptySnapshot: emptySnapshot,
       );

  /// Callback to load the current snapshot from storage.
  final Future<CounterSnapshot> Function() loadSnapshot;

  /// The empty snapshot to use as fallback.
  final CounterSnapshot emptySnapshot;

  /// Callback to get the Hive box.
  final Future<Box<dynamic>> Function() getBox;

  StreamSubscription<BoxEvent>? _boxSubscription;
  final HiveCounterRepositoryWatchState _watchState;
  final SubscriptionManager _subscriptionManager = SubscriptionManager();

  static const String _keyCount = 'count';
  static const String _keyChanged = 'last_changed';
  static const String _keyUserId = 'user_id';

  /// Gets the current cached snapshot.
  CounterSnapshot? get cachedSnapshot => _watchState.cachedSnapshot;

  /// Sets the cached snapshot.
  set cachedSnapshot(final CounterSnapshot snapshot) =>
      _watchState.cachedSnapshot = snapshot;

  /// Gets the stream for watching snapshots.
  ///
  /// Returns the stream from the watch controller, or creates a new controller
  /// if one doesn't exist yet. The controller will be properly initialized
  /// when [createWatchController] is called.
  Stream<CounterSnapshot> get stream => _watchState.stream;

  /// Creates and initializes the watch controller if not already created.
  ///
  /// Sets up the onListen and onCancel callbacks for the stream controller.
  /// If the controller was already created (e.g., by accessing [stream]),
  /// this method will recreate it with the proper callbacks.
  void createWatchController({
    required final void Function() onListen,
    required final Future<void> Function() onCancel,
  }) => _watchState.createController(onListen: onListen, onCancel: onCancel);

  /// Handles when a listener subscribes to the watch stream.
  void handleOnListen() {
    final CounterSnapshot? cached = _watchState.cachedSnapshot;
    if (cached != null) {
      emitSnapshot(cached);
    }
    unawaited(_watchState.loadAndEmitInitial());
    unawaited(_startBoxWatch());
  }

  /// Handles when a listener unsubscribes from the watch stream.
  Future<void> handleOnCancel() async {
    final StreamSubscription<BoxEvent>? subscription = _boxSubscription;
    _boxSubscription = null;
    _subscriptionManager.unregister(subscription);
    await subscription?.cancel();
    await _watchState.closeIfNoListeners();
  }

  /// Starts watching the Hive box for changes.
  ///
  /// Optimized to prevent concurrent watch setup and handle errors gracefully.
  /// The subscription is automatically cancelled on error to prevent repeated
  /// error emissions.
  Future<void> _startBoxWatch() async {
    // Prevent concurrent watch setup - early return if already watching or disposed
    if (_boxSubscription != null || _subscriptionManager.isDisposed) {
      return;
    }

    try {
      final Box<dynamic> box = await getBox();

      // After async: avoid creating subscription if disposed or another watch started
      if (_boxSubscription != null || _subscriptionManager.isDisposed) {
        return;
      }

      // Cancel any existing subscription (defensive check)
      await _boxSubscription?.cancel();

      _boxSubscription = box.watch().listen(
        (final event) {
          // Only trigger load for relevant keys to avoid unnecessary work
          if (_isRelevantKey(event.key)) {
            unawaited(_watchState.loadAndEmitInitial());
          }
        },
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error(
            'Hive box watch error',
            error,
            stackTrace,
          );
          // Cancel subscription on error to prevent repeated errors
          // Use unawaited since we're in an error handler
          final StreamSubscription<BoxEvent>? subscription = _boxSubscription;
          _boxSubscription = null;
          _subscriptionManager.unregister(subscription);
          unawaited(subscription?.cancel());
        },
        cancelOnError: false, // We handle errors manually
      );
      _subscriptionManager.register(_boxSubscription);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to start Hive box watch',
        error,
        stackTrace,
      );
      // Reset subscription on failure to allow retry
      _boxSubscription = null;
      // Don't crash - fallback to polling if watch fails
      // This is handled gracefully by the stream controller
    }
  }

  /// Checks if a Hive box key is relevant for counter updates.
  bool _isRelevantKey(final dynamic key) =>
      key == _keyCount || key == _keyChanged || key == _keyUserId;

  /// Emits a snapshot to all active stream listeners.
  void emitSnapshot(final CounterSnapshot snapshot) {
    _watchState.emitSnapshot(snapshot);
  }

  /// Disposes of all resources.
  Future<void> dispose() async {
    _boxSubscription = null;
    await _subscriptionManager.dispose();
    await _watchState.dispose();
  }
}
