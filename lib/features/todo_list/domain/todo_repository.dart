import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';

abstract class TodoRepository {
  Stream<List<TodoItem>> watchAll();

  Future<List<TodoItem>> fetchAll();

  Future<void> save(final TodoItem item);

  Future<void> delete(final String id);

  Future<void> clearCompleted();
}
