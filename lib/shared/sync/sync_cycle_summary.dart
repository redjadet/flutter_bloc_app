import 'package:equatable/equatable.dart';

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
    this.retryAttemptsByEntity = const <String, double>{},
    this.lastErrorByEntity = const <String, String>{},
    this.retrySuccessRate = 0.0,
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

  /// Map of entity type to average retry count.
  final Map<String, double> retryAttemptsByEntity;

  /// Map of entity type to most recent error message.
  final Map<String, String> lastErrorByEntity;

  /// Percentage of operations that succeeded after retries (0.0 to 1.0).
  final double retrySuccessRate;

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
    Map<String, double>? retryAttemptsByEntity,
    Map<String, String>? lastErrorByEntity,
    double? retrySuccessRate,
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
    retryAttemptsByEntity: retryAttemptsByEntity ?? this.retryAttemptsByEntity,
    lastErrorByEntity: lastErrorByEntity ?? this.lastErrorByEntity,
    retrySuccessRate: retrySuccessRate ?? this.retrySuccessRate,
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
    retryAttemptsByEntity,
    lastErrorByEntity,
    retrySuccessRate,
  ];
}
