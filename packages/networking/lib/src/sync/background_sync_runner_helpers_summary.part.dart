part of 'background_sync_runner.dart';

SyncCycleSummary _buildSummary({
  required DateTime recordedAt,
  required int durationMs,
  required int pullRemoteCount,
  required int pullRemoteFailures,
  required int pendingAtStart,
  required int operationsProcessed,
  required int operationsFailed,
  required Map<String, int> pendingByEntity,
  Map<String, double> retryAttemptsByEntity = const <String, double>{},
  Map<String, String> lastErrorByEntity = const <String, String>{},
  double retrySuccessRate = 0,
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

Map<String, Object?> _telemetryPayload(SyncCycleSummary summary) {
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

  void recordRetry(SyncOperation operation) {
    _retryCountsByEntity
        .putIfAbsent(operation.entityType, () => <int>[])
        .add(operation.retryCount);
  }

  void recordSuccess(SyncOperation operation) {
    if (operation.retryCount > 0) {
      successfulAfterRetry++;
    }
  }

  void recordFailure(String entityType, Object error) {
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
      averages[entry.key] = counts.reduce((a, b) => a + b) / counts.length;
    }
    return averages;
  }

  double get retrySuccessRate {
    final int totalOperationsWithRetries = _retryCountsByEntity.values
        .expand((list) => list)
        .where((count) => count > 0)
        .length;
    if (totalOperationsWithRetries == 0) {
      return 0;
    }
    return successfulAfterRetry / totalOperationsWithRetries;
  }
}
