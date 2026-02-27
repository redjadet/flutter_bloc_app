import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'todo_list_cubit_crud.dart';
part 'todo_list_cubit_helpers.dart';
part 'todo_list_cubit_logging.dart';
part 'todo_list_cubit_methods.dart';

class TodoListCubit extends Cubit<TodoListState>
    with
        CubitSubscriptionMixin<TodoListState>,
        _TodoListCubitMethods,
        _TodoListCubitCrud {
  TodoListCubit({
    required this.repository,
    required final TimerService timerService,
    final Duration searchDebounceDuration = const Duration(milliseconds: 300),
  }) : _timerService = timerService,
       _searchDebounceDuration = searchDebounceDuration,
       super(const TodoListState());
  @override
  final TodoRepository repository;
  @override
  // ignore: cancel_subscriptions - Subscription is managed by CubitSubscriptionMixin
  StreamSubscription<List<TodoItem>>? subscription;
  @override
  bool isLoading = false;
  @override
  TimerService get timerService => _timerService;
  @override
  Duration get searchDebounceDuration => _searchDebounceDuration;
  @override
  TimerDisposable? get searchDebounceHandle => _searchDebounceHandle;
  @override
  set searchDebounceHandle(final TimerDisposable? value) =>
      _searchDebounceHandle = value;
  @override
  TodoItem? get lastDeletedItem => _lastDeletedItem;
  @override
  set lastDeletedItem(final TodoItem? value) => _lastDeletedItem = value;
  @override
  bool Function() get stopLoadingIfClosed => _stopLoadingIfClosed;
  @override
  int get loadRequestId => _loadRequestId;
  @override
  set loadRequestId(final int value) => _loadRequestId = value;

  final TimerService _timerService;
  final Duration _searchDebounceDuration;
  TimerDisposable? _searchDebounceHandle;
  TodoItem? _lastDeletedItem;
  int _loadRequestId = 0;

  bool _stopLoadingIfClosed() {
    if (isClosed) {
      isLoading = false;
      return true;
    }
    return false;
  }

  Future<void> refresh() async {
    if (isClosed || isLoading) return;
    await loadInitial();
  }

  void setFilter(final TodoFilter filter) {
    if (isClosed || filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  void setSearchQuery(final String query) {
    if (isClosed) return;
    _cancelSearchDebounce();
    final String trimmedQuery = query.trim();

    // If query is empty, update immediately
    if (trimmedQuery.isEmpty) {
      emit(state.copyWith(searchQuery: ''));
      return;
    }

    // Debounce the search query update
    _searchDebounceHandle = _timerService.runOnce(
      _searchDebounceDuration,
      () {
        if (isClosed) return;
        emit(state.copyWith(searchQuery: trimmedQuery));
      },
    );
  }

  void _cancelSearchDebounce() {
    _searchDebounceHandle?.dispose();
    _searchDebounceHandle = null;
  }

  void setSortOrder(final TodoSortOrder sortOrder) {
    if (isClosed || sortOrder == state.sortOrder) return;
    emit(state.copyWith(sortOrder: sortOrder));
  }

  Future<void> undoDelete() async {
    if (isClosed) return;
    if (_lastDeletedItem case final item?) {
      _lastDeletedItem = null;
      await saveItem(item, logContext: 'TodoListCubit.undoDelete');
    }
  }

  void toggleItemSelection(final String itemId) {
    if (isClosed) return;
    // Verify item exists before allowing selection
    if (!state.items.any((final item) => item.id == itemId)) {
      return;
    }
    final Set<String> updated = Set<String>.from(state.selectedItemIds);
    if (updated.contains(itemId)) {
      updated.remove(itemId);
    } else {
      updated.add(itemId);
    }
    emit(state.copyWith(selectedItemIds: updated));
  }

  void selectAllItems() {
    if (isClosed) return;
    final Set<String> allIds = state.filteredItems
        .map((final item) => item.id)
        .toSet();
    emit(state.copyWith(selectedItemIds: allIds));
  }

  void clearSelection() {
    if (isClosed) return;
    emit(state.copyWith(selectedItemIds: const <String>{}));
  }

  Future<void> batchDeleteSelected() async {
    await _applyToSelectedItems(
      shouldProcess: (_) => true,
      action: deleteTodo,
    );
  }

  Future<void> batchCompleteSelected() async {
    await _applyToSelectedItems(
      shouldProcess: (final item) => !item.isCompleted,
      action: toggleTodo,
    );
  }

  Future<void> batchUncompleteSelected() async {
    await _applyToSelectedItems(
      shouldProcess: (final item) => item.isCompleted,
      action: toggleTodo,
    );
  }

  TodoItem? _findItemById(final String id) =>
      state.items.firstWhereOrNull((final item) => item.id == id);

  Future<void> _applyToSelectedItems({
    required final bool Function(TodoItem item) shouldProcess,
    required final Future<void> Function(TodoItem item) action,
  }) async {
    if (isClosed || state.selectedItemIds.isEmpty) return;
    // Copy selection to avoid race conditions while iterating.
    final Set<String> selectedIds = Set<String>.from(state.selectedItemIds);
    for (final String id in selectedIds) {
      if (isClosed) return;
      final TodoItem? currentItem = _findItemById(id);
      if (currentItem == null || !shouldProcess(currentItem)) {
        continue;
      }
      await action(currentItem);
    }
    if (isClosed) return;
    emit(state.copyWith(selectedItemIds: const <String>{}));
  }

  @override
  Future<void> close() async {
    _cancelSearchDebounce();
    isLoading = false;
    subscription = null;
    return super.close();
  }
}
