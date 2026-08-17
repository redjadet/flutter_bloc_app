import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';

/// Leaf I/O for todo persistence (Hive local or RTDB remote).
///
/// The domain repository facade owns the application-facing contract.
abstract class TodoDataSource {
  Stream<List<TodoItem>> watchAll();
  Future<List<TodoItem>> fetchAll();
  Future<void> save(TodoItem item);
  Future<void> delete(String id);
  Future<void> clearCompleted();
}
