import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

TodoItem _item({
  required final String id,
  required final String title,
  final bool completed = false,
  final String? description,
  final DateTime? dueDate,
  final TodoPriority priority = TodoPriority.none,
  final DateTime? updatedAt,
}) {
  final DateTime stamp = updatedAt ?? DateTime.utc(2026, 1, 1);
  return TodoItem(
    id: id,
    title: title,
    description: description,
    isCompleted: completed,
    dueDate: dueDate,
    priority: priority,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

void main() {
  test('filteredItems empty when no items', () {
    expect(const TodoListState().filteredItems, isEmpty);
  });

  test('filters active/completed and search', () {
    final TodoListState state = TodoListState(
      items: <TodoItem>[
        _item(id: '1', title: 'Buy milk'),
        _item(id: '2', title: 'Walk dog', completed: true),
        _item(id: '3', title: 'Read', description: 'milk notes'),
      ],
      filter: TodoFilter.active,
      searchQuery: 'milk',
    );

    expect(state.filteredItems.map((final e) => e.id).toList(), <String>[
      '1',
      '3',
    ]);
    expect(
      state
          .copyWith(filter: TodoFilter.completed, searchQuery: '')
          .filteredItems
          .single
          .id,
      '2',
    );
  });

  test('sorts by title, priority, due date, date, and manual order', () {
    final List<TodoItem> items = <TodoItem>[
      _item(
        id: 'a',
        title: 'B',
        priority: TodoPriority.low,
        dueDate: DateTime.utc(2026, 2, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
      _item(
        id: 'b',
        title: 'A',
        priority: TodoPriority.high,
        dueDate: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 3),
      ),
      _item(
        id: 'c',
        title: 'C',
        priority: TodoPriority.medium,
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    ];

    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.titleAsc,
      ).filteredItems.map((final e) => e.id),
      <String>['b', 'a', 'c'],
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.titleDesc,
      ).filteredItems.map((final e) => e.id),
      <String>['c', 'a', 'b'],
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.dateDesc,
      ).filteredItems.first.id,
      'b',
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.dateAsc,
      ).filteredItems.first.id,
      'c',
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.priorityDesc,
      ).filteredItems.first.id,
      'b',
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.priorityAsc,
      ).filteredItems.first.id,
      'a',
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.dueDateAsc,
      ).filteredItems.first.id,
      'b',
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.dueDateDesc,
      ).filteredItems.first.id,
      'a',
    );
    expect(
      TodoListState(
        items: items,
        sortOrder: TodoSortOrder.manual,
        manualOrder: const <String, int>{'c': 0, 'a': 1, 'b': 2},
      ).filteredItems.map((final e) => e.id),
      <String>['c', 'a', 'b'],
    );
  });

  test('selection and counts helpers', () {
    final TodoListState state = TodoListState(
      items: <TodoItem>[
        _item(id: '1', title: 'a'),
        _item(id: '2', title: 'b', completed: true),
      ],
      selectedItemIds: const <String>{'1'},
    );

    expect(state.hasItems, isTrue);
    expect(state.hasCompleted, isTrue);
    expect(state.completedCount, 1);
    expect(state.activeCount, 1);
    expect(state.hasSelectedItems, isTrue);
    expect(state.isItemSelected('1'), isTrue);
    expect(state.selectedCount, 1);
  });
}
