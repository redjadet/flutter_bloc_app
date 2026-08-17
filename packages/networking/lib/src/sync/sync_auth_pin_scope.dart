/// Pins the Firebase auth uid for the duration of a pending-sync push.
///
/// Remote repositories read [current] in [runWithAuthUser] and fail closed when
/// the live provider uid diverges (account switch mid-await).
abstract final class SyncAuthPinScope {
  static String? _current;

  /// Active pin for the current async scope, if any.
  static String? get current => _current;

  /// Runs [action] while [uid] is pinned; restores the previous pin afterward.
  static Future<T> runWithPin<T>(
    String? uid,
    Future<T> Function() action,
  ) async {
    final String? previous = _current;
    _current = uid;
    try {
      return await action();
    } finally {
      _current = previous;
    }
  }
}

/// Thrown when a pinned sync push observes a different Firebase auth uid.
class SyncAuthUserChangedException implements Exception {
  const SyncAuthUserChangedException();

  @override
  String toString() => 'SyncAuthUserChangedException';
}
