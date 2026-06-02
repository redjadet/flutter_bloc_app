part of 'background_sync_runner.dart';

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
