import 'dart:async';

/// Utility wrapper around [Completer] to standardize safe completion patterns.
class CompleterHelper<T> {
  Completer<T>? _completer;

  /// Returns the active, uncompleted completer if present.
  Completer<T>? get pending {
    final Completer<T>? current = _completer;
    if (current == null || current.isCompleted) return null;
    return current;
  }

  /// Returns the pending future, or null if none is active.
  Future<T>? get pendingFuture => pending?.future;

  /// Creates a new completer if none is pending, otherwise returns the existing one.
  Completer<T> start() {
    final Completer<T>? existing = pending;
    if (existing != null) return existing;
    _completer = Completer<T>();
    return _completer!;
  }

  /// Completes the pending completer when available.
  bool complete([final T? value]) {
    final Completer<T>? current = pending;
    if (current == null) return false;
    current.complete(value as T);
    return true;
  }

  /// Completes the pending completer with an error when available.
  bool completeError(final Object error, [final StackTrace? stackTrace]) {
    final Completer<T>? current = pending;
    if (current == null) return false;
    current.completeError(error, stackTrace);
    return true;
  }

  /// Completes the pending completer and resets internal state.
  bool completeAndReset([final T? value]) {
    final bool didComplete = complete(value);
    _completer = null;
    return didComplete;
  }

  /// Completes the pending completer with an error and resets internal state.
  bool completeErrorAndReset(
    final Object error, [
    final StackTrace? stackTrace,
  ]) {
    final bool didComplete = completeError(error, stackTrace);
    _completer = null;
    return didComplete;
  }

  /// Clears any stored completer without completing it.
  void reset() {
    _completer = null;
  }
}
