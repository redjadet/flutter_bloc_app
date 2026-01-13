import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

/// Additional tests for TodoListCubit to improve coverage
/// These tests cover methods that may not be fully tested in the main test file
void main() {
  group('TodoListCubit Additional Tests', () {
    late _FakeTodoRepository repository;
    late FakeTimerService timerService;

    TodoListCubit buildCubit({final List<TodoItem>? initialItems}) {
      repository = _FakeTodoRepository(initialItems: initialItems);
      addTearDown(repository.dispose);
      timerService = FakeTimerService();
      return TodoListCubit(repository: repository, timerService: timerService);
    }

    blocTest<TodoListCubit, TodoListState>(
      'setSortOrder updates the sort order',
      build: () => buildCubit(),
      seed: () => const TodoListState(
        status: ViewStatus.success,
        items: [],
        sortOrder: TodoSortOrder.dateDesc,
      ),
      act: (final cubit) => cubit.setSortOrder(TodoSortOrder.titleAsc),
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.sortOrder,
          'sortOrder',
          TodoSortOrder.titleAsc,
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'setSortOrder is a no-op when sort order is unchanged',
      build: () => buildCubit(),
      seed: () => const TodoListState(
        status: ViewStatus.success,
        items: [],
        sortOrder: TodoSortOrder.dateDesc,
      ),
      act: (final cubit) => cubit.setSortOrder(TodoSortOrder.dateDesc),
      expect: () => <TodoListState>[],
    );

    blocTest<TodoListCubit, TodoListState>(
      'setSearchQuery updates query immediately when empty',
      build: () => buildCubit(),
      seed: () => const TodoListState(
        status: ViewStatus.success,
        items: [],
        searchQuery: 'old query',
      ),
      act: (final cubit) => cubit.setSearchQuery(''),
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.searchQuery,
          'searchQuery',
          '',
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'setSearchQuery debounces non-empty queries',
      build: () => buildCubit(),
      seed: () => const TodoListState(
        status: ViewStatus.success,
        items: [],
        searchQuery: '',
      ),
      act: (final cubit) {
        cubit.setSearchQuery('test');
        timerService.elapse(const Duration(milliseconds: 300));
      },
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.searchQuery,
          'searchQuery',
          'test',
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'setSearchQuery trims whitespace',
      build: () => buildCubit(),
      seed: () => const TodoListState(
        status: ViewStatus.success,
        items: [],
        searchQuery: '',
      ),
      act: (final cubit) {
        cubit.setSearchQuery('  test  ');
        timerService.elapse(const Duration(milliseconds: 300));
      },
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.searchQuery,
          'searchQuery',
          'test',
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'toggleItemSelection adds item to selection',
      build: () => buildCubit(
        initialItems: [
          _todoItem(id: 'a', title: 'Task A'),
          _todoItem(id: 'b', title: 'Task B'),
        ],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [
          _todoItem(id: 'a', title: 'Task A'),
          _todoItem(id: 'b', title: 'Task B'),
        ],
        selectedItemIds: {},
      ),
      act: (final cubit) => cubit.toggleItemSelection('a'),
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.selectedItemIds.contains('a'),
          'selectedItemIds contains a',
          isTrue,
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'toggleItemSelection removes item from selection',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Task A')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Task A')],
        selectedItemIds: {'a'},
      ),
      act: (final cubit) => cubit.toggleItemSelection('a'),
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.selectedItemIds.contains('a'),
          'selectedItemIds contains a',
          isFalse,
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'toggleItemSelection does nothing for non-existent item',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Task A')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Task A')],
        selectedItemIds: {},
      ),
      act: (final cubit) => cubit.toggleItemSelection('non_existent'),
      expect: () => <TodoListState>[],
    );

    blocTest<TodoListCubit, TodoListState>(
      'selectAllItems selects all filtered items',
      build: () => buildCubit(
        initialItems: [
          _todoItem(id: 'a', title: 'Task A'),
          _todoItem(id: 'b', title: 'Task B'),
        ],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [
          _todoItem(id: 'a', title: 'Task A'),
          _todoItem(id: 'b', title: 'Task B'),
        ],
        selectedItemIds: {},
        filter: TodoFilter.all,
      ),
      act: (final cubit) => cubit.selectAllItems(),
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.selectedItemIds.length,
          'selectedItemIds length',
          2,
        ),
      ],
      verify: (final cubit) {
        expect(cubit.state.selectedItemIds, {'a', 'b'});
      },
    );

    blocTest<TodoListCubit, TodoListState>(
      'selectAllItems only selects filtered items',
      build: () => buildCubit(
        initialItems: [
          _todoItem(id: 'a', title: 'Task A', isCompleted: false),
          _todoItem(id: 'b', title: 'Task B', isCompleted: true),
        ],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [
          _todoItem(id: 'a', title: 'Task A', isCompleted: false),
          _todoItem(id: 'b', title: 'Task B', isCompleted: true),
        ],
        selectedItemIds: {},
        filter: TodoFilter.active,
      ),
      act: (final cubit) => cubit.selectAllItems(),
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.selectedItemIds.length,
          'selectedItemIds length',
          1,
        ),
      ],
      verify: (final cubit) {
        expect(cubit.state.selectedItemIds, {'a'});
      },
    );

    blocTest<TodoListCubit, TodoListState>(
      'clearSelection clears all selected items',
      build: () => buildCubit(),
      seed: () => const TodoListState(
        status: ViewStatus.success,
        items: [],
        selectedItemIds: {'a', 'b', 'c'},
      ),
      act: (final cubit) => cubit.clearSelection(),
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.selectedItemIds.isEmpty,
          'selectedItemIds isEmpty',
          isTrue,
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'batchDeleteSelected removes selected items',
      build: () => buildCubit(
        initialItems: [
          _todoItem(id: 'a', title: 'Task A'),
          _todoItem(id: 'b', title: 'Task B'),
          _todoItem(id: 'c', title: 'Task C'),
        ],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [
          _todoItem(id: 'a', title: 'Task A'),
          _todoItem(id: 'b', title: 'Task B'),
          _todoItem(id: 'c', title: 'Task C'),
        ],
        selectedItemIds: {'a', 'b'},
      ),
      act: (final cubit) async {
        await cubit.batchDeleteSelected();
      },
      expect: () => [
        // First delete (item 'a') - state with items [b, c], selection trimmed to {b}
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 2)
            .having((final s) => s.selectedItemIds, 'selectedItemIds', {'b'}),
        // Second delete (item 'b') - state with items [c], selection cleared
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 1)
            .having((final s) => s.items.first.id, 'remaining id', 'c')
            .having(
              (final s) => s.selectedItemIds.isEmpty,
              'selectedItemIds isEmpty',
              isTrue,
            ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'batchCompleteSelected completes selected active items',
      build: () => buildCubit(
        initialItems: [
          _todoItem(id: 'a', title: 'Task A', isCompleted: false),
          _todoItem(id: 'b', title: 'Task B', isCompleted: false),
          _todoItem(id: 'c', title: 'Task C', isCompleted: true),
        ],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [
          _todoItem(id: 'a', title: 'Task A', isCompleted: false),
          _todoItem(id: 'b', title: 'Task B', isCompleted: false),
          _todoItem(id: 'c', title: 'Task C', isCompleted: true),
        ],
        selectedItemIds: {'a', 'b', 'c'},
      ),
      act: (final cubit) async {
        await cubit.batchCompleteSelected();
      },
      expect: () => [
        // First toggle (item 'a') - 'a' completed, 'b' and 'c' unchanged, selection still {a, b, c}
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 3)
            .having(
              (final s) =>
                  s.items.where((final item) => item.isCompleted).length,
              'completed count',
              2,
            )
            .having((final s) => s.selectedItemIds, 'selectedItemIds', {
              'a',
              'b',
              'c',
            }),
        // Second toggle (item 'b') - 'a' and 'b' completed, 'c' unchanged, selection still {a, b, c}
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 3)
            .having(
              (final s) =>
                  s.items.where((final item) => item.isCompleted).length,
              'completed count',
              3,
            )
            .having((final s) => s.selectedItemIds, 'selectedItemIds', {
              'a',
              'b',
              'c',
            }),
        // Final state - selection cleared
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 3)
            .having(
              (final s) =>
                  s.items.where((final item) => item.isCompleted).length,
              'completed count',
              3,
            )
            .having(
              (final s) => s.selectedItemIds.isEmpty,
              'selectedItemIds isEmpty',
              isTrue,
            ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'batchUncompleteSelected uncompletes selected completed items',
      build: () => buildCubit(
        initialItems: [
          _todoItem(id: 'a', title: 'Task A', isCompleted: true),
          _todoItem(id: 'b', title: 'Task B', isCompleted: true),
          _todoItem(id: 'c', title: 'Task C', isCompleted: false),
        ],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [
          _todoItem(id: 'a', title: 'Task A', isCompleted: true),
          _todoItem(id: 'b', title: 'Task B', isCompleted: true),
          _todoItem(id: 'c', title: 'Task C', isCompleted: false),
        ],
        selectedItemIds: {'a', 'b', 'c'},
      ),
      act: (final cubit) async {
        await cubit.batchUncompleteSelected();
      },
      expect: () => [
        // First toggle (item 'a') - 'a' uncompleted, 'b' and 'c' unchanged, selection still {a, b, c}
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 3)
            .having(
              (final s) =>
                  s.items.where((final item) => item.isCompleted).length,
              'completed count',
              1,
            )
            .having((final s) => s.selectedItemIds, 'selectedItemIds', {
              'a',
              'b',
              'c',
            }),
        // Second toggle (item 'b') - 'a' and 'b' uncompleted, 'c' unchanged, selection still {a, b, c}
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 3)
            .having(
              (final s) =>
                  s.items.where((final item) => item.isCompleted).length,
              'completed count',
              0,
            )
            .having((final s) => s.selectedItemIds, 'selectedItemIds', {
              'a',
              'b',
              'c',
            }),
        // Final state - selection cleared
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 3)
            .having(
              (final s) =>
                  s.items.where((final item) => item.isCompleted).length,
              'completed count',
              0,
            )
            .having(
              (final s) => s.selectedItemIds.isEmpty,
              'selectedItemIds isEmpty',
              isTrue,
            ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'undoDelete restores last deleted item',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Task A')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Task A')],
        selectedItemIds: {},
      ),
      act: (final cubit) async {
        await cubit.deleteTodo(_todoItem(id: 'a', title: 'Task A'));
        await cubit.undoDelete();
      },
      expect: () => [
        // deleteTodo emits state with empty items
        isA<TodoListState>().having(
          (final s) => s.items.isEmpty,
          'items isEmpty',
          isTrue,
        ),
        // undoDelete restores the item
        isA<TodoListState>().having(
          (final s) => s.items.length,
          'items length',
          greaterThan(0),
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'undoDelete is a no-op when no item was deleted',
      build: () => buildCubit(),
      seed: () => const TodoListState(
        status: ViewStatus.success,
        items: [],
        selectedItemIds: {},
      ),
      act: (final cubit) async {
        await cubit.undoDelete();
      },
      expect: () => <TodoListState>[],
    );

    blocTest<TodoListCubit, TodoListState>(
      'batchDeleteSelected is a no-op when no items selected',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Task A')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Task A')],
        selectedItemIds: {},
      ),
      act: (final cubit) async {
        await cubit.batchDeleteSelected();
      },
      expect: () => <TodoListState>[],
    );

    test('refresh calls loadInitial', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadInitial();
      final initialCount = cubit.state.items.length;

      await repository.save(_todoItem(id: 'new', title: 'New Task'));
      await Future<void>.delayed(Duration.zero);

      await cubit.refresh();
      final refreshedCount = cubit.state.items.length;

      expect(refreshedCount, greaterThan(initialCount));
    });
  });
}

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository({final List<TodoItem>? initialItems})
    : _items = List<TodoItem>.from(initialItems ?? <TodoItem>[]) {
    _controller = StreamController<List<TodoItem>>.broadcast(
      onListen: _emitCurrent,
    );
  }

  final List<TodoItem> _items;
  late final StreamController<List<TodoItem>> _controller;

  @override
  Stream<List<TodoItem>> watchAll() => _controller.stream;

  @override
  Future<List<TodoItem>> fetchAll() async => _snapshot();

  @override
  Future<void> save(final TodoItem item) async {
    final int index = _items.indexWhere(
      (final current) => current.id == item.id,
    );
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    _emitCurrent();
  }

  @override
  Future<void> delete(final String id) async {
    _items.removeWhere((final item) => item.id == id);
    _emitCurrent();
  }

  @override
  Future<void> clearCompleted() async {
    _items.removeWhere((final item) => item.isCompleted);
    _emitCurrent();
  }

  List<TodoItem> _snapshot() => List<TodoItem>.unmodifiable(_items);

  void _emitCurrent() {
    scheduleMicrotask(() {
      if (_controller.isClosed) {
        return;
      }
      _controller.add(_snapshot());
    });
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

TodoItem _todoItem({
  required final String id,
  required final String title,
  final bool isCompleted = false,
}) {
  final DateTime now = DateTime.utc(2024, 1, 1, 10);
  return TodoItem(
    id: id,
    title: title,
    description: null,
    isCompleted: isCompleted,
    createdAt: now,
    updatedAt: now,
  );
}
