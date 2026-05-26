/// Thrown when a pending sync operation cannot be applied yet and must stay queued.
///
/// The background sync runner leaves the operation pending (no markCompleted /
/// markFailed) so a later cycle can retry after auth or scope preconditions change.
class SyncOperationDeferredException implements Exception {
  const SyncOperationDeferredException([this.reason]);

  final String? reason;

  @override
  String toString() => reason == null
      ? 'SyncOperationDeferredException'
      : 'SyncOperationDeferredException: $reason';
}
