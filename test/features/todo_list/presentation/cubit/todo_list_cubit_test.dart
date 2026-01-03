import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoListCubit', () {
    late _FakeTodoRepository repository;

    TodoListCubit buildCubit({final List<TodoItem>? initialItems}) {
      repository = _FakeTodoRepository(initialItems: initialItems);
      addTearDown(repository.dispose);
      return TodoListCubit(repository: repository);
    }

    blocTest<TodoListCubit, TodoListState>(
      'loadInitial emits loading then success states',
      build: () => buildCubit(),
      act: (final cubit) async {
        await cubit.loadInitial();
      },
      expect: () => [
        _hasStatus(ViewStatus.loading),
        _hasStatus(ViewStatus.success),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'addTodo emits updated list',
      build: () => buildCubit(),
      seed: () => const TodoListState(status: ViewStatus.success, items: []),
      act: (final cubit) async {
        await cubit.addTodo(title: 'Write tests', description: '');
      },
      expect: () => [
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 1)
            .having((final s) => s.items.first.title, 'title', 'Write tests'),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'toggleTodo flips completion state',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Task')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Task')],
      ),
      act: (final cubit) async {
        await cubit.toggleTodo(cubit.state.items.first);
      },
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.items.first.isCompleted,
          'isCompleted',
          true,
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'updateTodo updates title',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Old')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Old')],
      ),
      act: (final cubit) async {
        await cubit.updateTodo(
          item: cubit.state.items.first,
          title: 'New',
          description: null,
        );
      },
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.items.first.title,
          'title',
          'New',
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'deleteTodo removes item',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Task')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Task')],
      ),
      act: (final cubit) async {
        await cubit.deleteTodo(cubit.state.items.first);
      },
      expect: () => [
        isA<TodoListState>().having((final s) => s.items, 'items', isEmpty),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'clearCompleted removes completed items',
      build: () => buildCubit(
        initialItems: [
          _todoItem(id: 'a', title: 'Active'),
          _todoItem(id: 'b', title: 'Done', isCompleted: true),
        ],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [
          _todoItem(id: 'a', title: 'Active'),
          _todoItem(id: 'b', title: 'Done', isCompleted: true),
        ],
      ),
      act: (final cubit) async {
        await cubit.clearCompleted();
      },
      expect: () => [
        isA<TodoListState>()
            .having((final s) => s.items.length, 'items length', 1)
            .having((final s) => s.items.first.id, 'remaining id', 'a'),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'setFilter updates the filter',
      build: () => buildCubit(),
      seed: () => const TodoListState(status: ViewStatus.success, items: []),
      act: (final cubit) {
        cubit.setFilter(TodoFilter.completed);
      },
      expect: () => [
        isA<TodoListState>().having(
          (final s) => s.filter,
          'filter',
          TodoFilter.completed,
        ),
      ],
    );

    blocTest<TodoListCubit, TodoListState>(
      'setFilter is a no-op when filter is unchanged',
      build: () => buildCubit(),
      seed: () => const TodoListState(status: ViewStatus.success, items: []),
      act: (final cubit) {
        cubit.setFilter(TodoFilter.all);
      },
      expect: () => <TodoListState>[],
    );

    blocTest<TodoListCubit, TodoListState>(
      'deleteTodo is a no-op when item is missing',
      build: () => buildCubit(),
      seed: () => const TodoListState(status: ViewStatus.success, items: []),
      act: (final cubit) async {
        await cubit.deleteTodo(_todoItem(id: 'missing', title: 'Missing'));
      },
      expect: () => <TodoListState>[],
    );

    blocTest<TodoListCubit, TodoListState>(
      'clearCompleted is a no-op when there are no completed items',
      build: () => buildCubit(
        initialItems: [_todoItem(id: 'a', title: 'Active')],
      ),
      seed: () => TodoListState(
        status: ViewStatus.success,
        items: [_todoItem(id: 'a', title: 'Active')],
      ),
      act: (final cubit) async {
        await cubit.clearCompleted();
      },
      expect: () => <TodoListState>[],
    );

    test('addTodo ignores blank titles', () async {
      final TodoListCubit cubit = buildCubit();
      await cubit.addTodo(title: '   ', description: null);

      expect(cubit.state.items, isEmpty);
    });

    test('actions are ignored after cubit is closed', () async {
      final TodoListCubit cubit = buildCubit();
      await cubit.close();

      await cubit.addTodo(title: 'Title', description: null);
      await cubit.updateTodo(
        item: _todoItem(id: 'a', title: 'Old'),
        title: 'New',
        description: null,
      );
      await cubit.toggleTodo(_todoItem(id: 'a', title: 'Task'));
      await cubit.deleteTodo(_todoItem(id: 'a', title: 'Task'));
      await cubit.clearCompleted();
      cubit.setFilter(TodoFilter.completed);

      expect(cubit.isClosed, isTrue);
    });
  });
}

typedef _StatePredicate = bool Function(TodoListState state);

_TodoListStateMatcher _hasStatus(final ViewStatus status) =>
    _TodoListStateMatcher((final state) => state.status == status);

class _TodoListStateMatcher extends Matcher {
  _TodoListStateMatcher(this._predicate);

  final _StatePredicate _predicate;

  @override
  Description describe(final Description description) =>
      description.add('TodoListState with matching status');

  @override
  bool matches(final Object? item, final Map<Object?, Object?> matchState) {
    if (item is! TodoListState) {
      return false;
    }
    return _predicate(item);
  }
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
  Future<void> upsert(final TodoItem item) async {
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
  final DateTime now = DateTime.utc(2024, 1, 1);
  return TodoItem(
    id: id,
    title: title,
    description: null,
    isCompleted: isCompleted,
    createdAt: now,
    updatedAt: now,
  );
}
