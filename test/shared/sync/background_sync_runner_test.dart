import 'package:flutter_bloc_app/shared/sync/background_sync_runner.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_cycle_summary.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockSyncableRepository extends Mock implements SyncableRepository {}

class _FakeSyncableRepository extends Fake implements SyncableRepository {
  _FakeSyncableRepository(this.onProcess);

  final void Function(SyncOperation operation) onProcess;

  @override
  String get entityType => 'test';

  @override
  Future<void> pullRemote() async {}

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    onProcess(operation);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SyncOperation(
        id: 'fallback',
        entityType: 'fallback',
        payload: const <String, dynamic>{},
        createdAt: DateTime.utc(2024, 1, 1),
        idempotencyKey: 'fallback',
      ),
    );
  });

  group('runSyncCycle', () {
    late SyncableRepositoryRegistry registry;
    late _MockPendingSyncRepository pending;
    late List<SyncStatus> emittedStatuses;
    late Map<String, Object?>? telemetryPayload;
    late String? telemetryEvent;

    setUp(() {
      registry = SyncableRepositoryRegistry();
      pending = _MockPendingSyncRepository();
      emittedStatuses = <SyncStatus>[];
      telemetryPayload = null;
      telemetryEvent = null;
    });

    test('emits idle summary when no pending operations', () async {
      when(
        () => pending.getPendingOperations(
          now: any(named: 'now'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[]);

      final SyncCycleSummary summary = await runSyncCycle(
        registry: registry,
        pendingRepository: pending,
        emitStatus: emittedStatuses.add,
        telemetry: (final String event, final Map<String, Object?> payload) {
          telemetryEvent = event;
          telemetryPayload = payload;
        },
      );

      expect(summary.pendingAtStart, 0);
      expect(summary.operationsProcessed, 0);
      expect(summary.operationsFailed, 0);
      expect(summary.prunedCount, 0);
      expect(emittedStatuses.contains(SyncStatus.idle), isTrue);
      expect(telemetryEvent, 'sync_cycle_completed');
      expect(telemetryPayload?['prunedCount'], 0);
      expect(
        telemetryPayload?['pendingByEntity'],
        isA<Map<String, int>>().having((m) => m.length, 'length', 0),
      );
    });

    test('processes pending operations and reports telemetry', () async {
      final SyncOperation op = SyncOperation(
        id: 'op-1',
        entityType: 'test',
        payload: <String, dynamic>{'k': 'v'},
        createdAt: DateTime.utc(2024, 1, 1),
        idempotencyKey: 'key-1',
      );
      registry.register(_FakeSyncableRepository((_) {}));
      when(
        () => pending.getPendingOperations(
          now: any(named: 'now'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[op]);
      when(() => pending.markCompleted(op.id)).thenAnswer((_) async {});

      final SyncCycleSummary summary = await runSyncCycle(
        registry: registry,
        pendingRepository: pending,
        emitStatus: emittedStatuses.add,
        telemetry: (final String event, final Map<String, Object?> payload) {
          telemetryEvent = event;
          telemetryPayload = payload;
        },
      );

      expect(summary.pendingAtStart, 1);
      expect(summary.operationsProcessed, 1);
      expect(summary.operationsFailed, 0);
      expect(emittedStatuses.contains(SyncStatus.syncing), isTrue);
      expect(telemetryPayload?['pendingByEntity'], containsPair('test', 1));
      expect(telemetryPayload?['prunedCount'], 0);
      verify(() => pending.markCompleted(op.id)).called(1);
    });

    test('marks failed operations with backoff and emits degraded', () async {
      final SyncOperation op = SyncOperation(
        id: 'op-2',
        entityType: 'test',
        payload: const <String, dynamic>{'k': 'v'},
        createdAt: DateTime.utc(2024, 1, 1),
        idempotencyKey: 'key-2',
        retryCount: 1,
      );
      final _MockSyncableRepository repo = _MockSyncableRepository();
      when(() => repo.entityType).thenReturn('test');
      when(() => repo.pullRemote()).thenAnswer((_) async {});
      when(() => repo.processOperation(any())).thenThrow(Exception('boom'));
      registry.register(repo);
      when(
        () => pending.getPendingOperations(
          now: any(named: 'now'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[op]);
      when(
        () => pending.markFailed(
          operationId: op.id,
          nextRetryAt: any(named: 'nextRetryAt'),
          retryCount: any(named: 'retryCount'),
        ),
      ).thenAnswer((_) async {});

      final SyncCycleSummary summary = await runSyncCycle(
        registry: registry,
        pendingRepository: pending,
        emitStatus: emittedStatuses.add,
        telemetry: (final String event, final Map<String, Object?> payload) {
          telemetryEvent = event;
          telemetryPayload = payload;
        },
      );

      expect(summary.operationsProcessed, 1);
      expect(summary.operationsFailed, 1);
      expect(emittedStatuses.contains(SyncStatus.degraded), isTrue);
      verify(
        () => pending.markFailed(
          operationId: op.id,
          nextRetryAt: any(named: 'nextRetryAt', that: isA<DateTime>()),
          retryCount: op.retryCount + 1,
        ),
      ).called(1);
      expect(
        telemetryPayload?['pendingByEntity'],
        containsPair('test', greaterThanOrEqualTo(1)),
      );
    });
  });
}
