import 'package:flutter_bloc_app/shared/sync/background_sync_runner.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_cycle_summary.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

/// Runs a single sync cycle for the background sync coordinator.
///
/// Encapsulates the call to runSyncCycle so the coordinator depends on this
/// abstraction and tests can substitute a fake runner.
class SyncJobRunner {
  SyncJobRunner({
    required final SyncableRepositoryRegistry registry,
    required final PendingSyncRepository pendingRepository,
  }) : _registry = registry,
       _pendingRepository = pendingRepository;

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
