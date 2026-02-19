import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc_app/features/todo_list/data/todo_item_dto.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/shared/firebase/run_with_auth_user.dart';
import 'package:flutter_bloc_app/shared/firebase/stream_with_auth_user.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Firebase Realtime Database backed implementation of [TodoRepository].
class RealtimeDatabaseTodoRepository implements TodoRepository {
  RealtimeDatabaseTodoRepository({
    final FirebaseDatabase? database,
    final DatabaseReference? todoRef,
    final FirebaseAuth? auth,
    final String todoPath = _defaultTodoPath,
  }) : _todoRef =
           todoRef ?? (database ?? FirebaseDatabase.instance).ref(todoPath),
       _auth = auth ?? FirebaseAuth.instance;

  static const String _defaultTodoPath = 'todos';

  final DatabaseReference _todoRef;
  final FirebaseAuth _auth;

  @override
  Future<List<TodoItem>> fetchAll() async => _executeForUser<List<TodoItem>>(
    operation: 'fetchAll',
    action: (final user) async {
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseTodoRepository.fetchAll requesting todos',
      );
      final DataSnapshot snapshot = await _todoRef.child(user.uid).get();
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseTodoRepository.fetchAll response exists: '
        '${snapshot.exists}',
      );
      return _itemsFromValue(snapshot.value, userId: user.uid);
    },
    onFailureFallback: () async => const <TodoItem>[],
  );

  @override
  Stream<List<TodoItem>> watchAll() => streamWithAuthUser<List<TodoItem>>(
    auth: _auth,
    logContext: 'RealtimeDatabaseTodoRepository.watchAll',
    streamPerUser: (final user) => _todoRef
        .child(user.uid)
        .onValue
        .map(
          (final event) =>
              _itemsFromValue(event.snapshot.value, userId: user.uid),
        ),
  );

  @override
  Future<void> save(final TodoItem item) async => _executeForUser<void>(
    operation: 'save',
    action: (final user) async {
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseTodoRepository.save writing todo item',
      );
      final Map<String, dynamic> data = _todoToMap(item, userId: user.uid);
      // Use Map<String, Object?> to ensure JSON-safe types for platform channel.
      // FlutterFire may mishandle non-primitive values; explicit copy avoids issues.
      final Map<String, Object?> jsonSafe = data.map(
        (final k, final v) => MapEntry(k, v as Object?),
      );
      await _setTodoWithPlatformErrorGuard(
        userId: user.uid,
        todoId: item.id,
        data: jsonSafe,
      );
    },
    onFailureFallback: () async {},
  );

  @override
  Future<void> delete(final String id) async => _executeForUser<void>(
    operation: 'delete',
    action: (final user) async {
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseTodoRepository.delete removing todo item',
      );
      await _todoRef.child(user.uid).child(id).remove();
    },
    onFailureFallback: () async {},
  );

  @override
  Future<void> clearCompleted() async => _executeForUser<void>(
    operation: 'clearCompleted',
    action: (final user) async {
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseTodoRepository.clearCompleted removing completed todos',
      );
      final DataSnapshot snapshot = await _todoRef.child(user.uid).get();
      if (!snapshot.exists || snapshot.value == null) {
        return;
      }
      final List<TodoItem> items = _itemsFromValue(
        snapshot.value,
        userId: user.uid,
      );
      final List<TodoItem> completedItems = items
          .where((final item) => item.isCompleted)
          .toList(growable: false);
      if (completedItems.isEmpty) {
        return;
      }
      final Map<String, Object?> updates = <String, Object?>{};
      for (final TodoItem item in completedItems) {
        updates['${user.uid}/${item.id}'] = null;
      }
      await _todoRef.update(updates);
    },
    onFailureFallback: () async {},
  );

  Future<T> _executeForUser<T>({
    required final String operation,
    required final Future<T> Function(User user) action,
    final Future<T> Function()? onFailureFallback,
  }) => runWithAuthUser<T>(
    auth: _auth,
    logContext: 'RealtimeDatabaseTodoRepository.$operation',
    action: action,
    onFailureFallback: onFailureFallback,
  );

  List<TodoItem> _itemsFromValue(
    final Object? value, {
    required final String userId,
  }) {
    if (value == null) {
      return const <TodoItem>[];
    }
    if (value is! Map) {
      AppLogger.warning(
        'RealtimeDatabaseTodoRepository._itemsFromValue unexpected payload type: '
        '${value.runtimeType}',
      );
      return const <TodoItem>[];
    }
    final Map<Object?, Object?> data = Map<Object?, Object?>.from(value);
    final List<TodoItem> items = <TodoItem>[];
    for (final MapEntry<Object?, Object?> entry in data.entries) {
      if (entry.value is! Map) {
        continue;
      }
      try {
        final Map<dynamic, dynamic> itemMap = Map<dynamic, dynamic>.from(
          entry.value! as Map,
        );
        final Object? rawId = itemMap['id'];
        if (rawId == null || (rawId is String && rawId.trim().isEmpty)) {
          itemMap['id'] = entry.key?.toString();
        }
        final TodoItemDto dto = TodoItemDto.fromMap(itemMap);
        items.add(dto.toDomain());
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'RealtimeDatabaseTodoRepository._itemsFromValue failed to parse item: '
          '${entry.key}',
          error,
          stackTrace,
        );
      }
    }
    return _sortItems(items);
  }

  Map<String, dynamic> _todoToMap(
    final TodoItem item, {
    required final String userId,
  }) {
    final Map<String, dynamic> map = TodoItemDto.fromDomain(item).toMap();
    map['userId'] = userId;
    return map;
  }

  List<TodoItem> _sortItems(final List<TodoItem> items) {
    final List<TodoItem> sorted = List<TodoItem>.from(items)
      ..sort(
        (final a, final b) => b.updatedAt.compareTo(a.updatedAt),
      );
    return List<TodoItem>.unmodifiable(sorted);
  }

  Future<void> _setTodoWithPlatformErrorGuard({
    required final String userId,
    required final String todoId,
    required final Map<String, Object?> data,
  }) async {
    try {
      await _todoRef.child(userId).child(todoId).set(data);
    } catch (error, stackTrace) {
      if (error is TypeError) {
        final String errorMessage = error.toString();
        final bool isFlutterFireDetailsCastIssue = errorMessage.contains(
          "'String' is not a subtype of type 'Map",
        );
        if (isFlutterFireDetailsCastIssue) {
          Error.throwWithStackTrace(
            FirebaseException(
              plugin: 'firebase_database',
              code: 'database-platform-error-details',
              message:
                  'Realtime Database write failed while saving todo. '
                  'Check database rules and path keys.',
            ),
            stackTrace,
          );
        }
      }
      rethrow;
    }
  }
}
