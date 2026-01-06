import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';

class TodoListViewData {
  const TodoListViewData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.items,
    required this.filteredItems,
    required this.filter,
    required this.hasCompleted,
    required this.searchQuery,
    required this.sortOrder,
    required this.selectedItemIds,
    required this.hasSelectedItems,
    required this.selectedCount,
  });

  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<TodoItem> items;
  final List<TodoItem> filteredItems;
  final TodoFilter filter;
  final bool hasCompleted;
  final String searchQuery;
  final TodoSortOrder sortOrder;
  final Set<String> selectedItemIds;
  final bool hasSelectedItems;
  final int selectedCount;
}
