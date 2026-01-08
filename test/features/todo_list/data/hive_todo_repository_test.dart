import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/features/todo_list/data/hive_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
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
  });
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
