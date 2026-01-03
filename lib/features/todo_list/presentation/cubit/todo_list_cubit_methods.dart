part of 'todo_list_cubit.dart';

/// Mixin containing private methods for TodoListCubit.
mixin _TodoListCubitMethods
    on Cubit<TodoListState>, CubitSubscriptionMixin<TodoListState> {
  TodoRepository get repository;
  StreamSubscription<List<TodoItem>>? get subscription;
  set subscription(final StreamSubscription<List<TodoItem>>? value);
  bool get isLoading;
  set isLoading(final bool value);
  TimerService get timerService;
  Duration get searchDebounceDuration;
  TimerDisposable? get searchDebounceHandle;
  set searchDebounceHandle(final TimerDisposable? value);
  TodoItem? get lastDeletedItem;
  set lastDeletedItem(final TodoItem? value);
  bool Function() get stopLoadingIfClosed;

  void emitOptimisticUpdate(final List<TodoItem> items) {
    if (isClosed) return;
    emit(
      state.copyWith(
        items: List<TodoItem>.unmodifiable(items),
        status: ViewStatus.success,
        errorMessage: null,
      ),
    );
  }

  void onItemsUpdated(final List<TodoItem> items) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: ViewStatus.success,
        items: List<TodoItem>.unmodifiable(items),
        errorMessage: null,
      ),
    );
  }

  Future<void> startWatching() async {
    if (isClosed) return;
    final StreamSubscription<List<TodoItem>>? oldSubscription = subscription;
    subscription = null;
    unawaited(oldSubscription?.cancel());
    if (isClosed) return;
    final StreamSubscription<List<TodoItem>> newSubscription = repository
        .watchAll()
        .listen(
          onItemsUpdated,
          onError: (final Object error, final StackTrace stackTrace) {
            if (isClosed) return;
            emit(
              state.copyWith(
                status: ViewStatus.error,
                errorMessage: _todoWatchErrorMessage(error, stackTrace),
              ),
            );
          },
        );
    registerSubscription(newSubscription);
    subscription = newSubscription;
  }

  Future<void> loadInitial() async {
    if (isClosed || isLoading) return;
    isLoading = true;
    if (stopLoadingIfClosed()) return;
    emit(state.copyWith(status: ViewStatus.loading, errorMessage: null));
    await CubitExceptionHandler.executeAsync<List<TodoItem>>(
      operation: repository.fetchAll,
      onSuccess: (final items) async {
        if (stopLoadingIfClosed()) return;
        emit(
          state.copyWith(
            status: ViewStatus.success,
            items: List<TodoItem>.unmodifiable(items),
            errorMessage: null,
          ),
        );
        try {
          await startWatching();
        } finally {
          isLoading = false;
        }
      },
      onError: (final String errorMessage) {
        if (stopLoadingIfClosed()) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: errorMessage,
          ),
        );
        isLoading = false;
      },
      logContext: 'TodoListCubit.loadInitial',
    );
  }

  void reorderItems({
    required final int oldIndex,
    required final int newIndex,
  }) {
    if (isClosed) return;
    if (state.sortOrder != TodoSortOrder.manual) {
      // Switch to manual sort mode
      final Map<String, int> newManualOrder = <String, int>{};
      for (int i = 0; i < state.filteredItems.length; i++) {
        newManualOrder[state.filteredItems[i].id] = i;
      }
      emit(
        state.copyWith(
          sortOrder: TodoSortOrder.manual,
          manualOrder: newManualOrder,
        ),
      );
    }

    final List<TodoItem> items = List<TodoItem>.from(state.filteredItems);
    int adjustedNewIndex = newIndex;
    if (oldIndex < newIndex) {
      adjustedNewIndex -= 1;
    }
    final TodoItem item = items.removeAt(oldIndex);
    items.insert(adjustedNewIndex, item);

    // Update manual order
    final Map<String, int> updatedOrder = Map<String, int>.from(
      state.manualOrder,
    );
    for (int i = 0; i < items.length; i++) {
      updatedOrder[items[i].id] = i;
    }

    emit(state.copyWith(manualOrder: updatedOrder));
  }
}
