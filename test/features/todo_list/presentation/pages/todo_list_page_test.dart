import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/pages/todo_list_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    await setupTestDependencies();
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  group('TodoListPage', () {
    late _FakeTodoRepository repository;
    late TodoListCubit cubit;

    Widget buildSubject({final List<TodoItem>? initialItems}) {
      repository = _FakeTodoRepository(initialItems: initialItems);
      cubit = TodoListCubit(
        repository: repository,
        timerService: FakeTimerService(),
      );

      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<TodoListCubit>.value(
          value: cubit,
          child: const TodoListPage(),
        ),
      );
    }

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    testWidgets('renders TodoListPage', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Wait for cubit to initialize
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byType(TodoListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('displays page structure', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Verify page is rendered
      expect(find.byType(TodoListPage), findsOneWidget);
      // CommonPageLayout should be present
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('handles empty todo list', (tester) async {
      await tester.pumpWidget(buildSubject(initialItems: []));

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byType(TodoListPage), findsOneWidget);
    });

    testWidgets('handles todo list with items', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          initialItems: [
            _todoItem(id: '1', title: 'Test Todo 1'),
            _todoItem(id: '2', title: 'Test Todo 2'),
          ],
        ),
      );

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byType(TodoListPage), findsOneWidget);
    });

    testWidgets('uses only todo list scrolling when items are present', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          initialItems: [
            _todoItem(id: '1', title: 'Test Todo 1'),
            _todoItem(id: '2', title: 'Test Todo 2'),
          ],
        ),
      );

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('initializes cubit on page load', (tester) async {
      await tester.pumpWidget(buildSubject());

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Verify cubit is accessible and page is rendered
      expect(find.byType(TodoListPage), findsOneWidget);
    });

    testWidgets('keeps search field focus when keyboard insets change', (
      tester,
    ) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1083, 1800);

      await tester.pumpWidget(
        buildSubject(
          initialItems: <TodoItem>[_todoItem(id: '1', title: 'Focus test')],
        ),
      );

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final Finder searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.tap(searchField);
      await tester.pump();

      EditableTextState editableState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      expect(editableState.widget.focusNode.hasFocus, isTrue);

      addTearDown(tester.view.resetViewInsets);
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      editableState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      expect(editableState.widget.focusNode.hasFocus, isTrue);
    });

    testWidgets(
      'delete snackbar auto-dismisses after two seconds with undo action',
      (tester) async {
        final TodoItem item = _todoItem(id: '1', title: 'Delete me');
        await tester.pumpWidget(buildSubject(initialItems: <TodoItem>[item]));

        cubit.loadInitial();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppLocalizationsEn().todoListDeleteAction));
        await tester.pump();

        expect(
          find.text(AppLocalizationsEn().todoListDeleteUndone),
          findsOneWidget,
        );
        expect(
          find.text(AppLocalizationsEn().todoListUndoAction),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(
          find.text(AppLocalizationsEn().todoListDeleteUndone),
          findsNothing,
        );
      },
    );
  });
}
