import 'package:collection/collection.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:meta/meta.dart';

/// Loading / error projection for ViewStatusSwitcher. Ignores selection.
@immutable
class const TodoListLifecycleData({
  required final bool isLoading,
  required final bool hasError,
  required final String? errorMessage,
}) {
  factory TodoListLifecycleData.fromState(TodoListState state) =>
      TodoListLifecycleData(
        isLoading: state.isLoading,
        hasError: state.hasError,
        errorMessage: state.errorMessage,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoListLifecycleData &&
          other.isLoading == isLoading &&
          other.hasError == hasError &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(isLoading, hasError, errorMessage);
}

/// List / filter / sort inputs. Equality ignores selection so selection-only
/// emissions do not rebuild header/list shells. Does not call
/// `TodoListState.filteredItems` in `fromState` — derive in the list builder.
@immutable
class const TodoListListProjection({
  required final List<TodoItem> items,
  required final TodoFilter filter,
  required final String searchQuery,
  required final TodoSortOrder sortOrder,
  required final Map<String, int> manualOrder,
}) {
  factory TodoListListProjection.fromState(TodoListState state) =>
      TodoListListProjection(
        items: state.items,
        filter: state.filter,
        searchQuery: state.searchQuery,
        sortOrder: state.sortOrder,
        manualOrder: state.manualOrder,
      );

  static const DeepCollectionEquality _collectionEq = DeepCollectionEquality();

  /// Derived only when the list projection rebuilds, not on selection emits.
  bool get hasCompleted => items.any((item) => item.isCompleted);

  /// Derive filtered/sorted rows only when this projection rebuilds.
  List<TodoItem> get filteredItems {
    // Reuse cubit state logic via a transient state snapshot of list inputs
    // only — selection is intentionally omitted and unused by filteredItems.
    return TodoListState(
      items: items,
      filter: filter,
      searchQuery: searchQuery,
      sortOrder: sortOrder,
      manualOrder: manualOrder,
    ).filteredItems;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoListListProjection &&
          _collectionEq.equals(other.items, items) &&
          other.filter == filter &&
          other.searchQuery == searchQuery &&
          other.sortOrder == sortOrder &&
          _collectionEq.equals(other.manualOrder, manualOrder);

  @override
  int get hashCode => Object.hash(
    _collectionEq.hash(items),
    filter,
    searchQuery,
    sortOrder,
    _collectionEq.hash(manualOrder),
  );
}

/// Selection-only projection for batch/app-bar/row selection chrome.
@immutable
class const TodoListSelectionData({
  required final Set<String> selectedItemIds,
  required final bool hasSelectedItems,
  required final int selectedCount,
}) {
  factory TodoListSelectionData.fromState(TodoListState state) =>
      TodoListSelectionData(
        selectedItemIds: state.selectedItemIds,
        hasSelectedItems: state.hasSelectedItems,
        selectedCount: state.selectedCount,
      );

  static const DeepCollectionEquality _collectionEq = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoListSelectionData &&
          _collectionEq.equals(other.selectedItemIds, selectedItemIds) &&
          other.hasSelectedItems == hasSelectedItems &&
          other.selectedCount == selectedCount;

  @override
  int get hashCode => Object.hash(
    _collectionEq.hash(selectedItemIds),
    hasSelectedItems,
    selectedCount,
  );
}
