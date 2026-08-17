import 'dart:async';
import 'dart:collection';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/pages/todo_list_page_data.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_selectable_item.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../test_helpers.dart';

class _FakeTodoRepository
    with TodoRepositoryNoPendingSync
    implements TodoRepository {
  _FakeTodoRepository({List<TodoItem>? initialItems})
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
  Future<void> save(TodoItem item) async {
    final int index = _items.indexWhere((current) => current.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    _emitCurrent();
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    _emitCurrent();
  }

  @override
  Future<void> clearCompleted() async {
    _items.removeWhere((item) => item.isCompleted);
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

TodoItem _item(int index) {
  final DateTime stamp = DateTime.utc(2026, 1, 1).add(Duration(minutes: index));
  return TodoItem(
    id: 'todo-$index',
    title: 'Todo $index',
    createdAt: stamp,
    updatedAt: stamp,
  );
}

List<TodoItem> _largeList({int count = 120}) =>
    List<TodoItem>.generate(count, _item, growable: false);

class _ReadCountingTodoList extends ListBase<TodoItem> {
  _ReadCountingTodoList(this._items);

  final List<TodoItem> _items;
  int readCount = 0;

  @override
  int get length => _items.length;

  @override
  set length(int value) => throw UnsupportedError('read only');

  @override
  TodoItem operator [](int index) {
    readCount++;
    return _items[index];
  }

  @override
  void operator []=(int index, TodoItem value) =>
      throw UnsupportedError('read only');
}

void main() {
  group('Todo list rebuild isolation', () {
    test('list projection equality ignores selection-only state copies', () {
      final List<TodoItem> items = _largeList();
      final TodoListState base = TodoListState(
        status: ViewStatus.success,
        items: items,
      );
      final TodoListListProjection a = TodoListListProjection.fromState(base);
      final TodoListListProjection b = TodoListListProjection.fromState(
        base.copyWith(selectedItemIds: <String>{'todo-0'}),
      );
      expect(a, equals(b));
      expect(a.filteredItems, hasLength(120));
      expect(
        b.filteredItems.map((i) => i.id),
        a.filteredItems.map((i) => i.id),
      );
    });

    test('list projection defers item scans until list data is consumed', () {
      final _ReadCountingTodoList items = _ReadCountingTodoList(_largeList());
      final TodoListState state = TodoListState(
        status: ViewStatus.success,
        items: items,
      );

      final TodoListListProjection projection =
          TodoListListProjection.fromState(state);

      expect(items.readCount, 0);
      expect(projection.hasCompleted, isFalse);
      expect(items.readCount, 120);
    });

    test('selection projection changes when selection changes', () {
      final TodoListState base = TodoListState(
        status: ViewStatus.success,
        items: _largeList(count: 3),
      );
      final TodoListSelectionData a = TodoListSelectionData.fromState(base);
      final TodoListSelectionData b = TodoListSelectionData.fromState(
        base.copyWith(selectedItemIds: <String>{'todo-0'}),
      );
      expect(a, isNot(equals(b)));
      expect(b.selectedCount, 1);
    });

    testWidgets(
      'list projection selector does not rebuild on selection-only emits',
      (WidgetTester tester) async {
        final List<TodoItem> items = _largeList();
        final _FakeTodoRepository repository = _FakeTodoRepository(
          initialItems: items,
        );
        addTearDown(repository.dispose);
        final TodoListCubit cubit = TodoListCubit(
          repository: repository,
          timerService: FakeTimerService(),
        );
        addTearDown(cubit.close);

        await cubit.loadInitial();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        int listBuildCount = 0;
        int selectionBuildCount = 0;
        List<TodoItem>? capturedFiltered;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<TodoListCubit>.value(
              value: cubit,
              child:
                  TypeSafeBlocSelector<
                    TodoListCubit,
                    TodoListState,
                    TodoListListProjection
                  >(
                    selector: TodoListListProjection.fromState,
                    builder: (context, listData) {
                      listBuildCount++;
                      capturedFiltered = listData.filteredItems;
                      return TypeSafeBlocSelector<
                        TodoListCubit,
                        TodoListState,
                        TodoListSelectionData
                      >(
                        selector: TodoListSelectionData.fromState,
                        builder: (context, selection) {
                          selectionBuildCount++;
                          return Text(
                            'list=${capturedFiltered!.length} '
                            'selected=${selection.selectedCount}',
                          );
                        },
                      );
                    },
                  ),
            ),
          ),
        );
        await tester.pump();
        final int listBuildsAfterMount = listBuildCount;
        final int selectionBuildsAfterMount = selectionBuildCount;
        expect(listBuildsAfterMount, greaterThanOrEqualTo(1));
        expect(selectionBuildsAfterMount, greaterThanOrEqualTo(1));
        expect(capturedFiltered, hasLength(120));

        cubit.toggleItemSelection('todo-0');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          listBuildCount,
          listBuildsAfterMount,
          reason: 'selection-only emit must not rebuild list projection',
        );
        expect(selectionBuildCount, greaterThan(selectionBuildsAfterMount));
        expect(find.text('list=120 selected=1'), findsOneWidget);
      },
    );

    testWidgets('large list keeps stable ValueKey identity for rows', (
      WidgetTester tester,
    ) async {
      final List<TodoItem> items = _largeList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final TodoItem item = items[index];
                return RepaintBoundary(
                  key: ValueKey<String>('todo-${item.id}'),
                  child: Text(item.title),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('todo-todo-0')), findsOneWidget);
      expect(find.text('Todo 0'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('todo-todo-50')),
        200,
      );
      expect(
        find.byKey(const ValueKey<String>('todo-todo-50')),
        findsOneWidget,
      );
    });

    testWidgets('row selector updates the tapped row selection chrome', (
      WidgetTester tester,
    ) async {
      final _FakeTodoRepository repository = _FakeTodoRepository(
        initialItems: _largeList(count: 2),
      );
      addTearDown(repository.dispose);
      final TodoListCubit cubit = TodoListCubit(
        repository: repository,
        timerService: FakeTimerService(),
      );
      addTearDown(cubit.close);
      await cubit.loadInitial();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TodoListCubit>.value(
            value: cubit,
            child: Column(
              children: [
                TodoListSelectableItem(
                  item: _item(0),
                  showDragHandle: false,
                  onItemSelectionChanged: (itemId, {required selected}) =>
                      cubit.toggleItemSelection(itemId),
                  onToggle: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
                TodoListSelectableItem(
                  item: _item(1),
                  showDragHandle: false,
                  onItemSelectionChanged: (itemId, {required selected}) =>
                      cubit.toggleItemSelection(itemId),
                  onToggle: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      expect(cubit.state.selectedItemIds, <String>{'todo-0'});
      expect(find.byType(TodoListSelectableItem), findsNWidgets(2));
      final List<Checkbox> checkboxes = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .toList(growable: false);
      expect(checkboxes.map((checkbox) => checkbox.value), <bool?>[
        true,
        false,
      ]);
    });
  });
}
