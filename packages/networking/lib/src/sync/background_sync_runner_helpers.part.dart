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
  final String? Function()? getSharedSyncAuthUserId,
  final String? authUserIdAtCycleStart,
}) async {
  for (final SyncableRepository repo in syncables) {
    if (_isSharedSyncAuthStale(
      getSharedSyncAuthUserId: getSharedSyncAuthUserId,
      authUserIdAtCycleStart: authUserIdAtCycleStart,
    )) {
      return result;
    }
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
  final String? Function()? getSharedSyncAuthUserId,
  final String? authUserIdAtCycleStart,
}) async {
  final _PendingProcessingResult result = _PendingProcessingResult();
  final _CoalescedPendingOperations coalescedPending =
      _coalescePendingOperations(pending);

  for (final SyncOperation operation in coalescedPending.operations) {
    if (_isSharedSyncAuthStale(
      getSharedSyncAuthUserId: getSharedSyncAuthUserId,
      authUserIdAtCycleStart: authUserIdAtCycleStart,
    )) {
      break;
    }
    await _processOperation(
      operation: operation,
      registry: registry,
      pendingRepository: pendingRepository,
      emitStatus: emitStatus,
      result: result,
      getSharedSyncAuthUserId: getSharedSyncAuthUserId,
      authUserIdAtCycleStart: authUserIdAtCycleStart,
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
      if (b.createdAt.isAfter(a.createdAt)) {
        return b;
      }
      if (a.createdAt.isAfter(b.createdAt)) {
        return a;
      }
      // Same timestamp: prefer the later enqueued op (pending list is sorted by
      // createdAt, so the right-hand operand is newer when timestamps tie).
      return b;
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
  final String? Function()? getSharedSyncAuthUserId,
  final String? authUserIdAtCycleStart,
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
    await SyncAuthPinScope.runWithPin(
      authUserIdAtCycleStart,
      () => repository.processOperation(operation),
    );
    if (_isSharedSyncAuthStale(
      getSharedSyncAuthUserId: getSharedSyncAuthUserId,
      authUserIdAtCycleStart: authUserIdAtCycleStart,
    )) {
      result.processed--;
      return;
    }
    await pendingRepository.markCompleted(operation.id);
    result.recordSuccess(operation);
  } on SyncAuthUserChangedException {
    result.processed--;
    AppLogger.debug(
      'BackgroundSyncCoordinator aborted ${operation.entityType} '
      '(id=${operation.id}) after auth uid changed mid-push',
    );
  } on SyncOperationDeferredException {
    result.processed--;
    AppLogger.debug(
      'BackgroundSyncCoordinator deferred ${operation.entityType} '
      '(id=${operation.id}) until preconditions are met',
    );
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

bool _isSharedSyncAuthStale({
  required final String? Function()? getSharedSyncAuthUserId,
  required final String? authUserIdAtCycleStart,
}) {
  if (getSharedSyncAuthUserId == null) {
    return false;
  }
  return getSharedSyncAuthUserId() != authUserIdAtCycleStart;
}

SyncCycleSummary _abortSyncCycleForAuthChange({
  required final Stopwatch stopwatch,
  required final int pendingAtStart,
  required final Map<String, int> pendingByEntity,
  required final void Function(SyncStatus status) emitStatus,
  required final void Function(String event, Map<String, Object?> payload)
  telemetry,
}) {
  stopwatch.stop();
  final SyncCycleSummary summary = _buildSummary(
    recordedAt: DateTime.now().toUtc(),
    durationMs: stopwatch.elapsedMilliseconds,
    pullRemoteCount: 0,
    pullRemoteFailures: 0,
    pendingAtStart: pendingAtStart,
    operationsProcessed: 0,
    operationsFailed: 0,
    pendingByEntity: pendingByEntity,
  );
  telemetry('sync_cycle_aborted_auth_changed', _telemetryPayload(summary));
  emitStatus(SyncStatus.idle);
  return summary;
}
