import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockNetworkStatusService extends Mock implements NetworkStatusService {}

class _ControllableTimerService extends Fake implements TimerService {
  void Function()? _lastOnTick;
  int periodicCalls = 0;

  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) {
    periodicCalls += 1;
    _lastOnTick = onTick;
    return _ControllableTimerDisposable(onTick);
  }

  void tick() {
    _lastOnTick?.call();
  }
}

class _ControllableTimerDisposable implements TimerDisposable {
  _ControllableTimerDisposable(this.onTick);
  final void Function() onTick;
  @override
  void dispose() {}
}

class _MockSyncableRepository extends Mock implements SyncableRepository {}

void main() {
  group('BackgroundSyncCoordinator', () {
    late PendingSyncRepository pendingRepository;
    late NetworkStatusService networkService;
    late TimerService timerService;
    late SyncableRepositoryRegistry registry;
    late StreamController<NetworkStatus> networkController;
    late StreamController<void> enqueueController;

    setUpAll(() {
      registerFallbackValue(
        SyncOperation.create(
          entityType: 'counter',
          payload: const <String, dynamic>{},
          idempotencyKey: 'key',
        ),
      );
      registerFallbackValue(const Duration());
    });

    setUp(() {
      pendingRepository = _MockPendingSyncRepository();
      networkService = _MockNetworkStatusService();
      timerService = _ControllableTimerService();
      registry = SyncableRepositoryRegistry();
      networkController = StreamController<NetworkStatus>.broadcast();
      enqueueController = StreamController<void>.broadcast();
      when(
        () => networkService.statusStream,
      ).thenAnswer((_) => networkController.stream);
      when(
        () => networkService.getCurrentStatus(),
      ).thenAnswer((_) async => NetworkStatus.online);
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async => <SyncOperation>[]);
      when(
        () => pendingRepository.onOperationEnqueued,
      ).thenAnswer((_) => enqueueController.stream);
      when(
        () => pendingRepository.prune(
          maxRetryCount: any(named: 'maxRetryCount'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => 0);
    });

    tearDown(() async {
      await enqueueController.close();
      await networkController.close();
    });

    test('starts and emits syncing when pending operations exist', () async {
      final SyncOperation operation = SyncOperation.create(
        entityType: 'counter',
        payload: const <String, dynamic>{'count': 1},
        idempotencyKey: 'key2',
      );
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async => <SyncOperation>[operation]);
      final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
      when(() => syncableRepo.entityType).thenReturn('counter');
      when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
      when(
        () => syncableRepo.processOperation(operation),
      ).thenAnswer((_) async {});
      registry.register(syncableRepo);
      when(
        () => pendingRepository.markCompleted(operation.id),
      ).thenAnswer((_) async {});

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );
      final List<SyncStatus> emitted = <SyncStatus>[];
      coordinator.statusStream.listen(emitted.add);

      await coordinator.start();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      verify(() => syncableRepo.processOperation(operation)).called(1);
      expect(emitted.contains(SyncStatus.syncing), isTrue);
      await coordinator.stop();
    });

    test('default telemetry filter suppresses empty sync events', () {
      expect(
        BackgroundSyncCoordinator.shouldLogTelemetry(
          'sync_cycle_completed',
          const <String, Object?>{
            'durationMs': 0,
            'pullRemoteCount': 3,
            'pullRemoteFailures': 0,
            'pendingAtStart': 0,
            'operationsProcessed': 0,
            'operationsFailed': 0,
            'pendingByEntity': <String, int>{},
            'prunedCount': 0,
            'retryAttemptsByEntity': <String, double>{},
            'lastErrorByEntity': <String, String>{},
            'retrySuccessRate': 0.0,
          },
        ),
        isFalse,
      );
      expect(
        BackgroundSyncCoordinator.shouldLogTelemetry(
          'sync_cycle_completed',
          const <String, Object?>{
            'durationMs': 10,
            'pullRemoteCount': 1,
            'pullRemoteFailures': 0,
            'pendingAtStart': 1,
            'operationsProcessed': 1,
            'operationsFailed': 0,
            'pendingByEntity': <String, int>{'counter': 1},
            'prunedCount': 0,
            'retryAttemptsByEntity': <String, double>{},
            'lastErrorByEntity': <String, String>{},
            'retrySuccessRate': 0.0,
          },
        ),
        isTrue,
      );
      expect(
        BackgroundSyncCoordinator.shouldLogTelemetry(
          'sync_prune_completed',
          const <String, Object?>{'pruned': 0},
        ),
        isFalse,
      );
    });

    test(
      'start/stop are idempotent and do not double-schedule periodic ticks',
      () async {
        final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
          repository: pendingRepository,
          networkStatusService: networkService,
          timerService: timerService,
          registry: registry,
          syncInterval: const Duration(milliseconds: 10),
        );

        await coordinator.start();
        await coordinator.start();

        expect(
          (timerService as _ControllableTimerService).periodicCalls,
          1,
          reason: 'start() should not register multiple periodic timers.',
        );

        await coordinator.stop();
        await coordinator.stop();

        expect(coordinator.currentStatus, SyncStatus.idle);
      },
    );

    test('dispose is safe without start and after stop', () async {
      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );

      await coordinator.dispose();

      final BackgroundSyncCoordinator started = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );
      await started.start();
      await started.stop();
      await started.dispose();

      expect(started.currentStatus, SyncStatus.idle);
    });

    test('retries failed operations with exponential backoff', () async {
      final SyncOperation operation = SyncOperation.create(
        entityType: 'counter',
        payload: const <String, dynamic>{'count': 2},
        idempotencyKey: 'retry-key',
      );
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async => <SyncOperation>[operation]);
      final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
      when(() => syncableRepo.entityType).thenReturn('counter');
      when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
      when(
        () => syncableRepo.processOperation(operation),
      ).thenThrow(Exception('fail'));
      registry.register(syncableRepo);

      DateTime? capturedRetryAt;
      int? capturedRetryCount;
      final DateTime measurementStart = DateTime.now().toUtc();
      when(
        () => pendingRepository.markFailed(
          operationId: operation.id,
          nextRetryAt: any(named: 'nextRetryAt'),
          retryCount: any(named: 'retryCount'),
        ),
      ).thenAnswer((invocation) async {
        capturedRetryAt = invocation.namedArguments[#nextRetryAt] as DateTime?;
        capturedRetryCount = invocation.namedArguments[#retryCount] as int?;
      });

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );
      final List<SyncStatus> emitted = <SyncStatus>[];
      coordinator.statusStream.listen(emitted.add);

      await coordinator.start();
      networkController.add(NetworkStatus.online);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(capturedRetryCount, 1);
      expect(capturedRetryAt, isNotNull);
      expect(capturedRetryAt!.isAfter(measurementStart), isTrue);
      expect(emitted.contains(SyncStatus.degraded), isTrue);
      await coordinator.stop();
    });

    test(
      'processes successes and retries failures within the same batch',
      () async {
        final SyncOperation successOp = SyncOperation.create(
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 3},
          idempotencyKey: 'success',
        );
        final SyncOperation failOp = SyncOperation.create(
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 4},
          idempotencyKey: 'fail',
        );
        final List<List<SyncOperation>> batches = <List<SyncOperation>>[
          <SyncOperation>[successOp, failOp],
          <SyncOperation>[],
        ];
        when(
          () => pendingRepository.getPendingOperations(now: any(named: 'now')),
        ).thenAnswer(
          (_) async => batches.isNotEmpty ? batches.removeAt(0) : [],
        );

        final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
        when(() => syncableRepo.entityType).thenReturn('counter');
        when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
        when(
          () => syncableRepo.processOperation(successOp),
        ).thenAnswer((_) async {});
        when(
          () => syncableRepo.processOperation(failOp),
        ).thenThrow(Exception('fail op'));
        registry.register(syncableRepo);

        when(
          () => pendingRepository.markCompleted(successOp.id),
        ).thenAnswer((_) async {});
        DateTime? failedRetryAt;
        when(
          () => pendingRepository.markFailed(
            operationId: failOp.id,
            nextRetryAt: any(named: 'nextRetryAt'),
            retryCount: any(named: 'retryCount'),
          ),
        ).thenAnswer((invocation) async {
          failedRetryAt = invocation.namedArguments[#nextRetryAt] as DateTime?;
        });

        final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
          repository: pendingRepository,
          networkStatusService: networkService,
          timerService: timerService,
          registry: registry,
          syncInterval: const Duration(milliseconds: 10),
        );
        final List<SyncStatus> emitted = <SyncStatus>[];
        coordinator.statusStream.listen(emitted.add);

        await coordinator.start();
        networkController.add(NetworkStatus.online);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        // Counter ops are coalesced: only the one with max count (failOp) is
        // processed; successOp is marked completed without processing
        verify(() => syncableRepo.processOperation(failOp)).called(1);
        verify(() => pendingRepository.markCompleted(successOp.id)).called(1);
        verifyNever(() => pendingRepository.markCompleted(failOp.id));
        verify(
          () => pendingRepository.markFailed(
            operationId: failOp.id,
            nextRetryAt: any(named: 'nextRetryAt'),
            retryCount: 1,
          ),
        ).called(1);
        expect(failedRetryAt, isNotNull);
        expect(emitted.contains(SyncStatus.degraded), isTrue);

        // Trigger a subsequent periodic sync to drain and emit idle
        (timerService as _ControllableTimerService).tick();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(emitted.contains(SyncStatus.idle), isTrue);
        await coordinator.stop();
      },
    );

    test('ignores offline events and only syncs when online', () async {
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async => <SyncOperation>[]);
      final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
      when(() => syncableRepo.entityType).thenReturn('counter');
      when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
      registry.register(syncableRepo);

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );
      final List<SyncStatus> emitted = <SyncStatus>[];
      coordinator.statusStream.listen(emitted.add);

      await coordinator.start();

      // When offline, getCurrentStatus should return offline to prevent sync
      when(
        () => networkService.getCurrentStatus(),
      ).thenAnswer((_) async => NetworkStatus.offline);
      networkController.add(NetworkStatus.offline);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        emitted.where((final SyncStatus s) => s == SyncStatus.syncing),
        isEmpty,
      );
      // Network check in _triggerSync prevents sync when offline

      // When online, getCurrentStatus should return online to allow sync
      when(
        () => networkService.getCurrentStatus(),
      ).thenAnswer((_) async => NetworkStatus.online);
      networkController.add(NetworkStatus.online);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        emitted.where((final SyncStatus s) => s == SyncStatus.degraded),
        isEmpty,
      );
      await coordinator.stop();
    });

    test('drops operations with unknown entity types', () async {
      final SyncOperation orphan = SyncOperation.create(
        entityType: 'ghost',
        payload: const <String, dynamic>{},
        idempotencyKey: 'ghost',
      );
      int requestCount = 0;
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async {
        requestCount++;
        return requestCount == 1 ? <SyncOperation>[orphan] : <SyncOperation>[];
      });
      when(
        () => pendingRepository.markCompleted(orphan.id),
      ).thenAnswer((_) async {});

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );
      final List<SyncStatus> emitted = <SyncStatus>[];
      coordinator.statusStream.listen(emitted.add);

      await coordinator.flush();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      verify(() => pendingRepository.markCompleted(orphan.id)).called(1);
      expect(
        emitted.where((final SyncStatus s) => s == SyncStatus.syncing),
        isNotEmpty,
      );
      expect(emitted.contains(SyncStatus.idle), isTrue);
    });

    test('retries failed operation on subsequent manual flush', () async {
      final SyncOperation retryOp = SyncOperation.create(
        entityType: 'counter',
        payload: const <String, dynamic>{'count': 5},
        idempotencyKey: 'retry',
      );
      int fetchCount = 0;
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async {
        fetchCount++;
        return fetchCount <= 2 ? <SyncOperation>[retryOp] : <SyncOperation>[];
      });
      final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
      when(() => syncableRepo.entityType).thenReturn('counter');
      when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
      int attempts = 0;
      when(() => syncableRepo.processOperation(retryOp)).thenAnswer((_) async {
        attempts++;
        if (attempts == 1) {
          throw Exception('temporary failure');
        }
      });
      registry.register(syncableRepo);
      when(
        () => pendingRepository.markFailed(
          operationId: retryOp.id,
          nextRetryAt: any(named: 'nextRetryAt'),
          retryCount: any(named: 'retryCount'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => pendingRepository.markCompleted(retryOp.id),
      ).thenAnswer((_) async {});

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );
      final List<SyncStatus> emitted = <SyncStatus>[];
      coordinator.statusStream.listen(emitted.add);

      await coordinator.flush();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await coordinator.flush();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(attempts, 2);
      verify(
        () => pendingRepository.markFailed(
          operationId: retryOp.id,
          nextRetryAt: any(named: 'nextRetryAt'),
          retryCount: 1,
        ),
      ).called(1);
      verify(() => pendingRepository.markCompleted(retryOp.id)).called(1);
      expect(emitted.contains(SyncStatus.degraded), isTrue);
      expect(emitted.contains(SyncStatus.idle), isTrue);
    });

    test('continues in-flight flush while connectivity flaps', () async {
      final SyncOperation op = SyncOperation.create(
        entityType: 'counter',
        payload: const <String, dynamic>{'count': 9},
        idempotencyKey: 'flap',
      );
      int fetchCount = 0;
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async {
        fetchCount++;
        return fetchCount == 1 ? <SyncOperation>[op] : <SyncOperation>[];
      });
      final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
      when(() => syncableRepo.entityType).thenReturn('counter');
      when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
      when(() => syncableRepo.processOperation(op)).thenAnswer(
        (_) async => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      registry.register(syncableRepo);
      when(
        () => pendingRepository.markCompleted(op.id),
      ).thenAnswer((_) async {});

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );
      final List<SyncStatus> emitted = <SyncStatus>[];
      coordinator.statusStream.listen(emitted.add);

      await coordinator.start();
      final Future<void> flushFuture = coordinator.flush();
      networkController.add(NetworkStatus.offline);
      networkController.add(NetworkStatus.online);
      await flushFuture;
      await Future<void>.delayed(const Duration(milliseconds: 1));

      verify(() => syncableRepo.processOperation(op)).called(1);
      verify(() => pendingRepository.markCompleted(op.id)).called(1);
      expect(emitted.contains(SyncStatus.syncing), isTrue);
      expect(emitted.contains(SyncStatus.idle), isTrue);
      await coordinator.stop();
    });

    test(
      'coalesces immediate triggers and avoids overlapping sync cycles',
      () async {
        final SyncOperation op = SyncOperation.create(
          entityType: 'counter',
          payload: const <String, dynamic>{'count': 10},
          idempotencyKey: 'coalesce',
        );

        final Completer<void> operationCompleter = Completer<void>();
        final Completer<void> operationStarted = Completer<void>();
        int pendingCalls = 0;
        when(
          () => pendingRepository.getPendingOperations(now: any(named: 'now')),
        ).thenAnswer((_) async {
          pendingCalls++;
          // start() performs an initial sync; keep it fast/empty.
          if (pendingCalls == 1) {
            return <SyncOperation>[];
          }
          // The first manual flush returns a real operation and blocks.
          if (pendingCalls == 2) {
            return <SyncOperation>[op];
          }
          // A coalesced follow-up run is allowed only after the first completes.
          if (!operationCompleter.isCompleted) {
            throw StateError(
              'Overlapping sync cycle detected: second cycle started early',
            );
          }
          return <SyncOperation>[];
        });

        final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
        when(() => syncableRepo.entityType).thenReturn('counter');
        when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
        when(() => syncableRepo.processOperation(op)).thenAnswer((_) async {
          if (!operationStarted.isCompleted) {
            operationStarted.complete();
          }
          return operationCompleter.future;
        });
        registry.register(syncableRepo);
        when(
          () => pendingRepository.markCompleted(op.id),
        ).thenAnswer((_) async {});

        final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
          repository: pendingRepository,
          networkStatusService: networkService,
          timerService: timerService,
          registry: registry,
          syncInterval: const Duration(milliseconds: 10),
        );

        await coordinator.start();

        final Future<void> flushFuture = coordinator.flush();

        // Ensure the sync cycle is actively processing before triggering.
        await operationStarted.future;

        // Trigger multiple sync requests while flush is in-flight.
        networkController.add(NetworkStatus.online);
        (timerService as _ControllableTimerService).tick();

        operationCompleter.complete();

        await flushFuture;
        await Future<void>.delayed(const Duration(milliseconds: 5));

        verify(() => syncableRepo.processOperation(op)).called(1);
        verify(() => pendingRepository.markCompleted(op.id)).called(1);
        expect(pendingCalls, greaterThanOrEqualTo(3));

        await coordinator.stop();
      },
    );

    test('coalesces duplicate FCM triggers into a single run', () async {
      final SyncOperation op = SyncOperation.create(
        entityType: 'counter',
        payload: const <String, dynamic>{'count': 11},
        idempotencyKey: 'fcm-coalesce',
      );

      final Completer<void> operationCompleter = Completer<void>();
      final Completer<void> operationStarted = Completer<void>();
      int pendingCalls = 0;
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async {
        pendingCalls++;
        // start() performs an initial sync; keep it fast/empty.
        if (pendingCalls == 1) {
          return <SyncOperation>[];
        }
        // The first FCM trigger returns a real operation and blocks.
        if (pendingCalls == 2) {
          return <SyncOperation>[op];
        }
        // Any follow-up should happen only after the first completes.
        if (!operationCompleter.isCompleted) {
          throw StateError('Overlapping sync cycle detected');
        }
        return <SyncOperation>[];
      });

      final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
      when(() => syncableRepo.entityType).thenReturn('counter');
      when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
      when(() => syncableRepo.processOperation(op)).thenAnswer((_) async {
        if (!operationStarted.isCompleted) {
          operationStarted.complete();
        }
        return operationCompleter.future;
      });
      registry.register(syncableRepo);
      when(
        () => pendingRepository.markCompleted(op.id),
      ).thenAnswer((_) async {});

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
      );

      await coordinator.start();

      final Future<void> first = coordinator.triggerFromFcm(hint: 'sync-now');
      await operationStarted.future;

      // Duplicate push event while in-flight should coalesce, not overlap.
      final Future<void> second = coordinator.triggerFromFcm(hint: 'sync-now');

      operationCompleter.complete();
      await Future.wait<void>(<Future<void>>[first, second]);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      verify(() => syncableRepo.processOperation(op)).called(1);
      verify(() => pendingRepository.markCompleted(op.id)).called(1);
      expect(pendingCalls, greaterThanOrEqualTo(3));

      await coordinator.stop();
    });

    test('realtime subscription callback triggers an immediate sync', () async {
      void Function()? onSyncRequested;
      final SyncOperation op = SyncOperation.create(
        entityType: 'counter',
        payload: const <String, dynamic>{'count': 12},
        idempotencyKey: 'realtime-sync',
      );

      int pendingCalls = 0;
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((_) async {
        pendingCalls++;
        if (pendingCalls == 1) {
          return <SyncOperation>[];
        }
        if (pendingCalls == 2) {
          return <SyncOperation>[op];
        }
        return <SyncOperation>[];
      });

      final _MockSyncableRepository syncableRepo = _MockSyncableRepository();
      when(() => syncableRepo.entityType).thenReturn('counter');
      when(() => syncableRepo.pullRemote()).thenAnswer((_) async {});
      when(() => syncableRepo.processOperation(op)).thenAnswer((_) async {});
      registry.register(syncableRepo);
      when(
        () => pendingRepository.markCompleted(op.id),
      ).thenAnswer((_) async {});

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkService,
        timerService: timerService,
        registry: registry,
        syncInterval: const Duration(milliseconds: 10),
        startIotDemoRealtimeSubscription: (final callback) {
          onSyncRequested = callback;
        },
      );

      await coordinator.start();
      expect(onSyncRequested, isNotNull);

      onSyncRequested!.call();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      verify(() => syncableRepo.processOperation(op)).called(1);
      verify(() => pendingRepository.markCompleted(op.id)).called(1);
      expect(pendingCalls, greaterThanOrEqualTo(2));

      await coordinator.stop();
    });

    test(
      'flush degrades gracefully when network status lookup fails',
      () async {
        when(
          () => networkService.getCurrentStatus(),
        ).thenThrow(Exception('status lookup failed'));

        final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
          repository: pendingRepository,
          networkStatusService: networkService,
          timerService: timerService,
          registry: registry,
          syncInterval: const Duration(milliseconds: 10),
        );
        final List<SyncStatus> emitted = <SyncStatus>[];
        coordinator.statusStream.listen(emitted.add);

        await coordinator.flush();

        expect(coordinator.currentStatus, SyncStatus.degraded);
        expect(emitted.contains(SyncStatus.degraded), isTrue);

        await coordinator.stop();
      },
    );

    test(
      'degrades gracefully when enqueue subscription emits an error',
      () async {
        final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
          repository: pendingRepository,
          networkStatusService: networkService,
          timerService: timerService,
          registry: registry,
          syncInterval: const Duration(milliseconds: 10),
        );
        final List<SyncStatus> emitted = <SyncStatus>[];
        coordinator.statusStream.listen(emitted.add);

        await coordinator.start();
        enqueueController.addError(Exception('enqueue stream failed'));
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(coordinator.currentStatus, SyncStatus.degraded);
        expect(emitted.contains(SyncStatus.degraded), isTrue);

        await coordinator.stop();
      },
    );
  });
}
