import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';

/// Pending-sync inspector APIs for counter, separate from its CRUD contract.
abstract class CounterSyncDiagnosticsPort {
  /// Count of pending sync operations for this feature's entity type.
  Future<int> pendingSyncOperationCount({DateTime? now});

  /// Pending operations for sync inspector UI.
  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({DateTime? now});
}

/// No-op pending-sync reads when the active repository has no offline queue.
mixin CounterSyncDiagnosticsNoPendingSync
    implements CounterSyncDiagnosticsPort {
  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) =>
      Future<int>.value(0);

  @override
  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({
    DateTime? now,
  }) => Future<List<CounterSyncQueueEntry>>.value(
    const <CounterSyncQueueEntry>[],
  );
}

/// Compatibility alias for existing test fakes (`with CounterRepositoryNoPendingSync`).
@Deprecated('Use CounterSyncDiagnosticsNoPendingSync')
mixin CounterRepositoryNoPendingSync implements CounterSyncDiagnosticsPort {
  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) =>
      Future<int>.value(0);

  @override
  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({
    DateTime? now,
  }) => Future<List<CounterSyncQueueEntry>>.value(
    const <CounterSyncQueueEntry>[],
  );
}

/// Standalone no-op port for tests / non-offline DI bindings.
final class NoPendingCounterSyncDiagnostics
    with CounterSyncDiagnosticsNoPendingSync {
  const NoPendingCounterSyncDiagnostics();
}
