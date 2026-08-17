part of 'todo_list_cubit.dart';

/// Helper functions for TodoListCubit list operations.
class _TodoListCubitHelpers {
  _TodoListCubitHelpers._();

  /// Returns the maximum value in [order], or -1 if empty.
  static int maxOrderValue(Map<String, int> order) =>
      order.values.fold(-1, (currentMax, value) {
        if (value > currentMax) {
          return value;
        }
        return currentMax;
      });

  /// saves an item into a list, maintaining sort order by updatedAt descending.
  static List<TodoItem> saveInList(
    List<TodoItem> items,
    TodoItem item,
  ) {
    final List<TodoItem> updated = List<TodoItem>.from(items);
    final int index = updated.indexWhere(
      (current) => current.id == item.id,
    );
    if (index == -1) {
      updated.add(item);
    } else {
      updated[index] = item;
    }
    // Sort by updatedAt descending (most recent first)
    updated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return updated;
  }
}
