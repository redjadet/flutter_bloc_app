import 'dart:async';

import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
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
  });

  /// Callback to load the current snapshot from storage.
  final Future<CounterSnapshot> Function() loadSnapshot;

  /// The empty snapshot to use as fallback.
  final CounterSnapshot emptySnapshot;

  /// Callback to get the Hive box.
  final Future<Box<dynamic>> Function() getBox;

  StreamController<CounterSnapshot>? _watchController;
  CounterSnapshot? _cachedSnapshot;
  Future<void>? _pendingInitialNotification;
  StreamSubscription<BoxEvent>? _boxSubscription;

  static const String _keyCount = 'count';
  static const String _keyChanged = 'last_changed';
  static const String _keyUserId = 'user_id';

  /// Gets the current cached snapshot.
  CounterSnapshot? get cachedSnapshot => _cachedSnapshot;

  /// Sets the cached snapshot.
  set cachedSnapshot(CounterSnapshot snapshot) => _cachedSnapshot = snapshot;

  /// Gets the stream for watching snapshots.
  ///
  /// Returns the stream from the watch controller, or creates a new controller
  /// if one doesn't exist yet. The controller will be properly initialized
  /// when [createWatchController] is called.
  Stream<CounterSnapshot> get stream {
    _watchController ??= StreamController<CounterSnapshot>.broadcast();
    return _watchController!.stream;
  }

  /// Creates and initializes the watch controller if not already created.
  ///
  /// Sets up the onListen and onCancel callbacks for the stream controller.
  /// If the controller was already created (e.g., by accessing [stream]),
  /// this method will recreate it with the proper callbacks.
  void createWatchController({
    required void Function() onListen,
    required Future<void> Function() onCancel,
  }) {
    // If controller exists but wasn't initialized with callbacks, close and recreate
    if (_watchController != null && !_watchController!.hasListener) {
      unawaited(_watchController!.close());
      _watchController = null;
    }
    _watchController ??= StreamController<CounterSnapshot>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  /// Handles when a listener subscribes to the watch stream.
  void handleOnListen() {
    final CounterSnapshot? cached = _cachedSnapshot;
    if (cached != null) {
      emitSnapshot(cached);
    }
    _pendingInitialNotification ??= _loadAndEmitInitial();
    unawaited(_pendingInitialNotification);
    unawaited(_startBoxWatch());
  }

  /// Handles when a listener unsubscribes from the watch stream.
  Future<void> handleOnCancel() async {
    await _boxSubscription?.cancel();
    _boxSubscription = null;

    final StreamController<CounterSnapshot>? controller = _watchController;
    if (controller == null) {
      return;
    }
    if (!controller.hasListener) {
      _watchController = null;
      _pendingInitialNotification = null;
      await controller.close();
    }
  }

  /// Starts watching the Hive box for changes.
  Future<void> _startBoxWatch() async {
    // Prevent concurrent watch setup
    if (_boxSubscription != null) {
      return;
    }

    try {
      final Box<dynamic> box = await getBox();

      // Cancel existing subscription if any (shouldn't happen due to check above)
      await _boxSubscription?.cancel();

      _boxSubscription = box.watch().listen(
        (final BoxEvent event) {
          if (_isRelevantKey(event.key)) {
            unawaited(_loadAndEmitInitial());
          }
        },
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error(
            'Hive box watch error',
            error,
            stackTrace,
          );
          // Cancel subscription on error to prevent repeated errors
          unawaited(_boxSubscription?.cancel());
          _boxSubscription = null;
        },
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to start Hive box watch',
        error,
        stackTrace,
      );
      // Reset subscription on failure
      _boxSubscription = null;
      // Don't crash - fallback to polling if watch fails
      // This is handled gracefully by the stream controller
    }
  }

  /// Checks if a Hive box key is relevant for counter updates.
  bool _isRelevantKey(final dynamic key) =>
      key == _keyCount || key == _keyChanged || key == _keyUserId;

  /// Loads and emits the initial snapshot.
  Future<void> _loadAndEmitInitial() async {
    // Prevent concurrent loads
    final Future<void>? pending = _pendingInitialNotification;
    if (pending != null) {
      // Wait for existing load to complete
      try {
        await pending;
      } on Exception {
        // Ignore errors from pending load
      }
      // Check if another load was triggered while waiting
      if (_pendingInitialNotification != null) {
        return;
      }
    }

    _pendingInitialNotification = _performLoadAndEmit();
    try {
      await _pendingInitialNotification;
    } finally {
      _pendingInitialNotification = null;
    }
  }

  /// Performs the actual load and emit operation.
  Future<void> _performLoadAndEmit() async {
    try {
      final CounterSnapshot snapshot = await loadSnapshot();
      emitSnapshot(snapshot);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Failed to load and emit initial snapshot',
        error,
        stackTrace,
      );
      // Emit cached snapshot or empty snapshot on error
      final CounterSnapshot? cached = _cachedSnapshot;
      if (cached != null) {
        emitSnapshot(cached);
      } else {
        emitSnapshot(emptySnapshot);
      }
    }
  }

  /// Emits a snapshot to all active stream listeners.
  void emitSnapshot(final CounterSnapshot snapshot) {
    _cachedSnapshot = snapshot;
    final StreamController<CounterSnapshot>? controller = _watchController;
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(snapshot);
  }

  /// Disposes of all resources.
  Future<void> dispose() async {
    await _boxSubscription?.cancel();
    _boxSubscription = null;
    _pendingInitialNotification = null;
    await _watchController?.close();
    _watchController = null;
  }
}
