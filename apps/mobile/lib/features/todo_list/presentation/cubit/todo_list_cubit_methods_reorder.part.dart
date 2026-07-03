part of 'todo_list_cubit.dart';

mixin _TodoListCubitMethodsReorder on Cubit<TodoListState> {
  void reorderItems({
    required final int oldIndex,
    required final int newIndex,
  }) {
    if (isClosed) return;
    if (state.filter != TodoFilter.all || state.searchQuery.isNotEmpty) {
      return;
    }
    final List<TodoItem> filteredItems = state.filteredItems;

    if (filteredItems.isEmpty ||
        oldIndex < 0 ||
        oldIndex >= filteredItems.length ||
        newIndex < 0 ||
        newIndex >= filteredItems.length) {
      return;
    }

    if (state.sortOrder != TodoSortOrder.manual) {
      final Map<String, int> newManualOrder = <String, int>{};
      for (int i = 0; i < filteredItems.length; i++) {
        newManualOrder[filteredItems[i].id] = i;
      }
      emit(
        state.copyWith(
          sortOrder: TodoSortOrder.manual,
          manualOrder: newManualOrder,
        ),
      );
    }

    final List<TodoItem> items = List<TodoItem>.from(filteredItems);
    int adjustedNewIndex = newIndex;
    if (oldIndex < newIndex) {
      adjustedNewIndex -= 1;
    }
    final TodoItem item = items.removeAt(oldIndex);
    items.insert(adjustedNewIndex, item);

    final Map<String, int> updatedOrder = Map<String, int>.from(
      state.manualOrder,
    );
    for (int i = 0; i < items.length; i++) {
      updatedOrder[items[i].id] = i;
    }

    emit(state.copyWith(manualOrder: updatedOrder));
  }
}
