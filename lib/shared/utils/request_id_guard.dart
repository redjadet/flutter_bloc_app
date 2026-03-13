/// Guard for ignoring stale async completions in cubits (request-id pattern).
///
/// Increment [next] when starting a load; before emitting success/error check
/// [isCurrent](id) so older completions don't overwrite newer state.
///
/// Example:
/// ```dart
/// final RequestIdGuard _guard = RequestIdGuard();
/// Future<void> load() async {
///   final int id = _guard.next();
///   emit(state.copyWith(status: ViewStatus.loading));
///   final result = await repository.fetch();
///   if (isClosed || !_guard.isCurrent(id)) return;
///   emit(state.copyWith(status: ViewStatus.success, data: result));
/// }
/// ```
class RequestIdGuard {
  /// Current id. Read for tests or for exposing as a cubit getter; set in tests
  /// to simulate a stale request. Prefer [next] + [isCurrent] in new code.
  int currentId = 0;

  /// Returns the next request id and increments the internal counter.
  /// Use this id in completion callbacks and pass it to [isCurrent].
  int next() => ++currentId;

  /// Call after [next] to invalidate the current id (e.g. on clear/cancel)
  /// so any in-flight completion is ignored.
  void invalidate() {
    currentId++;
  }

  /// Returns true if [id] is still the latest request (no [next] or [invalidate] since).
  bool isCurrent(final int id) => id == currentId;
}
