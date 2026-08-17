import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc_app/app/firebase/realtime_database_guard.dart';
import 'package:flutter_bloc_app/app/firebase/run_with_auth_user.dart';
import 'package:flutter_bloc_app/app/firebase/stream_with_auth_user.dart';
import 'package:flutter_bloc_app/features/todo_list/data/todo_item_dto.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

/// Firebase Realtime Database backed leaf [TodoDataSource].
class RealtimeDatabaseTodoRepository implements TodoRepository {
  RealtimeDatabaseTodoRepository({
    FirebaseDatabase? database,
    DatabaseReference? todoRef,
    FirebaseAuth? auth,
    String todoPath = _defaultTodoPath,
  }) : _todoRef =
           todoRef ?? (database ?? FirebaseDatabase.instance).ref(todoPath),
       _auth = auth ?? FirebaseAuth.instance;

  static const String _defaultTodoPath = 'todos';

  final DatabaseReference _todoRef;
  final FirebaseAuth _auth;

  @override
  Future<List<TodoItem>> fetchAll() async => _executeForUser<List<TodoItem>>(
    operation: 'fetchAll',
    action: (user) async {
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
  );

  @override
  Stream<List<TodoItem>> watchAll() => streamWithAuthUser<List<TodoItem>>(
    auth: _auth,
    logContext: IntegrationLogMessages.realtimeDatabaseTodoWatchAllLogContext,
    streamPerUser: (user) => _todoRef
        .child(user.uid)
        .onValue
        .map(
          (event) => _itemsFromValue(event.snapshot.value, userId: user.uid),
        ),
  );

  @override
  Future<void> save(TodoItem item) async => _executeForUser<void>(
    operation: 'save',
    action: (user) async {
      AppLogger.debugInDebugMode(
        'RealtimeDatabaseTodoRepository.save writing todo item',
      );
      final Map<String, dynamic> data = _todoToMap(item, userId: user.uid);
      // Use Map<String, Object?> to ensure JSON-safe types for platform channel.
      // FlutterFire may mishandle non-primitive values; explicit copy avoids issues.
      final Map<String, Object?> jsonSafe = data.map(
        (k, v) => MapEntry(k, v as Object?),
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
  Future<void> delete(String id) async => _executeForUser<void>(
    operation: 'delete',
    action: (user) async {
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
    action: (user) async {
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
          .where((item) => item.isCompleted)
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
    required String operation,
    required Future<T> Function(User user) action,
    Future<T> Function()? onFailureFallback,
  }) => runWithAuthUser<T>(
    auth: _auth,
    logContext: 'RealtimeDatabaseTodoRepository.$operation',
    action: action,
    onFailureFallback: onFailureFallback,
  );

  List<TodoItem> _itemsFromValue(
    Object? value, {
    required String userId,
  }) {
    final List<TodoItem> items = parseMapOfMaps<TodoItem>(
      value,
      logContext: 'RealtimeDatabaseTodoRepository._itemsFromValue',
      parseItem: (key, map) {
        final Object? rawId = map['id'];
        if (rawId == null || (rawId is String && rawId.trim().isEmpty)) {
          map['id'] = key?.toString();
        }
        final TodoItemDto dto = TodoItemDto.fromMap(map);
        return dto.toDomain();
      },
    );
    return _sortItems(items);
  }

  Map<String, dynamic> _todoToMap(
    TodoItem item, {
    required String userId,
  }) {
    final Map<String, dynamic> map = TodoItemDto.fromDomain(item).toMap();
    map['userId'] = userId;
    return map;
  }

  List<TodoItem> _sortItems(List<TodoItem> items) {
    final List<TodoItem> sorted = List<TodoItem>.from(items)
      ..sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );
    return List<TodoItem>.unmodifiable(sorted);
  }

  Future<void> _setTodoWithPlatformErrorGuard({
    required String userId,
    required String todoId,
    required Map<String, Object?> data,
  }) async {
    await guardRealtimeDatabaseWrite(
      () => _todoRef.child(userId).child(todoId).set(data),
      message:
          'Realtime Database write failed while saving todo. '
          'Check database rules and path keys.',
    );
  }
}
