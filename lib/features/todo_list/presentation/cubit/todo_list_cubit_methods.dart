part of 'todo_list_cubit.dart';

/// Mixin containing private methods for TodoListCubit.
mixin _TodoListCubitMethods
    on Cubit<TodoListState>, CubitSubscriptionMixin<TodoListState> {
  TodoRepository get repository;
  StreamSubscription<List<TodoItem>>? get subscription;
  set subscription(final StreamSubscription<List<TodoItem>>? value);
  bool get isLoading;
  set isLoading(final bool value);

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

  Future<void> saveItem(
    final TodoItem item, {
    required final String logContext,
  }) async {
    final TodoListState previousState = state;
    final List<TodoItem> updatedItems = _TodoListCubitHelpers.upsertInList(
      state.items,
      item,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        items: List<TodoItem>.unmodifiable(updatedItems),
        status: ViewStatus.success,
        errorMessage: null,
      ),
    );
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => repository.upsert(item),
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
}
