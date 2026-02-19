import 'dart:io';

import 'package:flutter_bloc_app/features/todo_list/data/hive_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeRemoteRepository extends TodoRepository {
  _FakeRemoteRepository({
    List<TodoItem>? initial,
    this.shouldThrowOnSave = false,
    this.shouldThrowOnDelete = false,
    // Keep disabled by default to avoid background merges affecting tests.
    this.enableWatch = false,
  }) : _items = initial ?? [];

  List<TodoItem> _items = [];
  final List<TodoItem> savedItems = [];
  final List<String> deletedIds = [];
  final bool shouldThrowOnSave;
  final bool shouldThrowOnDelete;
  final bool enableWatch;

  @override
  Future<List<TodoItem>> fetchAll() async => List<TodoItem>.from(_items);

  @override
  Stream<List<TodoItem>> watchAll() async* {
    if (!enableWatch) {
      yield* Stream<List<TodoItem>>.empty();
      return;
    }
    yield List<TodoItem>.from(_items);
  }

  @override
  Future<void> save(final TodoItem item) async {
    if (shouldThrowOnSave) {
      throw Exception('Simulated remote save failure');
    }
    savedItems.add(item);
    _items = _items.where((final i) => i.id != item.id).toList()..add(item);
  }

  @override
  Future<void> delete(final String id) async {
    if (shouldThrowOnDelete) {
      throw Exception('Simulated remote delete failure');
    }
    deletedIds.add(id);
    _items = _items.where((final i) => i.id != id).toList();
  }

  @override
  Future<void> clearCompleted() async {
    final List<TodoItem> completed = _items
        .where((final item) => item.isCompleted)
        .toList(growable: false);
    for (final TodoItem item in completed) {
      await delete(item.id);
    }
  }
}

