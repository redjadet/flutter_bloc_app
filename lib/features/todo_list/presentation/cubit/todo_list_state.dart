import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_list_state.freezed.dart';

enum TodoFilter { all, active, completed }

enum TodoSortOrder {
  dateDesc,
  dateAsc,
  titleAsc,
  titleDesc,
  manual,
}

@freezed
abstract class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default(ViewStatus.initial) final ViewStatus status,
    @Default(<TodoItem>[]) final List<TodoItem> items,
    @Default(TodoFilter.all) final TodoFilter filter,
    @Default('') final String searchQuery,
    @Default(TodoSortOrder.dateDesc) final TodoSortOrder sortOrder,
    @Default(<String, int>{}) final Map<String, int> manualOrder,
    final String? errorMessage,
  }) = _TodoListState;

  const TodoListState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasItems => items.isNotEmpty;

  List<TodoItem> get filteredItems {
    // Early return if no items
    if (items.isEmpty) {
      return const <TodoItem>[];
    }

    // Apply filter
    List<TodoItem> result = switch (filter) {
      TodoFilter.all => items,
      TodoFilter.active =>
        items.where((final item) => !item.isCompleted).toList(growable: false),
      TodoFilter.completed =>
        items.where((final item) => item.isCompleted).toList(growable: false),
    };

    // Early return if filter resulted in empty list
    if (result.isEmpty) {
      return const <TodoItem>[];
    }

    // Apply search query if present
    if (searchQuery.isNotEmpty) {
      final String query = searchQuery.toLowerCase();
      result = result
          .where(
            (final item) =>
                item.title.toLowerCase().contains(query) ||
                (item.description?.toLowerCase().contains(query) ?? false),
          )
          .toList(growable: false);

      // Early return if search resulted in empty list
      if (result.isEmpty) {
        return const <TodoItem>[];
      }
    }

    // Apply sorting
    return _applySorting(result);
  }

  List<TodoItem> _applySorting(final List<TodoItem> items) {
    final List<TodoItem> sorted = List<TodoItem>.from(items);

    switch (sortOrder) {
      case TodoSortOrder.dateDesc:
        sorted.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case TodoSortOrder.dateAsc:
        sorted.sort((final a, final b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case TodoSortOrder.titleAsc:
        sorted.sort(
          (final a, final b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case TodoSortOrder.titleDesc:
        sorted.sort(
          (final a, final b) =>
              b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case TodoSortOrder.manual:
        sorted.sort((final a, final b) {
          final int orderA = manualOrder[a.id] ?? 0;
          final int orderB = manualOrder[b.id] ?? 0;
          if (orderA != orderB) {
            return orderA.compareTo(orderB);
          }
          // Fallback to date desc if order not set
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }

    return List<TodoItem>.unmodifiable(sorted);
  }

  bool get hasCompleted => items.any((final item) => item.isCompleted);
}
