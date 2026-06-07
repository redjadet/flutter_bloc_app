import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';

/// Abstraction over counter persistence.
/// Enables substituting storage without changing business logic (DIP).
abstract class CounterRepository {
  Future<CounterSnapshot> load();
  Future<void> save(final CounterSnapshot snapshot);
  Stream<CounterSnapshot> watch();

  /// Count of pending sync operations for this feature's entity type.
  Future<int> pendingSyncOperationCount({DateTime? now});

  /// Pending operations for sync inspector UI.
  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({DateTime? now});
}

/// No-op pending-sync reads for repositories without an offline queue.
mixin CounterRepositoryNoPendingSync {
  Future<int> pendingSyncOperationCount({DateTime? now}) =>
      Future<int>.value(0);

  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({
    DateTime? now,
  }) => Future<List<CounterSyncQueueEntry>>.value(
    const <CounterSyncQueueEntry>[],
  );
}
