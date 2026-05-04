import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc_app/features/todo_list/data/hive_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_schema_migration.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('HiveTodoRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late HiveTodoRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('todo_list_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = HiveTodoRepository(hiveService: hiveService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('fetchAll returns empty list initially', () async {
      final List<TodoItem> result = await repository.fetchAll();
      expect(result, isEmpty);
    });

    test('save persists items and sorts by updatedAt desc', () async {
      final TodoItem older = _todoItem(
        id: 'a',
        title: 'Older',
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      final TodoItem newer = _todoItem(
        id: 'b',
        title: 'Newer',
        updatedAt: DateTime.utc(2024, 1, 2),
      );

      await repository.save(older);
      await repository.save(newer);

      final List<TodoItem> result = await repository.fetchAll();
      expect(result.length, 2);
      expect(result.first.id, 'b');
      expect(result.last.id, 'a');
    });

    test('save updates an existing item', () async {
      final TodoItem original = _todoItem(
        id: 'a',
        title: 'Original',
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      final TodoItem updated = original.copyWith(
        title: 'Updated',
        updatedAt: DateTime.utc(2024, 1, 3),
      );

      await repository.save(original);
      await repository.save(updated);

      final List<TodoItem> result = await repository.fetchAll();
      expect(result.length, 1);
      expect(result.first.title, 'Updated');
      expect(result.first.updatedAt, DateTime.utc(2024, 1, 3));
    });

    test('delete removes an item', () async {
      final TodoItem item = _todoItem(id: 'a', title: 'Delete');
      await repository.save(item);

      await repository.delete('a');

      final List<TodoItem> result = await repository.fetchAll();
      expect(result, isEmpty);
    });

    test('clearCompleted removes completed items', () async {
      final TodoItem active = _todoItem(id: 'a', title: 'Active');
      final TodoItem completed = _todoItem(
        id: 'b',
        title: 'Done',
        isCompleted: true,
      );

      await repository.save(active);
      await repository.save(completed);

      await repository.clearCompleted();

      final List<TodoItem> result = await repository.fetchAll();
      expect(result.length, 1);
      expect(result.first.id, 'a');
    });

    test('watchAll emits updates when items change', () async {
      final TodoItem item = _todoItem(id: 'a', title: 'Watch');

      final StreamIterator<List<TodoItem>> iterator = StreamIterator(
        repository.watchAll(),
      );
      addTearDown(iterator.cancel);

      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isEmpty);

      // Ensure the watch subscription is listening before the write.
      final Future<bool> hasUpdate = iterator.moveNext();
      await repository.save(item);

      expect(await hasUpdate, isTrue);
      final List<TodoItem> result = iterator.current;
      expect(result.first.title, 'Watch');
    });

    test(
      'schema migrate salvages valid items from legacy JSON string',
      () async {
        await hiveService.openBoxAndRun<void>(
          'todo_list',
          action: (final box) async {
            final List<Map<String, dynamic>> legacy = <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'ok',
                'title': 'Ok',
                'createdAt': 1704067200000, // 2024-01-01T00:00:00Z
                'updatedAt': '2024-01-02T00:00:00Z',
                'isCompleted': 'false',
                'priority': 'none',
              },
              <String, dynamic>{'id': 'bad'}, // missing required fields
            ];
            await box.put('todos', jsonEncode(legacy));
          },
        );

        final List<TodoItem> items = await repository.fetchAll();
        expect(items, hasLength(1));
        expect(items.single.id, 'ok');

        final box = await repository.getBox();
        expect(box.get('__tmp__todos_migrated'), isNull);
        final Map<dynamic, dynamic>? meta =
            box.get(HiveSchemaMigratorService.metaKeyFingerprints)
                as Map<dynamic, dynamic>?;
        expect(meta, isNotNull);
        expect(meta!.containsKey('todo_list:todos'), isTrue);
      },
    );

    test(
      'schema migrate drops item with unparseable numeric date only',
      () async {
        await hiveService.openBoxAndRun<void>(
          'todo_list',
          action: (final box) async {
            await box.put('todos', <dynamic>[
              <String, dynamic>{
                'id': 'ok',
                'title': 'Ok',
                'createdAt': '2024-01-01T00:00:00Z',
                'updatedAt': '2024-01-02T00:00:00Z',
              },
              <String, dynamic>{
                'id': 'bad-date',
                'title': 'Bad date',
                'createdAt': double.nan,
                'updatedAt': '2024-01-02T00:00:00Z',
              },
            ]);
          },
        );

        final List<TodoItem> items = await repository.fetchAll();

        expect(items, hasLength(1));
        expect(items.single.id, 'ok');
        final box = await repository.getBox();
        final Map<dynamic, dynamic>? meta =
            box.get(HiveSchemaMigratorService.metaKeyFingerprints)
                as Map<dynamic, dynamic>?;
        expect(meta?['todo_list:todos'], isNotNull);
      },
    );

    test('schema migrate is idempotent and clears stale tmp key', () async {
      await hiveService.openBoxAndRun<void>(
        'todo_list',
        action: (final box) async {
          await box.put('__tmp__todos_migrated', <dynamic>['junk']);
          await box.put('todos', <dynamic>[]);
        },
      );

      await repository.fetchAll();
      final box = await repository.getBox();
      expect(box.get('__tmp__todos_migrated'), isNull);

      // Re-run: should still be clean.
      await repository.fetchAll();
      expect(box.get('__tmp__todos_migrated'), isNull);
    });

    test('schema fingerprint not written when migrator throws', () async {
      final HiveTodoRepository throwing = _ThrowingTodoRepository(
        hiveService: hiveService,
      );

      await throwing.fetchAll();

      final box = await throwing.getBox();
      final Map<dynamic, dynamic>? meta =
          box.get(HiveSchemaMigratorService.metaKeyFingerprints)
              as Map<dynamic, dynamic>?;
      expect(meta?['todo_list:todos'], isNull);
    });
  });
}

class _ThrowingTodoRepository extends HiveTodoRepository {
  _ThrowingTodoRepository({required super.hiveService});

  @override
  HiveBoxSchema get schema => const HiveBoxSchema(
    boxName: 'todo_list',
    namespace: 'todo_list:todos',
    fingerprint: 'throwing',
    migrate: _throwingMigrator,
  );

  static Future<void> _throwingMigrator(
    final Box<dynamic> box, {
    required final String? fromFingerprint,
  }) async {
    throw Exception('boom');
  }
}

TodoItem _todoItem({
  required final String id,
  required final String title,
  final String? description,
  final bool isCompleted = false,
  final DateTime? createdAt,
  final DateTime? updatedAt,
}) {
  final DateTime created = createdAt ?? DateTime.utc(2024, 1, 1);
  final DateTime updated = updatedAt ?? created;
  return TodoItem(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    createdAt: created,
    updatedAt: updated,
  );
}
