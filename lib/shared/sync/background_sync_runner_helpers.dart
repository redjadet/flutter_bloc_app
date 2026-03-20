part of 'background_sync_runner.dart';

Map<String, int> _pendingByEntity(final List<SyncOperation> pending) {
  final Map<String, int> pendingByEntity = <String, int>{};
  for (final SyncOperation operation in pending) {
    pendingByEntity.update(
      operation.entityType,
      (final count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  return pendingByEntity;
}

Future<_PullRemoteResult> _pullAllRemote({
  required final List<SyncableRepository> syncables,
  required final void Function(SyncStatus status) emitStatus,
  required final _PullRemoteResult result,
}) async {
  for (final SyncableRepository repo in syncables) {
    try {
      result.count++;
      await repo.pullRemote();
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'BackgroundSyncCoordinator.pullRemote failed for ${repo.entityType}',
        error,
        stackTrace,
      );
      result.failures++;
      emitStatus(SyncStatus.degraded);
    }
  }
  return result;
}

Future<_PendingProcessingResult> _processPendingOperations({
  required final List<SyncOperation> pending,
  required final SyncableRepositoryRegistry registry,
  required final PendingSyncRepository pendingRepository,
  required final void Function(SyncStatus status) emitStatus,
}) async {
  final _PendingProcessingResult result = _PendingProcessingResult();
  final _CoalescedPendingOperations coalescedPending =
      _coalescePendingOperations(
        pending,
      );

  for (final SyncOperation operation in coalescedPending.operations) {
    await _processOperation(
      operation: operation,
      registry: registry,
      pendingRepository: pendingRepository,
      emitStatus: emitStatus,
      result: result,
    );
  }

  for (final String id in coalescedPending.operationIdsToMarkCompleted) {
    await pendingRepository.markCompleted(id);
  }

  return result;
}

_CoalescedPendingOperations _coalescePendingOperations(
  final List<SyncOperation> pending,
) {
  const String counterEntity = 'counter';
  final List<SyncOperation> operations = <SyncOperation>[];
  final List<String> operationIdsToMarkCompleted = <String>[];
  final List<SyncOperation> counterOps = pending
      .where((final op) => op.entityType == counterEntity)
      .toList();

  if (counterOps.length > 1) {
    final SyncOperation latestCounterOp = counterOps.reduce((final a, final b) {
      final int countA = _counterCountFromPayload(a.payload);
      final int countB = _counterCountFromPayload(b.payload);
      return countB > countA ? b : a;
    });
    operations.add(latestCounterOp);
    for (final SyncOperation op in counterOps) {
      if (op.id != latestCounterOp.id) {
        operationIdsToMarkCompleted.add(op.id);
      }
    }
  } else if (counterOps.length == 1) {
    operations.add(counterOps.single);
  }

  for (final SyncOperation operation in pending) {
    if (operation.entityType == counterEntity) {
      continue;
    }
    operations.add(operation);
  }

  return _CoalescedPendingOperations(
    operations: operations,
    operationIdsToMarkCompleted: operationIdsToMarkCompleted,
  );
}

Future<void> _processOperation({
  required final SyncOperation operation,
  required final SyncableRepositoryRegistry registry,
  required final PendingSyncRepository pendingRepository,
  required final void Function(SyncStatus status) emitStatus,
  required final _PendingProcessingResult result,
}) async {
  final SyncableRepository? repository = registry.resolve(operation.entityType);
  if (repository == null) {
    AppLogger.warning(
      'No SyncableRepository registered for ${operation.entityType}, '
      'discarding operation ${operation.id}',
    );
    await pendingRepository.markCompleted(operation.id);
    return;
  }

  AppLogger.debug(
    'BackgroundSyncCoordinator processing ${operation.entityType} '
    '(id=${operation.id}, retry=${operation.retryCount})',
  );

  result.recordRetry(operation);

  try {
    result.processed++;
    await repository.processOperation(operation);
    await pendingRepository.markCompleted(operation.id);
    result.recordSuccess(operation);
  } on Exception catch (error, stackTrace) {
    AppLogger.error(
      'BackgroundSyncCoordinator.processOperation failed for '
      '${operation.entityType}',
      error,
      stackTrace,
    );
    result.recordFailure(operation.entityType, error);
    await pendingRepository.markFailed(
      operationId: operation.id,
      nextRetryAt: _nextRetryAt(operation.retryCount),
      retryCount: operation.retryCount + 1,
    );
    emitStatus(SyncStatus.degraded);
  }
}

DateTime _nextRetryAt(final int retryCount) {
  final int backoffMinutes = pow(2, retryCount.clamp(0, 5)).toInt();
  return DateTime.now().toUtc().add(Duration(minutes: backoffMinutes));
}

SyncCycleSummary _buildSummary({
  required final DateTime recordedAt,
  required final int durationMs,
  required final int pullRemoteCount,
  required final int pullRemoteFailures,
  required final int pendingAtStart,
  required final int operationsProcessed,
  required final int operationsFailed,
  required final Map<String, int> pendingByEntity,
  final Map<String, double> retryAttemptsByEntity = const <String, double>{},
  final Map<String, String> lastErrorByEntity = const <String, String>{},
  final double retrySuccessRate = 0,
}) {
  return SyncCycleSummary(
    recordedAt: recordedAt,
    durationMs: durationMs,
    pullRemoteCount: pullRemoteCount,
    pullRemoteFailures: pullRemoteFailures,
    pendingAtStart: pendingAtStart,
    operationsProcessed: operationsProcessed,
    operationsFailed: operationsFailed,
    pendingByEntity: pendingByEntity,
    retryAttemptsByEntity: retryAttemptsByEntity,
    lastErrorByEntity: lastErrorByEntity,
    retrySuccessRate: retrySuccessRate,
  );
}

Map<String, Object?> _telemetryPayload(final SyncCycleSummary summary) {
  return <String, Object?>{
    'durationMs': summary.durationMs,
    'pullRemoteCount': summary.pullRemoteCount,
    'pullRemoteFailures': summary.pullRemoteFailures,
    'pendingAtStart': summary.pendingAtStart,
    'operationsProcessed': summary.operationsProcessed,
    'operationsFailed': summary.operationsFailed,
    'pendingByEntity': summary.pendingByEntity,
    'prunedCount': summary.prunedCount,
    'retryAttemptsByEntity': summary.retryAttemptsByEntity,
    'lastErrorByEntity': summary.lastErrorByEntity,
    'retrySuccessRate': summary.retrySuccessRate,
  };
}

int _counterCountFromPayload(final Map<String, dynamic> payload) {
  final dynamic count = payload['count'];
  if (count is int) return count;
  if (count is num) return count.toInt();
  return 0;
}

final class _PullRemoteResult {
  int count = 0;
  int failures = 0;
}

final class _CoalescedPendingOperations {
  _CoalescedPendingOperations({
    required this.operations,
    required this.operationIdsToMarkCompleted,
  });

  final List<SyncOperation> operations;
  final List<String> operationIdsToMarkCompleted;
}

final class _PendingProcessingResult {
  int processed = 0;
  int failed = 0;
  int successfulAfterRetry = 0;
  final Map<String, List<int>> _retryCountsByEntity = <String, List<int>>{};
  final Map<String, String> lastErrorByEntity = <String, String>{};

  void recordRetry(final SyncOperation operation) {
    _retryCountsByEntity
        .putIfAbsent(operation.entityType, () => <int>[])
        .add(operation.retryCount);
  }

  void recordSuccess(final SyncOperation operation) {
    if (operation.retryCount > 0) {
      successfulAfterRetry++;
    }
  }

  void recordFailure(final String entityType, final Object error) {
    failed++;
    lastErrorByEntity[entityType] = error.toString();
  }

  Map<String, double> get retryAttemptsByEntity {
    final Map<String, double> averages = <String, double>{};
    for (final MapEntry<String, List<int>> entry
        in _retryCountsByEntity.entries) {
      final List<int> counts = entry.value;
      if (counts.isEmpty) {
        continue;
      }
      averages[entry.key] =
          counts.reduce((final a, final b) => a + b) / counts.length;
    }
    return averages;
  }

  double get retrySuccessRate {
    final int totalOperationsWithRetries = _retryCountsByEntity.values
        .expand((final list) => list)
        .where((final count) => count > 0)
        .length;
    if (totalOperationsWithRetries == 0) {
      return 0;
    }
    return successfulAfterRetry / totalOperationsWithRetries;
  }
}
