/// Pending-sync inspector APIs for todo, separate from its CRUD contract.
abstract class TodoSyncDiagnosticsPort {
  /// Count of pending sync operations for entity type `todo`.
  Future<int> pendingSyncOperationCount({DateTime? now});
}

/// No-op pending-sync count when the active repository has no offline queue.
mixin TodoSyncDiagnosticsNoPendingSync implements TodoSyncDiagnosticsPort {
  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) =>
      Future<int>.value(0);
}

/// Compatibility alias for existing test fakes (`with TodoRepositoryNoPendingSync`).
@Deprecated('Use TodoSyncDiagnosticsNoPendingSync')
mixin TodoRepositoryNoPendingSync implements TodoSyncDiagnosticsPort {
  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) =>
      Future<int>.value(0);
}

/// Standalone no-op port for tests / non-offline DI bindings.
final class NoPendingTodoSyncDiagnostics with TodoSyncDiagnosticsNoPendingSync {
  const NoPendingTodoSyncDiagnostics();
}
