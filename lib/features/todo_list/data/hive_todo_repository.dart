import 'dart:async';

import 'package:flutter_bloc_app/features/todo_list/data/todo_item_dto.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveTodoRepository extends HiveRepositoryBase implements TodoRepository {
  HiveTodoRepository({required super.hiveService});

  static const String _boxName = 'todo_list';
  static const String _keyTodos = 'todos';

  @override
  String get boxName => _boxName;

  @override
  Future<List<TodoItem>> fetchAll() async => StorageGuard.run<List<TodoItem>>(
    logContext: 'HiveTodoRepository.fetchAll',
    action: () async {
      final Box<dynamic> box = await getBox();
      return _loadFromBox(box);
    },
    fallback: () => const <TodoItem>[],
  );

  @override
  Stream<List<TodoItem>> watchAll() => _watchAllStream();

  Stream<List<TodoItem>> _watchAllStream() async* {
    final Box<dynamic> box = await getBox();
    yield await _loadFromBox(box);
    await for (final BoxEvent event in box.watch()) {
      if (event.key == _keyTodos) {
        yield await _loadFromBox(box);
      }
    }
  }

  @override
  Future<void> upsert(final TodoItem item) async => StorageGuard.run<void>(
    logContext: 'HiveTodoRepository.upsert',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<TodoItem> existing = await _loadFromBox(box);
      final List<TodoItem> updated = _upsertItem(existing, item);
      await _save(box, updated);
    },
  );

  @override
  Future<void> delete(final String id) async => StorageGuard.run<void>(
    logContext: 'HiveTodoRepository.delete',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<TodoItem> existing = await _loadFromBox(box);
      final List<TodoItem> updated = existing
          .where((final item) => item.id != id)
          .toList(growable: false);
      await _save(box, updated);
    },
  );

  @override
  Future<void> clearCompleted() async => StorageGuard.run<void>(
    logContext: 'HiveTodoRepository.clearCompleted',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<TodoItem> existing = await _loadFromBox(box);
      final List<TodoItem> updated = existing
          .where((final item) => !item.isCompleted)
          .toList(growable: false);
      await _save(box, updated);
    },
  );

  Future<List<TodoItem>> _loadFromBox(final Box<dynamic> box) async =>
      StorageGuard.run<List<TodoItem>>(
        logContext: 'HiveTodoRepository._loadFromBox',
        action: () async {
          final dynamic raw = box.get(_keyTodos);
          final List<TodoItem> items = await _parseStored(raw);
          return _sortItems(items);
        },
        fallback: () => const <TodoItem>[],
      );

  Future<void> _save(
    final Box<dynamic> box,
    final List<TodoItem> items,
  ) async {
    if (items.isEmpty) {
      await safeDeleteKey(box, _keyTodos);
    } else {
      final List<Map<String, dynamic>> serialized = items
          .map(TodoItemDto.fromDomain)
          .map((final dto) => dto.toMap())
          .toList(growable: false);
      await box.put(_keyTodos, serialized);
    }
    // The box.watch() in watchAll() will automatically emit when _keyTodos changes
  }

  List<TodoItem> _upsertItem(
    final List<TodoItem> existing,
    final TodoItem item,
  ) {
    final List<TodoItem> items = List<TodoItem>.from(existing);
    final int index = items.indexWhere(
      (final current) => current.id == item.id,
    );
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    return _sortItems(items);
  }

  Future<List<TodoItem>> _parseStored(final dynamic raw) async {
    if (raw is String && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = await decodeJsonList(raw);
        return _parseIterable(decoded);
      } on Exception {
        return const <TodoItem>[];
      }
    }

    if (raw is Iterable<dynamic>) {
      return _parseIterable(raw);
    }

    return const <TodoItem>[];
  }

  List<TodoItem> _parseIterable(final Iterable<dynamic> raw) => raw
      .whereType<Map<dynamic, dynamic>>()
      .map(_safeMap)
      .whereType<TodoItemDto>()
      .map((final dto) => dto.toDomain())
      .toList(growable: false);

  TodoItemDto? _safeMap(final Map<dynamic, dynamic> raw) {
    try {
      return TodoItemDto.fromMap(raw);
    } on Exception {
      return null;
    }
  }

  List<TodoItem> _sortItems(final List<TodoItem> items) {
    final List<TodoItem> sorted = List<TodoItem>.from(items)
      ..sort(
        (final a, final b) => b.updatedAt.compareTo(a.updatedAt),
      );
    return List<TodoItem>.unmodifiable(sorted);
  }
}
