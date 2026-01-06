part of 'todo_list_cubit.dart';

/// Mixin extension for CRUD operations on TodoListCubit.
mixin _TodoListCubitCrud on _TodoListCubitMethods {
  Future<void> saveItem(
    final TodoItem item, {
    required final String logContext,
  }) async {
    final TodoListState previousState = state;
    final List<TodoItem> updatedItems = _TodoListCubitHelpers.saveInList(
      state.items,
      item,
    );
    if (isClosed) return;

    // If in manual sort mode and item is new, add it to the end of manual order
    Map<String, int> updatedManualOrder = state.manualOrder;
    if (state.sortOrder == TodoSortOrder.manual &&
        !state.items.any((final existing) => existing.id == item.id)) {
      updatedManualOrder = Map<String, int>.from(state.manualOrder);
      final int maxOrder = updatedManualOrder.values.isEmpty
          ? -1
          : updatedManualOrder.values.reduce(
              (final a, final b) => a > b ? a : b,
            );
      updatedManualOrder[item.id] = maxOrder + 1;
    }

    emit(
      state.copyWith(
        items: List<TodoItem>.unmodifiable(updatedItems),
        status: ViewStatus.success,
        errorMessage: null,
        manualOrder: updatedManualOrder,
      ),
    );
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => repository.save(item),
      onError: (final String errorMessage) {
        if (isClosed) return;
        emit(
          previousState.copyWith(
            status: ViewStatus.error,
            errorMessage: errorMessage,
          ),
        );
      },
      logContext: logContext,
    );
  }

  Future<void> addTodo({
    required final String title,
    final String? description,
    final DateTime? dueDate,
    final TodoPriority priority = TodoPriority.none,
  }) async {
    if (isClosed) return;
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }
    final TodoItem item = TodoItem.create(
      title: trimmedTitle,
      description: description?.trim().isEmpty ?? true
          ? null
          : description!.trim(),
      dueDate: dueDate,
      priority: priority,
    );
    await saveItem(item, logContext: 'TodoListCubit.addTodo');
  }

  Future<void> updateTodo({
    required final TodoItem item,
    required final String title,
    final String? description,
    final DateTime? dueDate,
    final TodoPriority? priority,
  }) async {
    if (isClosed) return;
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }
    final String? trimmedDescription = description?.trim();
    final TodoItem updated = item.copyWith(
      title: trimmedTitle,
      description: trimmedDescription == null || trimmedDescription.isEmpty
          ? null
          : trimmedDescription,
      dueDate: dueDate?.toUtc(),
      priority: priority ?? item.priority,
      updatedAt: DateTime.now().toUtc(),
    );
    await saveItem(updated, logContext: 'TodoListCubit.updateTodo');
  }

  Future<void> toggleTodo(final TodoItem item) async {
    if (isClosed) return;
    final TodoItem updated = item.copyWith(
      isCompleted: !item.isCompleted,
      updatedAt: DateTime.now().toUtc(),
    );
    await saveItem(updated, logContext: 'TodoListCubit.toggleTodo');
  }

  Future<void> deleteTodo(final TodoItem item) async {
    if (isClosed ||
        state.items.every((final current) => current.id != item.id)) {
      return;
    }
    lastDeletedItem = item;
    final TodoListState previousState = state;
    final List<TodoItem> updatedItems = state.items
        .where((final current) => current.id != item.id)
        .toList(growable: false);
    emitOptimisticUpdate(updatedItems);
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => repository.delete(item.id),
      onError: (final String errorMessage) {
        if (isClosed) return;
        lastDeletedItem = null;
        emit(
          previousState.copyWith(
            status: ViewStatus.error,
            errorMessage: errorMessage,
          ),
        );
      },
      logContext: 'TodoListCubit.deleteTodo',
    );
  }

  Future<void> clearCompleted() async {
    if (isClosed || !state.items.any((final item) => item.isCompleted)) {
      return;
    }
    final TodoListState previousState = state;
    final List<TodoItem> updatedItems = state.items
        .where((final item) => !item.isCompleted)
        .toList(growable: false);
    emitOptimisticUpdate(updatedItems);
    await CubitExceptionHandler.executeAsyncVoid(
      operation: repository.clearCompleted,
      onError: (final String errorMessage) {
        if (isClosed) return;
        emit(
          previousState.copyWith(
            status: ViewStatus.error,
            errorMessage: errorMessage,
          ),
        );
      },
      logContext: 'TodoListCubit.clearCompleted',
    );
  }
}
