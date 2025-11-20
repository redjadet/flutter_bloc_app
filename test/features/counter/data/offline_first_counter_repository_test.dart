import 'dart:io';

import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeRemoteRepository implements CounterRepository {
  _FakeRemoteRepository({CounterSnapshot? initial}) : _snapshot = initial;

  CounterSnapshot? _snapshot;
  CounterSnapshot? saved;

  @override
  Future<CounterSnapshot> load() async =>
      _snapshot ?? const CounterSnapshot(count: 0);

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    saved = snapshot;
    _snapshot = snapshot;
  }

  @override
  Stream<CounterSnapshot> watch() async* {
    yield _snapshot ?? const CounterSnapshot(count: 0);
  }
}

void main() {
  group('OfflineFirstCounterRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late HiveCounterRepository localRepository;
    late PendingSyncRepository pendingRepository;
    late SyncableRepositoryRegistry registry;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('offline_counter_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(keyManager: HiveKeyManager());
      await hiveService.initialize();
      localRepository = HiveCounterRepository(hiveService: hiveService);
      pendingRepository = PendingSyncRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
    });

    tearDown(() async {
      await pendingRepository.clear();
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('processOperation updates remote and local state', () async {
      final _FakeRemoteRepository remote = _FakeRemoteRepository();
      final OfflineFirstCounterRepository repository =
          OfflineFirstCounterRepository(
            localRepository: localRepository,
            remoteRepository: remote,
            pendingSyncRepository: pendingRepository,
            registry: registry,
          );

      final SyncOperation operation = SyncOperation.create(
        entityType: OfflineFirstCounterRepository.counterEntity,
        payload: const CounterSnapshot(count: 5).toJson(),
        idempotencyKey: 'op-1',
      );

      await repository.processOperation(operation);

      expect(remote.saved?.count, 5);
      final CounterSnapshot local = await localRepository.load();
      expect(local.count, 5);
      expect(local.synchronized, isTrue);
      expect(local.lastSyncedAt, isNotNull);
    });

    test('pullRemote applies newer snapshot', () async {
      final DateTime remoteTimestamp = DateTime(2024, 1, 2);
      final _FakeRemoteRepository remote = _FakeRemoteRepository(
        initial: CounterSnapshot(count: 7, lastChanged: remoteTimestamp),
      );
      final OfflineFirstCounterRepository repository =
          OfflineFirstCounterRepository(
            localRepository: localRepository,
            remoteRepository: remote,
            pendingSyncRepository: pendingRepository,
            registry: registry,
          );

      await localRepository.save(
        const CounterSnapshot(count: 1, lastChanged: null),
      );

      await repository.pullRemote();

      final CounterSnapshot updated = await localRepository.load();
      expect(updated.count, 7);
      expect(updated.lastChanged, remoteTimestamp);
      expect(updated.synchronized, isTrue);
    });
  });
}
