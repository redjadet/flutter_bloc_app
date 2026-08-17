import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockSyncableRepository extends Mock implements SyncableRepository {}

class _FakeSyncableRepository extends Fake implements SyncableRepository {
  _FakeSyncableRepository(this.onProcess, {this.onPullRemote});

  final void Function(SyncOperation operation) onProcess;
  final Future<void> Function()? onPullRemote;

  @override
  String get entityType => 'test';

  @override
  Future<void> pullRemote() async {
    if (onPullRemote != null) {
      await onPullRemote!();
    }
  }

  @override
  Future<void> processOperation(SyncOperation operation) async {
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
          supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[]);

      final SyncCycleSummary summary = await runSyncCycle(
        registry: registry,
        pendingRepository: pending,
        emitStatus: emittedStatuses.add,
        telemetry: (String event, Map<String, Object?> payload) {
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
          supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[op]);
      when(() => pending.markCompleted(op.id)).thenAnswer((_) async {});

      final SyncCycleSummary summary = await runSyncCycle(
        registry: registry,
        pendingRepository: pending,
        emitStatus: emittedStatuses.add,
        telemetry: (String event, Map<String, Object?> payload) {
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
          supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
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
        telemetry: (String event, Map<String, Object?> payload) {
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

    test(
      'processes operations before pullRemote (prevents toggle flicker)',
      () async {
        final SyncOperation op = SyncOperation(
          id: 'op-3',
          entityType: 'test',
          payload: const <String, dynamic>{'k': 'v'},
          createdAt: DateTime.utc(2024, 1, 1),
          idempotencyKey: 'key-3',
        );
        final _MockSyncableRepository repo = _MockSyncableRepository();
        when(() => repo.entityType).thenReturn('test');
        when(() => repo.processOperation(any())).thenAnswer((_) async {});
        when(() => repo.pullRemote()).thenAnswer((_) async {});
        registry.register(repo);
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer((_) async => <SyncOperation>[op]);
        when(() => pending.markCompleted(op.id)).thenAnswer((_) async {});

        await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (_, _) {},
        );

        verifyInOrder(<void Function()>[
          () => repo.processOperation(any()),
          () => repo.pullRemote(),
        ]);
      },
    );

    test(
      'coalesces counter operations to latest createdAt and prunes older ones',
      () async {
        final SyncOperation olderCounterOp = SyncOperation(
          id: 'counter-1',
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 2},
          createdAt: DateTime.utc(2024, 1, 1, 10),
          idempotencyKey: 'counter-key-1',
        );
        final SyncOperation newerCounterOp = SyncOperation(
          id: 'counter-2',
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 5},
          createdAt: DateTime.utc(2024, 1, 1, 11),
          idempotencyKey: 'counter-key-2',
        );
        final _MockSyncableRepository repo = _MockSyncableRepository();
        when(() => repo.entityType).thenReturn('counter');
        when(() => repo.processOperation(any())).thenAnswer((_) async {});
        when(() => repo.pullRemote()).thenAnswer((_) async {});
        registry.register(repo);
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer(
          (_) async => <SyncOperation>[olderCounterOp, newerCounterOp],
        );
        when(() => pending.markCompleted(any())).thenAnswer((_) async {});

        await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (_, _) {},
        );

        verify(() => repo.processOperation(newerCounterOp)).called(1);
        verifyNever(() => repo.processOperation(olderCounterOp));
        verify(() => pending.markCompleted(newerCounterOp.id)).called(1);
        verify(() => pending.markCompleted(olderCounterOp.id)).called(1);
      },
    );

    test(
      'coalesces counter operations to latest createdAt when count decreases',
      () async {
        final SyncOperation staleHighCountOp = SyncOperation(
          id: 'counter-1',
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 10},
          createdAt: DateTime.utc(2024, 1, 1, 10),
          idempotencyKey: 'counter-key-1',
        );
        final SyncOperation latestLowerCountOp = SyncOperation(
          id: 'counter-2',
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 7},
          createdAt: DateTime.utc(2024, 1, 1, 11),
          idempotencyKey: 'counter-key-2',
        );
        final _MockSyncableRepository repo = _MockSyncableRepository();
        when(() => repo.entityType).thenReturn('counter');
        when(() => repo.processOperation(any())).thenAnswer((_) async {});
        when(() => repo.pullRemote()).thenAnswer((_) async {});
        registry.register(repo);
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer(
          (_) async => <SyncOperation>[staleHighCountOp, latestLowerCountOp],
        );
        when(() => pending.markCompleted(any())).thenAnswer((_) async {});

