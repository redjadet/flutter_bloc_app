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

  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) {
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
        () => pendingRepository.prune(
          maxRetryCount: any(named: 'maxRetryCount'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => 0);
    });

    tearDown(() async {
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

        verify(() => syncableRepo.processOperation(successOp)).called(1);
        verify(() => pendingRepository.markCompleted(successOp.id)).called(1);
        verify(() => syncableRepo.processOperation(failOp)).called(1);
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
      networkController.add(NetworkStatus.offline);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        emitted.where((final SyncStatus s) => s == SyncStatus.syncing),
        isEmpty,
      );

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
  });
}
