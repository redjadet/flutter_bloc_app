import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_cycle_summary.freezed.dart';

/// Immutable summary of a sync cycle for diagnostics/telemetry.
@freezed
abstract class SyncCycleSummary with _$SyncCycleSummary {
  const factory SyncCycleSummary({
    required final DateTime recordedAt,
    required final int durationMs,
    required final int pullRemoteCount,
    required final int pullRemoteFailures,
    required final int pendingAtStart,
    required final int operationsProcessed,
    required final int operationsFailed,
    required final Map<String, int> pendingByEntity,
    @Default(0) final int prunedCount,
    @Default(<String, double>{})
    final Map<String, double> retryAttemptsByEntity,
    @Default(<String, String>{}) final Map<String, String> lastErrorByEntity,
    @Default(0.0) final double retrySuccessRate,
  }) = _SyncCycleSummary;
}