        await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (_, _) {},
        );

        verify(() => repo.processOperation(latestLowerCountOp)).called(1);
        verifyNever(() => repo.processOperation(staleHighCountOp));
        verify(() => pending.markCompleted(latestLowerCountOp.id)).called(1);
        verify(() => pending.markCompleted(staleHighCountOp.id)).called(1);
      },
    );

    test(
      'leaves deferred operations pending without markCompleted or markFailed',
      () async {
        final SyncOperation op = SyncOperation(
          id: 'deferred-op',
          entityType: 'test',
          payload: const <String, dynamic>{'k': 'v'},
          createdAt: DateTime.utc(2024, 1, 1),
          idempotencyKey: 'deferred-key',
        );
        final _MockSyncableRepository repo = _MockSyncableRepository();
        when(() => repo.entityType).thenReturn('test');
        when(() => repo.pullRemote()).thenAnswer((_) async {});
        when(() => repo.processOperation(any()))
            .thenThrow(const SyncOperationDeferredException());
        registry.register(repo);
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer((_) async => <SyncOperation>[op]);

        final SyncCycleSummary summary = await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (_, _) {},
        );

        expect(summary.operationsProcessed, 0);
        expect(summary.operationsFailed, 0);
        verifyNever(() => pending.markCompleted(any()));
        verifyNever(
          () => pending.markFailed(
            operationId: any(named: 'operationId'),
            nextRetryAt: any(named: 'nextRetryAt'),
            retryCount: any(named: 'retryCount'),
          ),
        );
      },
    );

    test(
      'coalesces counter operations with equal createdAt to last pending op',
      () async {
        final DateTime sameInstant = DateTime.utc(2024, 1, 1, 12);
        final SyncOperation firstCounterOp = SyncOperation(
          id: 'counter-1',
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 10},
          createdAt: sameInstant,
          idempotencyKey: 'counter-key-1',
        );
        final SyncOperation secondCounterOp = SyncOperation(
          id: 'counter-2',
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 7},
          createdAt: sameInstant,
          idempotencyKey: 'counter-key-2',
        );
        final _MockSyncableRepository repo = _MockSyncableRepository();
        when(() => repo.entityType).thenReturn('counter');
        when(() => repo.processOperation(any())).thenAnswer((_) async {});
        when(() => repo.pullRemote()).thenAnswer((_) async {});
        registry.register(repo);
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer(
          (_) async => <SyncOperation>[firstCounterOp, secondCounterOp],
        );
        when(() => pending.markCompleted(any())).thenAnswer((_) async {});

        await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (_, _) {},
        );

        verify(() => repo.processOperation(secondCounterOp)).called(1);
        verifyNever(() => repo.processOperation(firstCounterOp));
        verify(() => pending.markCompleted(secondCounterOp.id)).called(1);
        verify(() => pending.markCompleted(firstCounterOp.id)).called(1);
      },
    );

    test('discards operations without a registered repository', () async {
      final SyncOperation op = SyncOperation(
        id: 'orphan-op',
        entityType: 'missing',
        payload: const <String, dynamic>{'k': 'v'},
        createdAt: DateTime.utc(2024, 1, 1),
        idempotencyKey: 'missing-key',
      );
      when(
        () => pending.getPendingOperations(
          now: any(named: 'now'),
          limit: any(named: 'limit'),
          supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[op]);
      when(() => pending.markCompleted(op.id)).thenAnswer((_) async {});

      final SyncCycleSummary summary = await runSyncCycle(
        registry: registry,
        pendingRepository: pending,
        emitStatus: emittedStatuses.add,
        telemetry: (String event, Map<String, Object?> payload) {
          telemetryEvent = event;
          telemetryPayload = payload;
        },
      );

      expect(summary.pendingAtStart, 1);
      expect(summary.operationsProcessed, 0);
      expect(summary.operationsFailed, 0);
      verify(() => pending.markCompleted(op.id)).called(1);
      expect(telemetryPayload?['pendingByEntity'], containsPair('missing', 1));
    });

    test(
      'aborts pending push when shared auth uid changes mid-cycle',
      () async {
        final SyncOperation op = SyncOperation(
          id: 'op-auth-switch',
          entityType: 'test',
          payload: <String, dynamic>{'k': 'v'},
          createdAt: DateTime.utc(2024, 1, 1),
          idempotencyKey: 'auth-switch-key',
        );
        var processed = false;
        registry.register(
          _FakeSyncableRepository((SyncOperation operation) {
            processed = true;
          }),
        );
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer((_) async => <SyncOperation>[op]);

        var authLookupCalls = 0;
        final SyncCycleSummary summary = await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (String event, Map<String, Object?> payload) {
            telemetryEvent = event;
            telemetryPayload = payload;
          },
          getSharedSyncAuthUserId: () {
            authLookupCalls += 1;
            return authLookupCalls == 1 ? 'user-a' : 'user-b';
          },
        );

        expect(processed, isFalse);
        expect(summary.pendingAtStart, 1);
        expect(summary.operationsProcessed, 0);
        expect(telemetryEvent, 'sync_cycle_aborted_auth_changed');
        verifyNever(() => pending.markCompleted(any()));
      },
    );

    test(
      'leaves pending op when auth uid changes during processOperation',
      () async {
        final SyncOperation op = SyncOperation(
          id: 'op-auth-mid-push',
          entityType: 'test',
          payload: <String, dynamic>{'k': 'v'},
          createdAt: DateTime.utc(2024, 1, 1),
          idempotencyKey: 'auth-mid-push-key',
        );
        registry.register(
          _FakeSyncableRepository((SyncOperation operation) {
            throw const SyncAuthUserChangedException();
          }),
        );
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer((_) async => <SyncOperation>[op]);

        final SyncCycleSummary summary = await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (String event, Map<String, Object?> payload) {
            telemetryEvent = event;
            telemetryPayload = payload;
          },
          getSharedSyncAuthUserId: () => 'user-a',
        );

        expect(summary.operationsProcessed, 0);
        verifyNever(() => pending.markCompleted(any()));
      },
    );

    test(
      'pins auth uid during pullRemote when shared auth provider is wired',
      () async {
        when(
          () => pending.getPendingOperations(
            now: any(named: 'now'),
            limit: any(named: 'limit'),
            supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
          ),
        ).thenAnswer((_) async => <SyncOperation>[]);

        String? observedPinDuringPull;
        registry.register(
          _FakeSyncableRepository(
            (_) {},
            onPullRemote: () async {
              observedPinDuringPull = SyncAuthPinScope.current;
            },
          ),
        );

        await runSyncCycle(
          registry: registry,
          pendingRepository: pending,
          emitStatus: emittedStatuses.add,
          telemetry: (String event, Map<String, Object?> payload) {
            telemetryEvent = event;
            telemetryPayload = payload;
          },
          getSharedSyncAuthUserId: () => 'user-a',
        );

        expect(observedPinDuringPull, 'user-a');
      },
    );

    test('aborts pullRemote when auth uid changes mid-pull', () async {
      when(
        () => pending.getPendingOperations(
          now: any(named: 'now'),
          limit: any(named: 'limit'),
          supabaseUserIdFilter: any(named: 'supabaseUserIdFilter'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[]);

      var pullRemoteInvoked = false;
      registry.register(
        _FakeSyncableRepository(
          (_) {},
          onPullRemote: () async {
            pullRemoteInvoked = true;
            throw const SyncAuthUserChangedException();
          },
        ),
      );

      final SyncCycleSummary summary = await runSyncCycle(
        registry: registry,
        pendingRepository: pending,
        emitStatus: emittedStatuses.add,
        telemetry: (String event, Map<String, Object?> payload) {
          telemetryEvent = event;
          telemetryPayload = payload;
        },
        getSharedSyncAuthUserId: () => 'user-a',
      );

      expect(pullRemoteInvoked, isTrue);
      expect(summary.pullRemoteFailures, 0);
      expect(summary.pullRemoteCount, 1);
    });
  });
}
