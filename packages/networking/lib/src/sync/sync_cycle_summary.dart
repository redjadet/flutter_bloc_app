import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_cycle_summary.freezed.dart';

/// Immutable summary of a sync cycle for diagnostics/telemetry.
@freezed
abstract class SyncCycleSummary with _$SyncCycleSummary {
  const factory SyncCycleSummary({
    required DateTime recordedAt,
    required int durationMs,
    required int pullRemoteCount,
    required int pullRemoteFailures,
    required int pendingAtStart,
    required int operationsProcessed,
    required int operationsFailed,
    required Map<String, int> pendingByEntity,
    @Default(0) int prunedCount,
    @Default(<String, double>{}) Map<String, double> retryAttemptsByEntity,
    @Default(<String, String>{}) Map<String, String> lastErrorByEntity,
    @Default(0.0) double retrySuccessRate,
  }) = _SyncCycleSummary;
}
