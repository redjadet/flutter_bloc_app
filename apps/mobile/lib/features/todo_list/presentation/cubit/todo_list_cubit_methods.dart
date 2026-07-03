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
  RequestIdGuard get loadRequestIdGuard;
  int get loadRequestId;
  set loadRequestId(final int value);
  Future<void> refreshPendingSyncCount();

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

    final int maxOrder = _TodoListCubitHelpers.maxOrderValue(state.manualOrder);

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
        lastError: null,
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
        lastError: null,
        selectedItemIds: updatedSelection,
        manualOrder: updatedManualOrder,
      ),
    );
  }

  Future<void> startWatching() async {
    if (isClosed) return;
    final StreamSubscription<List<TodoItem>>? oldSubscription = subscription;
    subscription = null;
    unawaited(cancelRegisteredSubscription(oldSubscription));
    if (isClosed) return;
    subscription = registerSubscription(
      repository.watchAll().listen(
        onItemsUpdated,
        onError: (final Object error, final StackTrace stackTrace) {
          if (isClosed) return;
          emit(
            state.copyWith(
              status: ViewStatus.error,
              lastError: _todoWatchError(error, stackTrace),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadInitial() async {
    if (isClosed || isLoading) return;
    isLoading = true;
    if (stopLoadingIfClosed()) return;
    final int requestId = loadRequestIdGuard.next();
    emit(state.copyWith(status: ViewStatus.loading, lastError: null));
    AppError? latestError;
    await CubitExceptionHandler.executeAsync<List<TodoItem>>(
      operation: repository.fetchAll,
      isAlive: () => !isClosed,
      onAppError: (final appError) {
        if (stopLoadingIfClosed() || !loadRequestIdGuard.isCurrent(requestId)) {
          return;
        }
        latestError = appError;
      },
      onSuccess: (final items) async {
        if (stopLoadingIfClosed() || !loadRequestIdGuard.isCurrent(requestId)) {
          return;
        }
        emit(
          state.copyWith(
            status: ViewStatus.success,
            items: List<TodoItem>.unmodifiable(items),
            lastError: null,
          ),
        );
        try {
          await startWatching();
          await refreshPendingSyncCount();
        } finally {
          isLoading = false;
        }
      },
      onError: (final errorMessage) {
        if (stopLoadingIfClosed() || !loadRequestIdGuard.isCurrent(requestId)) {
          return;
        }
        emit(
          state.copyWith(
            status: ViewStatus.error,
            lastError: latestError ?? UnknownError(message: errorMessage),
          ),
        );
        isLoading = false;
      },
      logContext: 'TodoListCubit.loadInitial',
    );
  }
}
