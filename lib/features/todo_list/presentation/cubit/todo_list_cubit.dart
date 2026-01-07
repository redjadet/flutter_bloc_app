import 'dart:async';

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

  final TimerService _timerService;
  final Duration _searchDebounceDuration;
  TimerDisposable? _searchDebounceHandle;
  TodoItem? _lastDeletedItem;

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
    if (isClosed || _lastDeletedItem == null) return;
    final TodoItem item = _lastDeletedItem!;
    _lastDeletedItem = null;
    await saveItem(item, logContext: 'TodoListCubit.undoDelete');
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
    if (isClosed || state.selectedItemIds.isEmpty) return;
    // Capture current state to avoid race conditions
    final Set<String> selectedIds = Set<String>.from(state.selectedItemIds);
    final List<TodoItem> itemsToDelete = state.items
        .where((final item) => selectedIds.contains(item.id))
        .toList();
    for (final TodoItem item in itemsToDelete) {
      if (isClosed) return;
      // Verify item still exists before deleting
      if (state.items.any((final current) => current.id == item.id)) {
        await deleteTodo(item);
      }
    }
    if (isClosed) return;
    emit(state.copyWith(selectedItemIds: const <String>{}));
  }

  Future<void> batchCompleteSelected() async {
    if (isClosed || state.selectedItemIds.isEmpty) return;
    // Capture current state to avoid race conditions
    final Set<String> selectedIds = Set<String>.from(state.selectedItemIds);
    final List<TodoItem> itemsToComplete = state.items
        .where(
          (final item) => selectedIds.contains(item.id) && !item.isCompleted,
        )
        .toList();
    for (final TodoItem item in itemsToComplete) {
      if (isClosed) return;
      // Verify item still exists and matches condition before toggling
      final List<TodoItem> matchingItems = state.items
          .where((final current) => current.id == item.id)
          .toList();
      if (matchingItems.isNotEmpty) {
        final TodoItem currentItem = matchingItems.first;
        if (!currentItem.isCompleted) {
          await toggleTodo(currentItem);
        }
      }
    }
    if (isClosed) return;
    emit(state.copyWith(selectedItemIds: const <String>{}));
  }

  Future<void> batchUncompleteSelected() async {
    if (isClosed || state.selectedItemIds.isEmpty) return;
    // Capture current state to avoid race conditions
    final Set<String> selectedIds = Set<String>.from(state.selectedItemIds);
    final List<TodoItem> itemsToUncomplete = state.items
        .where(
          (final item) => selectedIds.contains(item.id) && item.isCompleted,
        )
        .toList();
    for (final TodoItem item in itemsToUncomplete) {
      if (isClosed) return;
      // Verify item still exists and matches condition before toggling
      final List<TodoItem> matchingItems = state.items
          .where((final current) => current.id == item.id)
          .toList();
      if (matchingItems.isNotEmpty) {
        final TodoItem currentItem = matchingItems.first;
        if (currentItem.isCompleted) {
          await toggleTodo(currentItem);
        }
      }
    }
    if (isClosed) return;
    emit(state.copyWith(selectedItemIds: const <String>{}));
  }

  @override
  Future<void> close() async {
    _cancelSearchDebounce();
    isLoading = false;
    await closeAllSubscriptions();
    subscription = null;
    return super.close();
  }
}
