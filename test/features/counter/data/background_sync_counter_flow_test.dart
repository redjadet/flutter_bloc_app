import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class _MockNetworkStatusService extends Mock implements NetworkStatusService {}

class _FakeRemoteCounterRepository implements CounterRepository {
  CounterSnapshot _snapshot = const CounterSnapshot(count: 0);

  @override
  Future<CounterSnapshot> load() async => _snapshot;

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    _snapshot = snapshot;
  }

  @override
  Stream<CounterSnapshot> watch() async* {
    yield _snapshot;
  }
}

class _FakeStreamController<T> {
  _FakeStreamController() : controller = StreamController<T>.broadcast();

  final StreamController<T> controller;

  void add(final T value) => controller.add(value);

  Stream<T> get stream => controller.stream;

  Future<void> close() => controller.close();
}

void main() {
  group('Background sync + OfflineFirstCounterRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late HiveCounterRepository localRepository;
    late PendingSyncRepository pendingRepository;
    late SyncableRepositoryRegistry registry;
    late NetworkStatusService networkStatusService;
    late _FakeStreamController<NetworkStatus> statusController;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('background_counter_flow');
      Hive.init(tempDir.path);
      hiveService = HiveService(keyManager: HiveKeyManager());
      await hiveService.initialize();
      localRepository = HiveCounterRepository(hiveService: hiveService);
      pendingRepository = PendingSyncRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
      networkStatusService = _MockNetworkStatusService();
      statusController = _FakeStreamController<NetworkStatus>();
      when(
        () => networkStatusService.statusStream,
      ).thenAnswer((_) => statusController.stream);
      when(
        () => networkStatusService.getCurrentStatus(),
      ).thenAnswer((_) async => NetworkStatus.online);
    });

    tearDown(() async {
      await pendingRepository.clear();
      await statusController.close();
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('coordinator flushes queued operations end-to-end', () async {
      final OfflineFirstCounterRepository repo = OfflineFirstCounterRepository(
        localRepository: localRepository,
        pendingSyncRepository: pendingRepository,
        registry: registry,
        remoteRepository: _FakeRemoteCounterRepository(),
      );

      final CounterSnapshot snapshot = const CounterSnapshot(count: 3);
      await repo.save(snapshot);
      final List<SyncOperation> pendingBefore = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pendingBefore.length, 1);

      final BackgroundSyncCoordinator coordinator = BackgroundSyncCoordinator(
        repository: pendingRepository,
        networkStatusService: networkStatusService,
        timerService: _ImmediateTimerService(),
        registry: registry,
        syncInterval: const Duration(milliseconds: 5),
      );

      await coordinator.start();
      statusController.add(NetworkStatus.online);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final List<SyncOperation> pendingAfter = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pendingAfter, isEmpty);
      final CounterSnapshot updated = await localRepository.load();
      expect(updated.count, 3);
      await coordinator.stop();
    });
  });
}

class _ImmediateTimerService implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) {
    onTick();
    return _ImmediateTimerDisposable();
  }

  @override
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  ) {
    onComplete();
    return _ImmediateTimerDisposable();
  }
}

class _ImmediateTimerDisposable implements TimerDisposable {
  @override
  void dispose() {}
}
