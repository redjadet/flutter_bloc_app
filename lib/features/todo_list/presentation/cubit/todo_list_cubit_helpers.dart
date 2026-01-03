part of 'todo_list_cubit.dart';

/// Helper functions for TodoListCubit list operations.
class _TodoListCubitHelpers {
  _TodoListCubitHelpers._();

  /// saves an item into a list, maintaining sort order by updatedAt descending.
  static List<TodoItem> saveInList(
    final List<TodoItem> items,
    final TodoItem item,
  ) {
    final List<TodoItem> updated = List<TodoItem>.from(items);
    final int index = updated.indexWhere(
      (final current) => current.id == item.id,
    );
    if (index == -1) {
      updated.add(item);
    } else {
      updated[index] = item;
    }
    // Sort by updatedAt descending (most recent first)
    updated.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
    return updated;
  }
}
