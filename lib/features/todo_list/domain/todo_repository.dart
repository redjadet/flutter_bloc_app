import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';

/// Repository contract for todo items: watch, fetch, save, delete, and clear.
abstract class TodoRepository {
  /// Stream of all todo items; emits when the list changes.
  Stream<List<TodoItem>> watchAll();

  /// Fetches all todo items (e.g. from remote or cache).
  Future<List<TodoItem>> fetchAll();

  /// Creates or updates a todo item.
  Future<void> save(final TodoItem item);

  /// Deletes the todo item with the given [id].
  Future<void> delete(final String id);

  /// Removes all completed todo items.
  Future<void> clearCompleted();
}
