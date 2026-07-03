import 'package:collection/collection.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:meta/meta.dart';

@immutable
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

  factory TodoListViewData.fromState(final TodoListState state) =>
      TodoListViewData(
        isLoading: state.isLoading,
        hasError: state.hasError,
        errorMessage: state.errorMessage,
        items: state.items,
        filteredItems: state.filteredItems,
        filter: state.filter,
        hasCompleted: state.hasCompleted,
        searchQuery: state.searchQuery,
        sortOrder: state.sortOrder,
        selectedItemIds: state.selectedItemIds,
        hasSelectedItems: state.hasSelectedItems,
        selectedCount: state.selectedCount,
      );

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

  static const DeepCollectionEquality _collectionEq = DeepCollectionEquality();

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TodoListViewData &&
          other.isLoading == isLoading &&
          other.hasError == hasError &&
          other.errorMessage == errorMessage &&
          _collectionEq.equals(other.items, items) &&
          _collectionEq.equals(other.filteredItems, filteredItems) &&
          other.filter == filter &&
          other.hasCompleted == hasCompleted &&
          other.searchQuery == searchQuery &&
          other.sortOrder == sortOrder &&
          _collectionEq.equals(other.selectedItemIds, selectedItemIds) &&
          other.hasSelectedItems == hasSelectedItems &&
          other.selectedCount == selectedCount;

  @override
  int get hashCode => Object.hash(
    isLoading,
    hasError,
    errorMessage,
    _collectionEq.hash(items),
    _collectionEq.hash(filteredItems),
    filter,
    hasCompleted,
    searchQuery,
    sortOrder,
    _collectionEq.hash(selectedItemIds),
    hasSelectedItems,
    selectedCount,
  );
}
