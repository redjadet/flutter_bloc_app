import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'todo_list_cubit_helpers.dart';
part 'todo_list_cubit_logging.dart';
part 'todo_list_cubit_methods.dart';

class TodoListCubit extends Cubit<TodoListState>
    with CubitSubscriptionMixin<TodoListState>, _TodoListCubitMethods {
  TodoListCubit({required this.repository}) : super(const TodoListState());
  @override
  final TodoRepository repository;
  @override
  // ignore: cancel_subscriptions - Subscription is managed by CubitSubscriptionMixin
  StreamSubscription<List<TodoItem>>? subscription;
  @override
  bool isLoading = false;
  TodoItem? _lastDeletedItem;

  bool _stopLoadingIfClosed() {
    if (isClosed) {
      isLoading = false;
      return true;
    }
    return false;
  }

  Future<void> loadInitial() async {
    if (isClosed || isLoading) return;
    isLoading = true;
    if (_stopLoadingIfClosed()) return;
    emit(state.copyWith(status: ViewStatus.loading, errorMessage: null));
    await CubitExceptionHandler.executeAsync<List<TodoItem>>(
      operation: repository.fetchAll,
      onSuccess: (final items) async {
        if (_stopLoadingIfClosed()) return;
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
        if (_stopLoadingIfClosed()) return;
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

  void setFilter(final TodoFilter filter) {
    if (isClosed || filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  void setSearchQuery(final String query) {
    if (isClosed) return;
    emit(state.copyWith(searchQuery: query.trim()));
  }

  void setSortOrder(final TodoSortOrder sortOrder) {
    if (isClosed || sortOrder == state.sortOrder) return;
    emit(state.copyWith(sortOrder: sortOrder));
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

  Future<void> addTodo({
    required final String title,
    final String? description,
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
    );
    await saveItem(item, logContext: 'TodoListCubit.addTodo');
  }

  Future<void> updateTodo({
    required final TodoItem item,
    required final String title,
    final String? description,
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
    _lastDeletedItem = item;
    final TodoListState previousState = state;
    final List<TodoItem> updatedItems = state.items
        .where((final current) => current.id != item.id)
        .toList(growable: false);
    emitOptimisticUpdate(updatedItems);
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => repository.delete(item.id),
      onError: (final String errorMessage) {
        if (isClosed) return;
        _lastDeletedItem = null;
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

  Future<void> undoDelete() async {
    if (isClosed || _lastDeletedItem == null) return;
    final TodoItem item = _lastDeletedItem!;
    _lastDeletedItem = null;
    await saveItem(item, logContext: 'TodoListCubit.undoDelete');
  }

  TodoItem? get lastDeletedItem => _lastDeletedItem;

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

  @override
  Future<void> close() async {
    isLoading = false;
    await closeAllSubscriptions();
    subscription = null;
    return super.close();
  }
}
