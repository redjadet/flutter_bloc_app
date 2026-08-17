part of 'todo_list_cubit.dart';

/// Mixin extension for CRUD operations on TodoListCubit.
mixin _TodoListCubitCrud on _TodoListCubitMethods {
  Future<void> saveItem(
    TodoItem item, {
    required String logContext,
  }) async {
    if (isClosed) return;
    final TodoListState previousState = state;
    final bool itemExists = state.items.any(
      (existing) => existing.id == item.id,
    );
    final List<TodoItem> updatedItems = _TodoListCubitHelpers.saveInList(
      state.items,
      item,
    );
    if (isClosed) return;

    // If in manual sort mode and item is new, add it to the end of manual order
    Map<String, int> updatedManualOrder = state.manualOrder;
    if (state.sortOrder == TodoSortOrder.manual && !itemExists) {
      updatedManualOrder = Map<String, int>.from(state.manualOrder);
      final int maxOrder = _TodoListCubitHelpers.maxOrderValue(
        updatedManualOrder,
      );
      updatedManualOrder[item.id] = maxOrder + 1;
    }

    emit(
      state.copyWith(
        items: List<TodoItem>.unmodifiable(updatedItems),
        status: ViewStatus.success,
        lastError: null,
        manualOrder: updatedManualOrder,
      ),
    );
    AppError? latestError;
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => repository.save(item),
      isAlive: () => !isClosed,
      onAppError: (appError) => latestError = appError,
      onSuccess: () => unawaited(refreshPendingSyncCount()),
      onError: (errorMessage) {
        if (isClosed) return;
        emit(
          previousState.copyWith(
            status: ViewStatus.error,
            lastError: latestError ?? UnknownError(message: errorMessage),
          ),
        );
      },
      logContext: logContext,
    );
  }

  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    TodoPriority priority = TodoPriority.none,
  }) async {
    if (isClosed) return;
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }
    final TodoItem item = TodoItem.create(
      title: trimmedTitle,
      description: switch (description) {
        final d? when d.trim().isNotEmpty => d.trim(),
        _ => null,
      },
      dueDate: dueDate,
      priority: priority,
    );
    await saveItem(item, logContext: 'TodoListCubit.addTodo');
  }

  Future<void> updateTodo({
    required TodoItem item,
    required String title,
    String? description,
    DateTime? dueDate,
    TodoPriority? priority,
    bool? isCompleted,
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
      isCompleted: isCompleted ?? item.isCompleted,
      updatedAt: DateTime.now().toUtc(),
    );
    await saveItem(updated, logContext: 'TodoListCubit.updateTodo');
  }

  Future<void> toggleTodo(TodoItem item) async {
    if (isClosed) return;
    final TodoItem updated = item.copyWith(
      isCompleted: !item.isCompleted,
      updatedAt: DateTime.now().toUtc(),
    );
    await saveItem(updated, logContext: 'TodoListCubit.toggleTodo');
  }

  Future<void> deleteTodo(TodoItem item) async {
    if (isClosed || state.items.every((current) => current.id != item.id)) {
      return;
    }
    lastDeletedItem = item;
    final TodoListState previousState = state;
    final List<TodoItem> updatedItems = state.items
        .where((current) => current.id != item.id)
        .toList(growable: false);
    emitOptimisticUpdate(updatedItems);
    AppError? latestError;
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => repository.delete(item.id),
      isAlive: () => !isClosed,
      onAppError: (appError) => latestError = appError,
      onSuccess: () => unawaited(refreshPendingSyncCount()),
      onError: (errorMessage) {
        if (isClosed) return;
        lastDeletedItem = null;
        emit(
          previousState.copyWith(
            status: ViewStatus.error,
            lastError: latestError ?? UnknownError(message: errorMessage),
          ),
        );
      },
      logContext: 'TodoListCubit.deleteTodo',
    );
  }

  Future<void> clearCompleted() async {
    if (isClosed || !state.items.any((item) => item.isCompleted)) {
      return;
    }
    final TodoListState previousState = state;
    final List<TodoItem> updatedItems = state.items
        .where((item) => !item.isCompleted)
        .toList(growable: false);
    emitOptimisticUpdate(updatedItems);
    AppError? latestError;
    await CubitExceptionHandler.executeAsyncVoid(
      operation: repository.clearCompleted,
      isAlive: () => !isClosed,
      onAppError: (appError) => latestError = appError,
      onSuccess: () => unawaited(refreshPendingSyncCount()),
      onError: (errorMessage) {
        if (isClosed) return;
        emit(
          previousState.copyWith(
            status: ViewStatus.error,
            lastError: latestError ?? UnknownError(message: errorMessage),
          ),
        );
      },
      logContext: 'TodoListCubit.clearCompleted',
    );
  }
}