void main() {
  group('OfflineFirstTodoRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late HiveTodoRepository localRepository;
    late PendingSyncRepository pendingRepository;
    late SyncableRepositoryRegistry registry;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('offline_todo_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(keyManager: HiveKeyManager());
      await hiveService.initialize();
      localRepository = HiveTodoRepository(hiveService: hiveService);
      pendingRepository = PendingSyncRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
    });

    tearDown(() async {
      await pendingRepository.clear();
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test(
      'processOperation updates remote and local for save operation',
      () async {
        final _FakeRemoteRepository remote = _FakeRemoteRepository();
        final OfflineFirstTodoRepository repository =
            OfflineFirstTodoRepository(
              localRepository: localRepository,
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        final TodoItem item = TodoItem.create(
          title: 'Test Todo',
          description: 'Test Description',
        );

        final SyncOperation operation = SyncOperation.create(
          entityType: OfflineFirstTodoRepository.todoEntity,
          payload: item.toJson(),
          idempotencyKey: 'op-1',
        );

        await repository.processOperation(operation);

        expect(remote.savedItems.length, 1);
        expect(remote.savedItems.first.title, 'Test Todo');

        final List<TodoItem> local = await localRepository.fetchAll();
        expect(local.length, 1);
        expect(local.first.title, 'Test Todo');
        expect(local.first.synchronized, isTrue);
        expect(local.first.lastSyncedAt, isNotNull);
      },
    );

    test('processOperation handles delete operation', () async {
      final _FakeRemoteRepository remote = _FakeRemoteRepository();
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item = TodoItem.create(title: 'To Delete');
      await localRepository.save(item);

      final SyncOperation operation = SyncOperation.create(
        entityType: OfflineFirstTodoRepository.todoEntity,
        payload: <String, dynamic>{'id': item.id, 'deleted': true},
        idempotencyKey: 'delete-op-1',
      );

      await repository.processOperation(operation);

      expect(remote.deletedIds, contains(item.id));

      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local, isEmpty);
    });

    test('processOperation handles delete when no remote repository', () async {
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item = TodoItem.create(title: 'To Delete');
      await localRepository.save(item);

      final SyncOperation operation = SyncOperation.create(
        entityType: OfflineFirstTodoRepository.todoEntity,
        payload: <String, dynamic>{'id': item.id, 'deleted': true},
        idempotencyKey: 'delete-op-1',
      );

      await repository.processOperation(operation);

      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local, isEmpty);
    });

    test('pullRemote applies newer remote items', () async {
      final DateTime remoteTimestamp = DateTime.now().toUtc().subtract(
        const Duration(hours: 1),
      );
      final TodoItem remoteItem = TodoItem.create(
        title: 'Remote Todo',
        description: 'From Remote',
      ).copyWith(updatedAt: remoteTimestamp);

      final _FakeRemoteRepository remote = _FakeRemoteRepository(
        initial: [remoteItem],
        enableWatch: false,
      );
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      await repository.pullRemote();

      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local.length, 1);
      expect(local.first.title, 'Remote Todo');
      expect(local.first.synchronized, isTrue);
      expect(local.first.lastSyncedAt, isNotNull);
    });

    test('pullRemote applies remote when local item is older', () async {
      final DateTime localTimestamp = DateTime.utc(2024, 1, 1, 10);
      final DateTime remoteTimestamp = DateTime.utc(2024, 1, 1, 12);

      final TodoItem remoteItem = TodoItem.create(
        title: 'Remote Updated',
        description: 'Newer',
        now: remoteTimestamp,
      );

      final TodoItem localItem =
          TodoItem.create(
            title: 'Local Old',
            description: 'Older',
            now: localTimestamp,
          ).copyWith(
            id: remoteItem.id,
            updatedAt: localTimestamp,
            synchronized: true,
          );

      final _FakeRemoteRepository remote = _FakeRemoteRepository(
        initial: [remoteItem],
        enableWatch: false,
      );
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      await localRepository.save(localItem);
      final List<TodoItem> beforePull = await localRepository.fetchAll();
      expect(beforePull.length, 1);
      expect(beforePull.first.title, 'Local Old');
      expect(beforePull.first.updatedAt.isBefore(remoteItem.updatedAt), isTrue);
      await repository.pullRemote();

      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local.length, 1);
      expect(local.first.title, 'Remote Updated');
      expect(local.first.synchronized, isTrue);
    });

    test('pullRemote does not apply remote when local item is newer', () async {
      final DateTime remoteTimestamp = DateTime.utc(2024, 1, 1, 10);
      final DateTime localTimestamp = DateTime.utc(2024, 1, 1, 12);

      final TodoItem remoteItem = TodoItem.create(
        title: 'Remote Old',
        description: 'Older',
      ).copyWith(updatedAt: remoteTimestamp);

      final TodoItem localItem =
          TodoItem.create(
            title: 'Local Updated',
            description: 'Newer',
          ).copyWith(
            id: remoteItem.id,
            updatedAt: localTimestamp,
            synchronized: true,
          );

      final _FakeRemoteRepository remote = _FakeRemoteRepository(
        initial: [remoteItem],
        enableWatch: false,
      );
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      await localRepository.save(localItem);
      await repository.pullRemote();

      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local.length, 1);
      expect(local.first.title, 'Local Updated');
    });

    test('save syncs immediately to remote when remote exists', () async {
      final _FakeRemoteRepository remote = _FakeRemoteRepository();
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item = TodoItem.create(title: 'Test Todo');
      await repository.save(item);

      // Verify item was saved to local
      final List<TodoItem> stored = await localRepository.fetchAll();
      expect(stored.length, 1);
      expect(stored.first.title, 'Test Todo');
      expect(stored.first.changeId, isNotEmpty);
      expect(stored.first.synchronized, isTrue);
      expect(stored.first.lastSyncedAt, isNotNull);

      // Verify item was saved to remote immediately
      expect(remote.savedItems.length, 1);
      expect(remote.savedItems.first.title, 'Test Todo');

      // Verify no operation was enqueued (since sync succeeded)
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.length, 0);
    });

    test(
      'save stamps lastSyncedAt and synchronized when no remote repository',
      () async {
        final OfflineFirstTodoRepository repository =
            OfflineFirstTodoRepository(
              localRepository: localRepository,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        final DateTime before = DateTime.now().toUtc();
        final TodoItem item = TodoItem.create(title: 'Test Todo');
        await repository.save(item);

        final List<TodoItem> stored = await localRepository.fetchAll();
        final DateTime after = DateTime.now().toUtc();
        expect(stored.length, 1);
        expect(stored.first.synchronized, isTrue);
        expect(stored.first.lastSyncedAt, isNotNull);
        final DateTime lastSynced = stored.first.lastSyncedAt!;
        final int lastSyncedMs = lastSynced.millisecondsSinceEpoch;
        expect(lastSyncedMs >= before.millisecondsSinceEpoch, isTrue);
        expect(lastSyncedMs <= after.millisecondsSinceEpoch, isTrue);
      },
    );

    test('delete syncs immediately to remote when remote exists', () async {
      final _FakeRemoteRepository remote = _FakeRemoteRepository();
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item = TodoItem.create(title: 'To Delete');
      await localRepository.save(item);
      await remote.save(item); // Pre-populate remote

      await repository.delete(item.id);

      // Verify item was deleted from local
      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local, isEmpty);

      // Verify item was deleted from remote immediately
      expect(remote.deletedIds.length, 1);
      expect(remote.deletedIds.first, item.id);

      // Verify no operation was enqueued (since sync succeeded)
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.length, 0);
    });

    test('save queues operation when remote save fails', () async {
      final _FakeRemoteRepository remote = _FakeRemoteRepository(
        shouldThrowOnSave: true,
      );
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item = TodoItem.create(title: 'Test Todo');
      await repository.save(item);

      // Verify item was saved to local
      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local.length, 1);
      expect(local.first.title, 'Test Todo');
      expect(local.first.synchronized, isFalse); // Not synced due to error

      // Verify operation was enqueued for retry
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.length, 1);
      expect(pending.first.entityType, 'todo');
    });

    test('delete queues operation when remote delete fails', () async {
      final _FakeRemoteRepository remote = _FakeRemoteRepository(
        shouldThrowOnDelete: true,
      );
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item = TodoItem.create(title: 'Test Todo');
      await localRepository.save(item);

      await repository.delete(item.id);

      // Verify item was deleted from local
      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local, isEmpty);

      // Verify operation was enqueued for retry
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.length, 1);
      expect(pending.first.entityType, 'todo');
      expect(pending.first.payload['id'], item.id);
      expect(pending.first.payload['deleted'], isTrue);
    });

    test('clearCompleted deletes all completed items', () async {
      final _FakeRemoteRepository remote = _FakeRemoteRepository();
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item1 = TodoItem.create(
        title: 'Completed 1',
      ).copyWith(isCompleted: true);
      final TodoItem item2 = TodoItem.create(title: 'Active');
      final TodoItem item3 = TodoItem.create(
        title: 'Completed 2',
      ).copyWith(isCompleted: true);

      await localRepository.save(item1);
      await localRepository.save(item2);
      await localRepository.save(item3);
      await remote.save(item1); // Pre-populate remote
      await remote.save(item2);
      await remote.save(item3);

      await repository.clearCompleted();

      final List<TodoItem> local = await localRepository.fetchAll();
      expect(local.length, 1);
      expect(local.first.title, 'Active');
      expect(local.first.isCompleted, isFalse);

      // Verify items were deleted from remote immediately
      expect(remote.deletedIds.length, 2);
      expect(remote.deletedIds, contains(item1.id));
      expect(remote.deletedIds, contains(item3.id));

      // Verify no operations were enqueued (since sync succeeded)
      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.length, 0);
    });

    test('fetchAll returns items from local repository', () async {
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item1 = TodoItem.create(title: 'Item 1');
      final TodoItem item2 = TodoItem.create(title: 'Item 2');
      await localRepository.save(item1);
      await localRepository.save(item2);

      final List<TodoItem> items = await repository.fetchAll();
      expect(items.length, 2);
    });

    test('watchAll streams items from local repository', () async {
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      final TodoItem item = TodoItem.create(title: 'Item');
      await localRepository.save(item);

      final List<TodoItem> items = await repository.watchAll().first;
      expect(items.length, 1);
      expect(items.first.title, 'Item');
    });

    test('dispose unregisters repository from syncable registry', () async {
      final OfflineFirstTodoRepository repository = OfflineFirstTodoRepository(
        localRepository: localRepository,
        pendingSyncRepository: pendingRepository,
        registry: registry,
      );

      expect(
        registry.resolve(OfflineFirstTodoRepository.todoEntity),
        same(repository),
      );

      await repository.dispose();

      expect(registry.resolve(OfflineFirstTodoRepository.todoEntity), isNull);
    });

    test(
      'dispose does not unregister a newer repository instance for same entity',
      () async {
        final OfflineFirstTodoRepository firstRepository =
            OfflineFirstTodoRepository(
              localRepository: localRepository,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );
        final OfflineFirstTodoRepository secondRepository =
            OfflineFirstTodoRepository(
              localRepository: localRepository,
              pendingSyncRepository: pendingRepository,
              registry: registry,
            );

        expect(
          registry.resolve(OfflineFirstTodoRepository.todoEntity),
          same(secondRepository),
        );

        await firstRepository.dispose();

        expect(
          registry.resolve(OfflineFirstTodoRepository.todoEntity),
          same(secondRepository),
        );

        await secondRepository.dispose();
        expect(registry.resolve(OfflineFirstTodoRepository.todoEntity), isNull);
      },
    );
  });
}
