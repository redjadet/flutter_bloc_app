import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_cycle_summary.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Runs a single sync cycle and returns a summary for diagnostics.
Future<SyncCycleSummary> runSyncCycle({
  required final SyncableRepositoryRegistry registry,
  required final PendingSyncRepository pendingRepository,
  required final void Function(SyncStatus status) emitStatus,
  required final void Function(String event, Map<String, Object?> payload)
  telemetry,
}) async {
  // Create a snapshot copy to avoid concurrent modification during iteration
  // even if the registry is modified concurrently
  final List<SyncableRepository> syncables = List<SyncableRepository>.from(
    registry.repositories,
  );
  final Stopwatch stopwatch = Stopwatch()..start();
  int pullCount = 0;
  int pullFailures = 0;
  if (syncables.isNotEmpty) {
    for (final SyncableRepository repo in syncables) {
      try {
        pullCount++;
        await repo.pullRemote();
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'BackgroundSyncCoordinator.pullRemote failed for ${repo.entityType}',
          error,
          stackTrace,
        );
        pullFailures++;
        emitStatus(SyncStatus.degraded);
      }
    }
  }

  final List<SyncOperation> pending = await pendingRepository
      .getPendingOperations(
        now: DateTime.now().toUtc(),
      );
  final Map<String, int> pendingByEntity = <String, int>{};
  for (final SyncOperation operation in pending) {
    pendingByEntity.update(
      operation.entityType,
      (final count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  if (pending.isEmpty) {
    stopwatch.stop();
    final SyncCycleSummary summary = SyncCycleSummary(
      recordedAt: DateTime.now().toUtc(),
      durationMs: stopwatch.elapsedMilliseconds,
      pullRemoteCount: pullCount,
      pullRemoteFailures: pullFailures,
      pendingAtStart: 0,
      operationsProcessed: 0,
      operationsFailed: 0,
      pendingByEntity: pendingByEntity,
    );
    telemetry(
      'sync_cycle_completed',
      <String, Object?>{
        'durationMs': summary.durationMs,
        'pullRemoteCount': pullCount,
        'pullRemoteFailures': pullFailures,
        'pendingAtStart': summary.pendingAtStart,
        'operationsProcessed': summary.operationsProcessed,
        'operationsFailed': summary.operationsFailed,
        'pendingByEntity': pendingByEntity,
        'prunedCount': summary.prunedCount,
        'retryAttemptsByEntity': summary.retryAttemptsByEntity,
        'lastErrorByEntity': summary.lastErrorByEntity,
        'retrySuccessRate': summary.retrySuccessRate,
      },
    );
    emitStatus(SyncStatus.idle);
    return summary;
  }

  emitStatus(SyncStatus.syncing);
  int processed = 0;
  int failed = 0;
  int successfulAfterRetry = 0;
  final Map<String, List<int>> retryCountsByEntity = <String, List<int>>{};
  final Map<String, String> lastErrorByEntity = <String, String>{};

  for (final SyncOperation operation in pending) {
    final SyncableRepository? repository = registry.resolve(
      operation.entityType,
    );
    if (repository == null) {
      AppLogger.warning(
        'No SyncableRepository registered for ${operation.entityType}, '
        'discarding operation ${operation.id}',
      );
      await pendingRepository.markCompleted(operation.id);
      continue;
    }
    AppLogger.debug(
      'BackgroundSyncCoordinator processing ${operation.entityType} '
      '(id=${operation.id}, retry=${operation.retryCount})',
    );

    // Track retry count for this entity
    retryCountsByEntity.putIfAbsent(operation.entityType, () => <int>[]);
    retryCountsByEntity[operation.entityType]!.add(operation.retryCount);

    try {
      processed++;
      await repository.processOperation(operation);
      await pendingRepository.markCompleted(operation.id);

      // If this operation had retries and succeeded, count it
      if (operation.retryCount > 0) {
        successfulAfterRetry++;
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'BackgroundSyncCoordinator.processOperation failed for '
        '${operation.entityType}',
        error,
        stackTrace,
      );
      failed++;
      lastErrorByEntity[operation.entityType] = error.toString();

      final int backoffMinutes = pow(
        2,
        operation.retryCount.clamp(0, 5),
      ).toInt();
      await pendingRepository.markFailed(
        operationId: operation.id,
        nextRetryAt: DateTime.now().toUtc().add(
          Duration(minutes: backoffMinutes),
        ),
        retryCount: operation.retryCount + 1,
      );
      emitStatus(SyncStatus.degraded);
    }
  }

  // Calculate average retry attempts by entity
  final Map<String, double> retryAttemptsByEntity = <String, double>{};
  for (final MapEntry<String, List<int>> entry in retryCountsByEntity.entries) {
    final List<int> counts = entry.value;
    if (counts.isNotEmpty) {
      final double average =
          counts.reduce((final a, final b) => a + b) / counts.length;
      retryAttemptsByEntity[entry.key] = average;
    }
  }

  // Calculate retry success rate
  final int totalOperationsWithRetries = retryCountsByEntity.values
      .expand((final list) => list)
      .where((final count) => count > 0)
      .length;
  final double retrySuccessRate = totalOperationsWithRetries > 0
      ? successfulAfterRetry / totalOperationsWithRetries
      : 0.0;

  stopwatch.stop();
  final SyncCycleSummary summary = SyncCycleSummary(
    recordedAt: DateTime.now().toUtc(),
    durationMs: stopwatch.elapsedMilliseconds,
    pullRemoteCount: pullCount,
    pullRemoteFailures: pullFailures,
    pendingAtStart: pending.length,
    operationsProcessed: processed,
    operationsFailed: failed,
    pendingByEntity: pendingByEntity,
    retryAttemptsByEntity: retryAttemptsByEntity,
    lastErrorByEntity: lastErrorByEntity,
    retrySuccessRate: retrySuccessRate,
  );
  telemetry(
    'sync_cycle_completed',
    <String, Object?>{
      'durationMs': summary.durationMs,
      'pullRemoteCount': pullCount,
      'pullRemoteFailures': pullFailures,
      'pendingAtStart': summary.pendingAtStart,
      'operationsProcessed': summary.operationsProcessed,
      'operationsFailed': summary.operationsFailed,
      'pendingByEntity': pendingByEntity,
      'prunedCount': summary.prunedCount,
      'retryAttemptsByEntity': retryAttemptsByEntity,
      'lastErrorByEntity': lastErrorByEntity,
      'retrySuccessRate': retrySuccessRate,
    },
  );
  return summary;
}
