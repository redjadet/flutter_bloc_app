import 'dart:async';

/// Helper to standardize initial load flows in repositories that expose
/// watch streams. Ensures only one initial load runs at a time, tracks
/// whether an initial value has been resolved, and allows resetting when
/// all listeners detach.
class RepositoryInitialLoadHelper<T> {
  RepositoryInitialLoadHelper({void Function()? onReset}) : _onReset = onReset;

  Completer<void>? _initialLoadCompleter;
  bool _hasResolvedInitialValue = false;
  final void Function()? _onReset;

  bool get hasResolvedInitialValue => _hasResolvedInitialValue;

  /// Triggers the initial load once and forwards the loaded value to [onValue].
  /// Subsequent calls while the initial load is in-flight will await the same
  /// completer to avoid duplicate requests.
  Future<void> ensureInitialLoad({
    required Future<T> Function() load,
    required void Function(T value) onValue,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    if (_initialLoadCompleter != null) {
      return _initialLoadCompleter!.future;
    }

    final Completer<void> completer = Completer<void>();
    _initialLoadCompleter = completer;

    unawaited(
      Future<void>(() async {
        try {
          final T value = await load();
          onValue(value);
          _hasResolvedInitialValue = true;
        } on Object catch (error, stackTrace) {
          onError?.call(error, stackTrace);
        } finally {
          if (!completer.isCompleted) {
            completer.complete();
          }
          _initialLoadCompleter = null;
        }
      }),
    );

    return completer.future;
  }

  /// Marks the helper as having resolved an initial value. Useful when values
  /// are updated outside of the initial load flow (e.g. on save).
  void markResolved() {
    _hasResolvedInitialValue = true;
  }

  /// Resets resolution state and triggers the optional reset callback so
  /// repositories can clear cached values when all listeners detach.
  void resetResolution() {
    _hasResolvedInitialValue = false;
    _onReset?.call();
  }
}
