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

  Set<String> _trimSelection(final List<TodoItem> items) {
    if (state.selectedItemIds.isEmpty) {
      return state.selectedItemIds;
    }
    final Set<String> itemIds = items.map((final item) => item.id).toSet();
    final Set<String> trimmed = state.selectedItemIds
        .where(itemIds.contains)
        .toSet();
    if (trimmed.length == state.selectedItemIds.length) {
      return state.selectedItemIds;
    }
    return trimmed;
  }

  Map<String, int> _normalizeManualOrder(final List<TodoItem> items) {
    if (items.isEmpty) {
      return const <String, int>{};
    }

    // Calculate max order value for items that have order set
    final int maxOrder = state.manualOrder.values.isEmpty
        ? -1
        : state.manualOrder.values.reduce(
            (final a, final b) => a > b ? a : b,
          );

    final Map<String, int> originalIndex = <String, int>{
      for (int i = 0; i < items.length; i++) items[i].id: i,
    };

    // Sort items according to current manual order to preserve user's ordering
    final List<TodoItem> sortedItems = List<TodoItem>.from(items)
      ..sort((final a, final b) {
        final int orderA = state.manualOrder[a.id] ?? maxOrder + 1;
        final int orderB = state.manualOrder[b.id] ?? maxOrder + 1;
        if (orderA != orderB) {
          return orderA.compareTo(orderB);
        }
        // Fallback to date desc if order not set (for new items)
        final int dateComparison = b.updatedAt.compareTo(a.updatedAt);
        if (dateComparison != 0) {
          return dateComparison;
        }
        final int indexA = originalIndex[a.id] ?? originalIndex.length + 1;
        final int indexB = originalIndex[b.id] ?? originalIndex.length + 1;
        if (indexA != indexB) {
          return indexA.compareTo(indexB);
        }
        return a.id.compareTo(b.id);
      });

    // Reindex sequentially (0, 1, 2, ...) while preserving the sorted order
    final Map<String, int> normalized = <String, int>{};
    for (int i = 0; i < sortedItems.length; i++) {
      normalized[sortedItems[i].id] = i;
    }

    return normalized;
  }

  void emitOptimisticUpdate(final List<TodoItem> items) {
    if (isClosed) return;
    final Set<String> updatedSelection = _trimSelection(items);
    final Map<String, int> updatedManualOrder =
        state.sortOrder == TodoSortOrder.manual
        ? _normalizeManualOrder(items)
        : state.manualOrder;
    emit(
      state.copyWith(
        items: List<TodoItem>.unmodifiable(items),
        status: ViewStatus.success,
        errorMessage: null,
        selectedItemIds: updatedSelection,
        manualOrder: updatedManualOrder,
      ),
    );
  }

  void onItemsUpdated(final List<TodoItem> items) {
    if (isClosed) return;
    final Set<String> updatedSelection = _trimSelection(items);
    final Map<String, int> updatedManualOrder =
        state.sortOrder == TodoSortOrder.manual
        ? _normalizeManualOrder(items)
        : state.manualOrder;
    emit(
      state.copyWith(
        status: ViewStatus.success,
        items: List<TodoItem>.unmodifiable(items),
        errorMessage: null,
        selectedItemIds: updatedSelection,
        manualOrder: updatedManualOrder,
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
    if (state.filter != TodoFilter.all || state.searchQuery.isNotEmpty) {
      // Avoid inconsistent manual ordering while filtered or searching.
      return;
    }
    final List<TodoItem> filteredItems = state.filteredItems;

    // Validate indices
    if (filteredItems.isEmpty ||
        oldIndex < 0 ||
        oldIndex >= filteredItems.length ||
        newIndex < 0 ||
        newIndex >= filteredItems.length) {
      return;
    }

    if (state.sortOrder != TodoSortOrder.manual) {
      // Switch to manual sort mode
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
