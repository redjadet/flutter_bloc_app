import 'package:flutter_bloc_app/shared/sync/sync_cycle_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncCycleSummary', () {
    test('creates summary with required fields', () {
      final summary = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1),
        durationMs: 1000,
        pullRemoteCount: 5,
        pullRemoteFailures: 1,
        pendingAtStart: 10,
        operationsProcessed: 8,
        operationsFailed: 2,
        pendingByEntity: {'todo': 5, 'counter': 3},
      );

      expect(summary.recordedAt, DateTime.utc(2024, 1, 1));
      expect(summary.durationMs, 1000);
      expect(summary.pullRemoteCount, 5);
      expect(summary.pullRemoteFailures, 1);
      expect(summary.pendingAtStart, 10);
      expect(summary.operationsProcessed, 8);
      expect(summary.operationsFailed, 2);
      expect(summary.pendingByEntity, {'todo': 5, 'counter': 3});
    });

    test('uses default values for optional fields', () {
      final summary = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1),
        durationMs: 1000,
        pullRemoteCount: 5,
        pullRemoteFailures: 1,
        pendingAtStart: 10,
        operationsProcessed: 8,
        operationsFailed: 2,
        pendingByEntity: {},
      );

      expect(summary.prunedCount, 0);
      expect(summary.retryAttemptsByEntity, isEmpty);
      expect(summary.lastErrorByEntity, isEmpty);
      expect(summary.retrySuccessRate, 0.0);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1),
        durationMs: 1000,
        pullRemoteCount: 5,
        pullRemoteFailures: 1,
        pendingAtStart: 10,
        operationsProcessed: 8,
        operationsFailed: 2,
        pendingByEntity: {'todo': 5},
      );

      final updated = original.copyWith(
        durationMs: 2000,
        operationsProcessed: 10,
      );

      expect(updated.durationMs, 2000);
      expect(updated.operationsProcessed, 10);
      expect(updated.recordedAt, original.recordedAt);
      expect(updated, isNot(same(original)));
    });

    test('copyWith preserves all fields when no changes', () {
      final original = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1),
        durationMs: 1000,
        pullRemoteCount: 5,
        pullRemoteFailures: 1,
        pendingAtStart: 10,
        operationsProcessed: 8,
        operationsFailed: 2,
        pendingByEntity: {'todo': 5},
        prunedCount: 2,
        retryAttemptsByEntity: {'todo': 1.5},
        lastErrorByEntity: {'todo': 'Error message'},
        retrySuccessRate: 0.8,
      );

      final copied = original.copyWith();

      expect(copied.recordedAt, original.recordedAt);
      expect(copied.durationMs, original.durationMs);
      expect(copied.prunedCount, original.prunedCount);
      expect(copied.retryAttemptsByEntity, original.retryAttemptsByEntity);
      expect(copied.lastErrorByEntity, original.lastErrorByEntity);
      expect(copied.retrySuccessRate, original.retrySuccessRate);
    });

    test('equality works correctly', () {
      final summary1 = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1),
        durationMs: 1000,
        pullRemoteCount: 5,
        pullRemoteFailures: 1,
        pendingAtStart: 10,
        operationsProcessed: 8,
        operationsFailed: 2,
        pendingByEntity: {'todo': 5},
      );

      final summary2 = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1),
        durationMs: 1000,
        pullRemoteCount: 5,
        pullRemoteFailures: 1,
        pendingAtStart: 10,
        operationsProcessed: 8,
        operationsFailed: 2,
        pendingByEntity: {'todo': 5},
      );

      expect(summary1, equals(summary2));
      expect(summary1.hashCode, equals(summary2.hashCode));
    });
  });
}
