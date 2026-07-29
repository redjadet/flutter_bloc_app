import 'dart:async';
import 'dart:math';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:storage/storage.dart';

import 'sync_auth_pin_scope.dart';

import 'sync_cycle_summary.dart';
import 'sync_status.dart';

part 'background_sync_runner_helpers.dart';
part 'background_sync_runner_helpers_summary.part.dart';

/// Runs a single sync cycle and returns a summary for diagnostics.
///
/// When [supabaseUserIdForUserScopedSync] is set, only pending operations
/// for that user (e.g. iot_demo with matching payload) are processed.
///
/// When [getSharedSyncAuthUserId] is set, the cycle aborts before pushing or
/// pulling shared Firebase offline data if the provider auth uid changes
/// mid-cycle (e.g. A→B account switch before session cleanup quiesces).
Future<SyncCycleSummary> runSyncCycle({
  required final SyncableRepositoryRegistry registry,
  required final PendingSyncRepository pendingRepository,
  required final void Function(SyncStatus status) emitStatus,
  required final void Function(String event, Map<String, Object?> payload)
  telemetry,
  final String? supabaseUserIdForUserScopedSync,
  final String? Function()? getSharedSyncAuthUserId,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final _PullRemoteResult initialPullResult = _PullRemoteResult();
  final String? sharedAuthUserIdAtCycleStart = getSharedSyncAuthUserId?.call();

  final List<SyncOperation> pending = await pendingRepository
      .getPendingOperations(
        now: DateTime.now().toUtc(),
        supabaseUserIdFilter: supabaseUserIdForUserScopedSync,
      );
  final Map<String, int> pendingByEntity = _pendingByEntity(pending);
  if (pending.isEmpty) {
    if (_isSharedSyncAuthStale(
      getSharedSyncAuthUserId: getSharedSyncAuthUserId,
      authUserIdAtCycleStart: sharedAuthUserIdAtCycleStart,
    )) {
      return _abortSyncCycleForAuthChange(
        stopwatch: stopwatch,
        pendingAtStart: 0,
        pendingByEntity: pendingByEntity,
        emitStatus: emitStatus,
        telemetry: telemetry,
      );
    }
    await _pullAllRemote(
      syncables: List<SyncableRepository>.from(registry.repositories),
      emitStatus: emitStatus,
      result: initialPullResult,
      getSharedSyncAuthUserId: getSharedSyncAuthUserId,
      authUserIdAtCycleStart: sharedAuthUserIdAtCycleStart,
    );
    stopwatch.stop();
    final SyncCycleSummary summary = _buildSummary(
      recordedAt: DateTime.now().toUtc(),
      durationMs: stopwatch.elapsedMilliseconds,
      pullRemoteCount: initialPullResult.count,
      pullRemoteFailures: initialPullResult.failures,
      pendingAtStart: 0,
      operationsProcessed: 0,
      operationsFailed: 0,
      pendingByEntity: pendingByEntity,
    );
    telemetry('sync_cycle_completed', _telemetryPayload(summary));
    emitStatus(SyncStatus.idle);
    return summary;
  }

  // Create a snapshot copy to avoid concurrent modification during iteration
  // even if the registry is modified concurrently.
  //
  // Pull happens after processing pending operations so we don't overwrite
  // optimistic local state with stale remote data (e.g. a toggle that hasn't
  // been pushed yet).
  final List<SyncableRepository> syncables = List<SyncableRepository>.from(
    registry.repositories,
  );

  emitStatus(SyncStatus.syncing);
  if (_isSharedSyncAuthStale(
    getSharedSyncAuthUserId: getSharedSyncAuthUserId,
    authUserIdAtCycleStart: sharedAuthUserIdAtCycleStart,
  )) {
    return _abortSyncCycleForAuthChange(
      stopwatch: stopwatch,
      pendingAtStart: pending.length,
      pendingByEntity: pendingByEntity,
      emitStatus: emitStatus,
      telemetry: telemetry,
    );
  }
  final _PendingProcessingResult processingResult =
      await _processPendingOperations(
        pending: pending,
        registry: registry,
        pendingRepository: pendingRepository,
        emitStatus: emitStatus,
        getSharedSyncAuthUserId: getSharedSyncAuthUserId,
        authUserIdAtCycleStart: sharedAuthUserIdAtCycleStart,
      );

  final _PullRemoteResult finalPullResult = _PullRemoteResult();
  await _pullAllRemote(
    syncables: syncables,
    emitStatus: emitStatus,
    result: finalPullResult,
    getSharedSyncAuthUserId: getSharedSyncAuthUserId,
    authUserIdAtCycleStart: sharedAuthUserIdAtCycleStart,
  );

  stopwatch.stop();
  final SyncCycleSummary summary = _buildSummary(
    recordedAt: DateTime.now().toUtc(),
    durationMs: stopwatch.elapsedMilliseconds,
    pullRemoteCount: finalPullResult.count,
    pullRemoteFailures: finalPullResult.failures,
    pendingAtStart: pending.length,
    operationsProcessed: processingResult.processed,
    operationsFailed: processingResult.failed,
    pendingByEntity: pendingByEntity,
    retryAttemptsByEntity: processingResult.retryAttemptsByEntity,
    lastErrorByEntity: processingResult.lastErrorByEntity,
    retrySuccessRate: processingResult.retrySuccessRate,
  );
  telemetry('sync_cycle_completed', _telemetryPayload(summary));
  return summary;
}
