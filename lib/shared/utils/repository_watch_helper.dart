import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Generic helper for managing repository watch streams with StreamController.
///
/// This helper provides a standardized pattern for repositories that need to
/// watch for changes and emit values to stream listeners. It handles:
/// - StreamController lifecycle management
/// - Initial value emission
/// - Error handling
/// - Subscription cleanup
/// - Caching of latest values
///
/// Example:
/// ```dart
/// class MyRepository {
///   final RepositoryWatchHelper<MyData> _watchHelper = RepositoryWatchHelper<MyData>(
///     loadInitial: () => _loadFromStorage(),
///     emptyValue: MyData.empty(),
///   );
///
///   Stream<MyData> watch() {
///     _watchHelper.createWatchController(
///       onListen: () => _watchHelper.handleOnListen(),
///       onCancel: () => _watchHelper.handleOnCancel(),
///     );
///     return _watchHelper.stream;
///   }
///
///   void emitValue(MyData value) {
///     _watchHelper.emitValue(value);
///   }
/// }
/// ```
class RepositoryWatchHelper<T> {
  RepositoryWatchHelper({
    required this.loadInitial,
    required this.emptyValue,
    this.onError,
  });

  /// Callback to load the initial value from storage.
  final Future<T> Function() loadInitial;

  /// The empty value to use as fallback.
  final T emptyValue;

  /// Optional error handler for load errors.
  final void Function(Object error, StackTrace stackTrace)? onError;

  StreamController<T>? _watchController;
  T? _cachedValue;
  Future<void>? _pendingInitialNotification;

  /// Gets the current cached value.
  T? get cachedValue => _cachedValue;

  /// Sets the cached value.
  set cachedValue(final T value) => _cachedValue = value;

  /// Gets the stream for watching values.
  ///
  /// Returns the stream from the watch controller, or creates a new controller
  /// if one doesn't exist yet. The controller will be properly initialized
  /// when [createWatchController] is called.
  Stream<T> get stream {
    _watchController ??= StreamController<T>.broadcast();
    return _watchController!.stream;
  }

  /// Creates and initializes the watch controller if not already created.
  ///
  /// Sets up the onListen and onCancel callbacks for the stream controller.
  /// If the controller was already created (e.g., by accessing [stream]),
  /// this method will recreate it with the proper callbacks.
  void createWatchController({
    required final void Function() onListen,
    required final Future<void> Function() onCancel,
  }) {
    // If controller exists but wasn't initialized with callbacks, close and recreate
    final StreamController<T>? existing = _watchController;
    if (existing != null) {
      // Only recreate if controller has no listeners (safe to close)
      // This prevents unnecessary recreation when listeners are active
      if (!existing.hasListener && !existing.isClosed) {
        unawaited(existing.close());
        _watchController = null;
      } else if (existing.hasListener) {
        // Controller already has listeners, don't recreate
        return;
      }
    }
    _watchController ??= StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  /// Handles when a listener subscribes to the watch stream.
  ///
  /// Emits cached value if available, then triggers initial load if needed.
  void handleOnListen() {
    final T? cached = _cachedValue;
    if (cached != null) {
      emitValue(cached);
    }
    _pendingInitialNotification ??= _loadAndEmitInitial();
    unawaited(_pendingInitialNotification);
  }

  /// Handles when a listener unsubscribes from the watch stream.
  ///
  /// Cleans up the controller if no listeners remain.
  Future<void> handleOnCancel() async {
    final StreamController<T>? controller = _watchController;
    if (controller == null) {
      return;
    }
    if (!controller.hasListener) {
      _watchController = null;
      _pendingInitialNotification = null;
      await controller.close();
    }
  }

  /// Loads and emits the initial value.
  ///
  /// Prevents concurrent loads by reusing an existing pending load future
  /// if one is already in progress.
  Future<void> _loadAndEmitInitial() async {
    // Prevent concurrent loads by reusing existing pending load
    final Future<void>? pending = _pendingInitialNotification;
    if (pending != null) {
      // Wait for existing load to complete, then check if another was triggered
      try {
        await pending;
      } on Exception {
        // Ignore errors from pending load - they're handled in _performLoadAndEmit
      }
      // If another load was triggered while waiting, return early
      // This prevents duplicate loads when multiple events fire rapidly
      if (_pendingInitialNotification != null &&
          _pendingInitialNotification != pending) {
        return;
      }
    }

    // Start new load operation
    final Future<void> currentLoad = _performLoadAndEmit();
    _pendingInitialNotification = currentLoad;
    try {
      await currentLoad;
    } finally {
      // Only clear if this is still the current pending operation
      // (prevents clearing if a new load started during execution)
      if (_pendingInitialNotification == currentLoad) {
        _pendingInitialNotification = null;
      }
    }
  }

  /// Performs the actual load and emit operation.
  Future<void> _performLoadAndEmit() async {
    try {
      final T value = await loadInitial();
      emitValue(value);
    } on Exception catch (error, stackTrace) {
      if (onError != null) {
        onError!(error, stackTrace);
      } else {
        AppLogger.error(
          'RepositoryWatchHelper.loadInitial failed',
          error,
          stackTrace,
        );
      }
      // Emit cached value or empty value on error
      final T? cached = _cachedValue;
      if (cached != null) {
        emitValue(cached);
      } else {
        emitValue(emptyValue);
      }
    }
  }

  /// Emits a value to all active stream listeners.
  ///
  /// Caches the value and safely adds it to the stream controller.
  void emitValue(final T value) {
    _cachedValue = value;
    final StreamController<T>? controller = _watchController;
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(value);
  }

  /// Disposes of all resources.
  ///
  /// Should be called when the repository is being disposed.
  Future<void> dispose() async {
    _pendingInitialNotification = null;
    await _watchController?.close();
    _watchController = null;
  }
}
