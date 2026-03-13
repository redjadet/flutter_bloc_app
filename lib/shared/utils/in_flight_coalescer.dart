import 'dart:async';

// Futures are returned to callers or passed to unawaited(); not discarded.
// ignore_for_file: discarded_futures

/// Single-flight gate: concurrent callers share one running [Future].
///
/// Use in repositories/services when multiple callers should await the same
/// in-flight work (e.g. refresh, pullRemote) instead of starting duplicate work.
///
/// Example:
/// ```dart
/// final InFlightCoalescer _coalescer = InFlightCoalescer();
/// Future<void> refresh() => _coalescer.run(() => _doRefresh());
/// ```
class InFlightCoalescer {
  Future<void>? _future;

  /// Runs [work] or returns the existing future if work is already in flight.
  /// When the future completes, the gate is cleared so the next call starts fresh.
  Future<void> run(final Future<void> Function() work) {
    final Future<void>? inFlight = _future;
    if (inFlight != null) {
      return inFlight;
    }
    final Future<void> f = Future<void>.sync(work);
    _future = f;
    unawaited(
      f.then<void>(
        (_) => _clear(f),
        onError: (final Object _, final StackTrace _) => _clear(f),
      ),
    );
    return f;
  }

  void _clear(final Future<void> future) {
    if (identical(_future, future)) {
      _future = null;
    }
  }
}

/// Keyed single-flight: one in-flight future per key.
///
/// Use when concurrent calls for the same key should share one run (e.g.
/// per-query refresh). Calls for different keys run concurrently.
///
/// Example:
/// ```dart
/// final KeyedInFlightCoalescer<String> _coalescer = KeyedInFlightCoalescer<String>();
/// Future<void> refreshQuery(String query) =>
///     _coalescer.run(query, () => _doRefreshAndCache(query));
/// ```
class KeyedInFlightCoalescer<K> {
  final Map<K, Future<void>> _byKey = <K, Future<void>>{};

  /// Runs [work] for [key], or returns the existing future if work for [key] is in flight.
  /// When the future completes, the key is cleared.
  Future<void> run(final K key, final Future<void> Function() work) {
    final Future<void>? inFlight = _byKey[key];
    if (inFlight != null) {
      return inFlight;
    }
    final Future<void> f = Future<void>.sync(work);
    _byKey[key] = f;
    unawaited(
      f.then<void>(
        (_) => _clear(key, f),
        onError: (final Object _, final StackTrace _) => _clear(key, f),
      ),
    );
    return f;
  }

  void _clear(final K key, final Future<void> future) {
    if (identical(_byKey[key], future)) {
      _byKey.remove(key);
    }
  }
}
