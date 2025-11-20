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

class _FakeTimerService extends Fake implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) => _FakeTimerDisposable(onTick);
}

class _FakeTimerDisposable implements TimerDisposable {
  _FakeTimerDisposable(this.onTick);
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
    });

    setUp(() {
      pendingRepository = _MockPendingSyncRepository();
      networkService = _MockNetworkStatusService();
      timerService = _FakeTimerService();
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
      networkController.add(NetworkStatus.online);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      verify(() => syncableRepo.processOperation(operation)).called(2);
      expect(emitted.contains(SyncStatus.syncing), isTrue);
      await coordinator.stop();
    });
  });
}
