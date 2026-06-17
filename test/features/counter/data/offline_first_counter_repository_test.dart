import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeRemoteRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
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

class _ReReadAwareLocalRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
  _ReReadAwareLocalRepository(this._inner);

  final CounterRepository _inner;
  Future<void> Function()? onSecondLoad;
  int _loadCount = 0;

  @override
  Future<CounterSnapshot> load() async {
    _loadCount++;
    if (_loadCount == 2 && onSecondLoad != null) {
      await onSecondLoad!();
    }
    return _inner.load();
  }

  @override
  Future<void> save(final CounterSnapshot snapshot) => _inner.save(snapshot);

  @override
  Stream<CounterSnapshot> watch() => _inner.watch();
}

class _StreamRemoteRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
  _StreamRemoteRepository();

  final StreamController<CounterSnapshot> controller =
      StreamController<CounterSnapshot>.broadcast();

  @override
  Future<CounterSnapshot> load() async => const CounterSnapshot(count: 0);

  @override
  Future<void> save(final CounterSnapshot snapshot) async {}

  @override
  Stream<CounterSnapshot> watch() => controller.stream;
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
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
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

    test(
      'save generates changeId and enqueues operation when remote exists',
      () async {
        final _FakeRemoteRepository remote = _FakeRemoteRepository();
        final OfflineFirstCounterRepository repository =
            OfflineFirstCounterRepository(
              localRepository: localRepository,
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        await repository.save(const CounterSnapshot(count: 10));

        final CounterSnapshot stored = await localRepository.load();
        expect(stored.changeId, isNotEmpty);
        expect(stored.synchronized, isFalse);

        final List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        expect(pending.length, 1);
      },
    );

    test(
      'save stamps lastSyncedAt and synchronized when no remote repository',
      () async {
        final OfflineFirstCounterRepository repository =
            OfflineFirstCounterRepository(
              localRepository: localRepository,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        final DateTime before = DateTime.now().toUtc();
        await repository.save(const CounterSnapshot(count: 2));

        final CounterSnapshot stored = await localRepository.load();
        final DateTime after = DateTime.now().toUtc();
        expect(stored.synchronized, isTrue);
        expect(stored.lastSyncedAt, isNotNull);
        final DateTime lastSynced = stored.lastSyncedAt!;
        final int lastSyncedMs = lastSynced.millisecondsSinceEpoch;
        expect(lastSyncedMs >= before.millisecondsSinceEpoch, isTrue);
        expect(lastSyncedMs <= after.millisecondsSinceEpoch, isTrue);
      },
    );

    test('pending sync reads filter to counter entity only', () async {
      final OfflineFirstCounterRepository repository =
          OfflineFirstCounterRepository(
            localRepository: localRepository,
            pendingSyncRepository: pendingRepository,
            registry: registry,
          );

      await pendingRepository.enqueue(
        SyncOperation.create(
          entityType: OfflineFirstCounterRepository.counterEntity,
          payload: const CounterSnapshot(count: 1).toJson(),
          idempotencyKey: 'counter-op',
        ),
      );
      await pendingRepository.enqueue(
        SyncOperation.create(
          entityType: 'todo',
          payload: const <String, dynamic>{},
          idempotencyKey: 'todo-op',
        ),
      );

      expect(await repository.pendingSyncOperationCount(), 1);
      final List<CounterSyncQueueEntry> entries = await repository
          .pendingSyncQueueEntries();
      expect(entries, hasLength(1));
      expect(
        entries.single.entityType,
        OfflineFirstCounterRepository.counterEntity,
      );
    });

    test(
      'pullRemote does not overwrite newer synchronized local count',
      () async {
        final DateTime localChanged = DateTime(2024, 1, 2, 12);
        final _FakeRemoteRepository remote = _FakeRemoteRepository(
          initial: CounterSnapshot(
            count: 4,
            lastChanged: DateTime(2024, 1, 1, 12),
          ),
        );
        final OfflineFirstCounterRepository repository =
            OfflineFirstCounterRepository(
              localRepository: localRepository,
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        await localRepository.save(
          CounterSnapshot(
            count: 5,
            lastChanged: localChanged,
            synchronized: true,
            lastSyncedAt: localChanged,
          ),
        );

        await repository.pullRemote();

        final CounterSnapshot local = await localRepository.load();
        expect(local.count, 5);
        expect(local.lastChanged, localChanged);
      },
    );

    test(
      'remote watch does not overwrite newer synchronized local count',
      () async {
        final _StreamRemoteRepository remote = _StreamRemoteRepository();
        addTearDown(remote.controller.close);

        final OfflineFirstCounterRepository repository =
            OfflineFirstCounterRepository(
              localRepository: localRepository,
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        final DateTime localChanged = DateTime(2024, 1, 2, 12);
        await localRepository.save(
          CounterSnapshot(
            count: 5,
            lastChanged: localChanged,
            synchronized: true,
            lastSyncedAt: localChanged,
          ),
        );

        final StreamSubscription sub = repository.watch().listen((_) {});
        addTearDown(sub.cancel);

        remote.controller.add(
          CounterSnapshot(count: 4, lastChanged: DateTime(2024, 1, 1, 12)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final CounterSnapshot local = await localRepository.load();
        expect(local.count, 5);

        await sub.cancel();
      },
    );

    test(
      'remote watch re-checks local before save when local advances',
      () async {
        final _StreamRemoteRepository remote = _StreamRemoteRepository();
        addTearDown(remote.controller.close);

        final _ReReadAwareLocalRepository local = _ReReadAwareLocalRepository(
          localRepository,
        );
        final OfflineFirstCounterRepository repository =
            OfflineFirstCounterRepository(
              localRepository: local,
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        final DateTime initialChanged = DateTime(2024, 1, 1, 12);
        await localRepository.save(
          CounterSnapshot(
            count: 3,
            lastChanged: initialChanged,
            synchronized: true,
            lastSyncedAt: initialChanged,
          ),
        );

        final StreamSubscription sub = repository.watch().listen((_) {});
        addTearDown(sub.cancel);

        local.onSecondLoad = () async {
          final DateTime newerChanged = DateTime(2024, 1, 3, 12);
          await localRepository.save(
            CounterSnapshot(
              count: 4,
              lastChanged: newerChanged,
              synchronized: false,
            ),
          );
        };

        remote.controller.add(
          CounterSnapshot(count: 5, lastChanged: DateTime(2024, 1, 2, 12)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final CounterSnapshot stored = await localRepository.load();
        expect(stored.count, 4);
        expect(stored.lastChanged, DateTime(2024, 1, 3, 12));

        await sub.cancel();
      },
    );

    test(
      'remote watch does not overwrite newer unsynced local count',
      () async {
        final _StreamRemoteRepository remote = _StreamRemoteRepository();
        addTearDown(remote.controller.close);

        final OfflineFirstCounterRepository repository =
            OfflineFirstCounterRepository(
              localRepository: localRepository,
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        final DateTime localChanged = DateTime(2024, 1, 2, 12);
        await repository.save(
          CounterSnapshot(count: 5, lastChanged: localChanged),
        );

        final StreamSubscription sub = repository.watch().listen((_) {});
        addTearDown(sub.cancel);

        // Emit a stale remote snapshot (older timestamp, different count).
        remote.controller.add(
          CounterSnapshot(count: 4, lastChanged: DateTime(2024, 1, 1, 12)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final CounterSnapshot local = await localRepository.load();
        expect(local.count, 5);

        await sub.cancel();
      },
    );

    test(
      'processOperation does not push stale pending over newer remote',
      () async {
        final DateTime pendingChanged = DateTime(2024, 1, 1, 12);
        final DateTime remoteChanged = DateTime(2024, 1, 2, 12);
        final _FakeRemoteRepository remote = _FakeRemoteRepository(
          initial: CounterSnapshot(
            count: 10,
            lastChanged: remoteChanged,
          ),
        );
        final OfflineFirstCounterRepository repository =
            OfflineFirstCounterRepository(
              localRepository: localRepository,
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        await localRepository.save(
          CounterSnapshot(
            count: 6,
            lastChanged: pendingChanged,
            synchronized: false,
          ),
        );

        final SyncOperation operation = SyncOperation.create(
          entityType: OfflineFirstCounterRepository.counterEntity,
          payload: CounterSnapshot(
            count: 6,
            lastChanged: pendingChanged,
          ).toJson(),
          idempotencyKey: 'stale-op',
        );

        await repository.processOperation(operation);

        expect(remote.saved, isNull);
        expect((await remote.load()).count, 10);
        final CounterSnapshot local = await localRepository.load();
        expect(local.count, 10);
        expect(local.synchronized, isTrue);
        expect(local.lastSyncedAt, isNotNull);
      },
    );
  });
}
