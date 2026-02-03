import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/todo_list/data/todo_item_dto.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/shared/firebase/auth_helpers.dart';
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
      _debugLog(
        'RealtimeDatabaseTodoRepository.fetchAll requesting todos',
      );
      final DataSnapshot snapshot = await _todoRef.child(user.uid).get();
      _debugLog(
        'RealtimeDatabaseTodoRepository.fetchAll response exists: '
        '${snapshot.exists}',
      );
      return _itemsFromValue(snapshot.value, userId: user.uid);
    },
    onFailureFallback: () async => const <TodoItem>[],
  );

  @override
  Stream<List<TodoItem>> watchAll() => Stream.fromFuture(waitForAuthUser(_auth))
      .asyncExpand(
        (final user) => _todoRef
            .child(user.uid)
            .onValue
            .map(
              (final event) =>
                  _itemsFromValue(event.snapshot.value, userId: user.uid),
            ),
      )
      .handleError((final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'RealtimeDatabaseTodoRepository.watchAll failed',
          error,
          stackTrace,
        );
      });

  @override
  Future<void> save(final TodoItem item) async => _executeForUser<void>(
    operation: 'save',
    action: (final user) async {
      _debugLog(
        'RealtimeDatabaseTodoRepository.save writing todo item',
      );
      final Map<String, dynamic> data = _todoToMap(item, userId: user.uid);
      await _todoRef.child(user.uid).child(item.id).set(data);
    },
    onFailureFallback: () async {},
  );

  @override
  Future<void> delete(final String id) async => _executeForUser<void>(
    operation: 'delete',
    action: (final user) async {
      _debugLog(
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
      _debugLog(
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
  }) async {
    try {
      final User user = await waitForAuthUser(_auth);
      return await action(user);
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeDatabaseTodoRepository.$operation failed',
        error,
        stackTrace,
      );
      if (onFailureFallback != null) {
        return onFailureFallback();
      }
      rethrow;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'RealtimeDatabaseTodoRepository.$operation failed',
        error,
        stackTrace,
      );
      if (onFailureFallback != null) {
        return onFailureFallback();
      }
      rethrow;
    } catch (error, stackTrace) {
      // Catch any other errors (e.g. TypeError from Firebase SDK exception
      // conversion when platform exceptions have unexpected formats)
      AppLogger.error(
        'RealtimeDatabaseTodoRepository.$operation failed with unexpected error',
        error,
        stackTrace,
      );
      if (onFailureFallback != null) {
        return onFailureFallback();
      }
      rethrow;
    }
  }

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
}

void _debugLog(final String message) {
  if (kDebugMode) {
    AppLogger.debug(message);
  }
}
