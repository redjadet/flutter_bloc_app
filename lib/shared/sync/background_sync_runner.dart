import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Immutable summary of a sync cycle for diagnostics/telemetry.
class SyncCycleSummary extends Equatable {
  const SyncCycleSummary({
    required this.recordedAt,
    required this.durationMs,
    required this.pullRemoteCount,
    required this.pullRemoteFailures,
    required this.pendingAtStart,
    required this.operationsProcessed,
    required this.operationsFailed,
    required this.pendingByEntity,
    this.prunedCount = 0,
  });

  final DateTime recordedAt;
  final int durationMs;
  final int pullRemoteCount;
  final int pullRemoteFailures;
  final int pendingAtStart;
  final int operationsProcessed;
  final int operationsFailed;
  final Map<String, int> pendingByEntity;
  final int prunedCount;

  SyncCycleSummary copyWith({
    DateTime? recordedAt,
    int? durationMs,
    int? pullRemoteCount,
    int? pullRemoteFailures,
    int? pendingAtStart,
    int? operationsProcessed,
    int? operationsFailed,
    Map<String, int>? pendingByEntity,
    int? prunedCount,
  }) => SyncCycleSummary(
    recordedAt: recordedAt ?? this.recordedAt,
    durationMs: durationMs ?? this.durationMs,
    pullRemoteCount: pullRemoteCount ?? this.pullRemoteCount,
    pullRemoteFailures: pullRemoteFailures ?? this.pullRemoteFailures,
    pendingAtStart: pendingAtStart ?? this.pendingAtStart,
    operationsProcessed: operationsProcessed ?? this.operationsProcessed,
    operationsFailed: operationsFailed ?? this.operationsFailed,
    pendingByEntity: pendingByEntity ?? this.pendingByEntity,
    prunedCount: prunedCount ?? this.prunedCount,
  );

  @override
  List<Object?> get props => <Object?>[
    recordedAt,
    durationMs,
    pullRemoteCount,
    pullRemoteFailures,
    pendingAtStart,
    operationsProcessed,
    operationsFailed,
    pendingByEntity,
    prunedCount,
  ];
}

/// Runs a single sync cycle and returns a summary for diagnostics.
Future<SyncCycleSummary> runSyncCycle({
  required SyncableRepositoryRegistry registry,
  required PendingSyncRepository pendingRepository,
  required void Function(SyncStatus status) emitStatus,
  required void Function(String event, Map<String, Object?> payload) telemetry,
}) async {
  final List<SyncableRepository> syncables = registry.repositories;
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

  final List<SyncOperation> pending = await pendingRepository.getPendingOperations(
    now: DateTime.now().toUtc(),
  );
  final Map<String, int> pendingByEntity = <String, int>{};
  for (final SyncOperation operation in pending) {
    pendingByEntity.update(
      operation.entityType,
      (final int count) => count + 1,
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
      },
    );
    emitStatus(SyncStatus.idle);
    return summary;
  }

  emitStatus(SyncStatus.syncing);
  int processed = 0;
  int failed = 0;
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
    try {
      processed++;
      await repository.processOperation(operation);
      await pendingRepository.markCompleted(operation.id);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'BackgroundSyncCoordinator.processOperation failed for '
        '${operation.entityType}',
        error,
        stackTrace,
      );
      failed++;
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
    },
  );
  return summary;
}
