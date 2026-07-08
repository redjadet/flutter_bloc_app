import 'package:storage/storage.dart';

import 'background_sync_runner.dart';
import 'sync_cycle_summary.dart';
import 'sync_status.dart';

/// Runs a single sync cycle for the background sync coordinator.
///
/// Encapsulates the call to runSyncCycle so the coordinator depends on this
/// abstraction and tests can substitute a fake runner.
class SyncJobRunner {
  SyncJobRunner({required this._registry, required this._pendingRepository});

  final SyncableRepositoryRegistry _registry;
  final PendingSyncRepository _pendingRepository;

  /// Runs one sync cycle and returns the summary.
  Future<SyncCycleSummary> run({
    required final void Function(SyncStatus status) emitStatus,
    required final void Function(String event, Map<String, Object?> payload)
    telemetry,
    final String? supabaseUserIdForUserScopedSync,
  }) => runSyncCycle(
    registry: _registry,
    pendingRepository: _pendingRepository,
    emitStatus: emitStatus,
    telemetry: telemetry,
    supabaseUserIdForUserScopedSync: supabaseUserIdForUserScopedSync,
  );
}
