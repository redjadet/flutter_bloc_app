import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/pages/todo_list_page.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_list_content.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_search_field.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_stats_widget.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/memory/leak_safe_test_widgets.dart';
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

/// Controllable repo for ViewStatusSwitcher loading / error / retry proof.
class _ControllableTodoRepository
    with TodoRepositoryNoPendingSync
    implements TodoRepository {
  _ControllableTodoRepository({List<TodoItem>? initialItems})
    : _items = List<TodoItem>.from(initialItems ?? <TodoItem>[]) {
    _controller = StreamController<List<TodoItem>>.broadcast(
      onListen: _emitCurrent,
    );
  }

  final List<TodoItem> _items;
  late final StreamController<List<TodoItem>> _controller;
  Completer<List<TodoItem>>? pendingFetch;
  Object? nextFetchError;
  int fetchCount = 0;

  @override
  Stream<List<TodoItem>> watchAll() => _controller.stream;

  @override
  Future<List<TodoItem>> fetchAll() async {
    fetchCount += 1;
    final Completer<List<TodoItem>>? pending = pendingFetch;
    if (pending != null) {
      return pending.future;
    }
    final Object? error = nextFetchError;
    if (error != null) {
      nextFetchError = null;
      throw error;
    }
    return _snapshot();
  }

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
    final Completer<List<TodoItem>>? pending = pendingFetch;
    if (pending != null && !pending.isCompleted) {
      pending.complete(_snapshot());
    }
    await _controller.close();
  }
}

TodoItem _todoItem({
  required String id,
  required String title,
  bool isCompleted = false,
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
    late TodoRepository repository;
    late TodoListCubit cubit;
    _FakeTodoRepository? ownedFake;
    _ControllableTodoRepository? ownedControllable;

    Widget buildSubject({
      List<TodoItem>? initialItems,
      TodoRepository? repositoryOverride,
    }) {
      if (repositoryOverride != null) {
        repository = repositoryOverride;
        ownedFake = null;
      } else {
        ownedControllable = null;
        ownedFake = _FakeTodoRepository(initialItems: initialItems);
        repository = ownedFake!;
      }
      cubit = TodoListCubit(
        repository: repository,
        timerService: FakeTimerService(),
      );

      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
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
      await ownedFake?.dispose();
      await ownedControllable?.dispose();
    });

    leakSafeTestWidgets(
      'TodoListPage controller ownership teardown is leak-safe',
      (tester) async {
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = const Size(1083, 1800);

        await tester.pumpWidget(
          buildSubject(
            initialItems: <TodoItem>[
              _todoItem(id: '1', title: 'Leak owner 1'),
              _todoItem(id: '2', title: 'Leak owner 2'),
            ],
          ),
        );

        await cubit.loadInitial();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();

        expect(find.byType(TodoListPage), findsOneWidget);
        expect(find.byType(TodoListContent), findsOneWidget);
        final TodoListContent listContent = tester.widget<TodoListContent>(
          find.byType(TodoListContent),
        );
        expect(listContent.scrollController.hasClients, isTrue);
        expect(
          find.byKey(const ValueKey<String>('todo_search_field')),
          findsOneWidget,
        );
        expect(find.byType(TodoSearchField), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );

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

    testWidgets('scroll wheel over header scrolls the list (wide web)', (
      tester,
    ) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(2560, 1440);

      final List<TodoItem> items = List<TodoItem>.generate(
        80,
        (i) => _todoItem(id: '${i + 1}', title: 'Todo ${i + 1}'),
      );

      await tester.pumpWidget(buildSubject(initialItems: items));
      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      final Finder scrollableFinder = find.byType(Scrollable);
      final Iterable<ScrollableState> scrollableStates = scrollableFinder
          .evaluate()
          .whereType<StatefulElement>()
          .map((element) => element.state)
          .whereType<ScrollableState>();
      final ScrollableState listScrollable = scrollableStates.firstWhere(
        (s) =>
            s.position.axis == Axis.vertical && s.position.maxScrollExtent > 0,
      );
      final ScrollPosition position = listScrollable.position;
      final double before = position.pixels;

      // Target a header widget so the header's Listener receives the wheel event.
      expect(find.byType(TodoStatsWidget), findsOneWidget);
      final Offset headerCenter = tester.getCenter(
        find.byType(TodoStatsWidget),
      );

      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: headerCenter,
          scrollDelta: const Offset(0, 400),
          kind: PointerDeviceKind.mouse,
        ),
      );
      await tester.pump();

      expect(position.pixels, greaterThan(before));
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
      // Force compact remaining height while keyboard is visible to ensure
      // search field does not get removed and drop focus.
      tester.view.viewInsets = const FakeViewPadding(bottom: 520);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);

      editableState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      expect(editableState.widget.focusNode.hasFocus, isTrue);
    });

    testWidgets(
      'keeps search focus when stats section hides after keyboard opens',
      (tester) async {
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.view.resetViewInsets();
        });
        tester.view.devicePixelRatio = 3;
        // 390 x 844 logical points (iPhone-like tall screen).
        tester.view.physicalSize = const Size(1170, 2532);

        await tester.pumpWidget(
          buildSubject(
            initialItems: <TodoItem>[
              _todoItem(id: '1', title: 'Focus test'),
              _todoItem(id: '2', title: 'Focus test 2'),
            ],
          ),
        );

        cubit.loadInitial();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();

        expect(find.byType(TodoStatsWidget), findsOneWidget);

        final Finder searchField = find.byType(TextField);
        final Finder searchWidgetByKey = find.byKey(
          const ValueKey<String>('todo_search_field'),
        );
        expect(searchField, findsOneWidget);
        final State<StatefulWidget> searchStateBefore = tester.state(
          searchWidgetByKey,
        );
        await tester.tap(searchField);
        await tester.pump();

        EditableTextState editableState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        expect(editableState.widget.focusNode.hasFocus, isTrue);

        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(TextField), findsOneWidget);
        final State<StatefulWidget> searchStateAfter = tester.state(
          searchWidgetByKey,
        );
        expect(identical(searchStateBefore, searchStateAfter), isTrue);

        editableState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        expect(editableState.widget.focusNode.hasFocus, isTrue);
      },
    );

    testWidgets(
      'keeps search focus in landscape when keyboard insets transiently clear',
      (tester) async {
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.view.resetViewInsets();
        });
        tester.view.devicePixelRatio = 3;
        // 844 x 390 logical points (iPhone landscape).
        tester.view.physicalSize = const Size(2532, 1170);

        await tester.pumpWidget(
          buildSubject(
            initialItems: <TodoItem>[
              _todoItem(id: '1', title: 'Landscape focus test'),
              _todoItem(id: '2', title: 'Landscape focus test 2'),
            ],
          ),
        );

        cubit.loadInitial();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();

        final Finder searchField = find.byType(TextField);
        final Finder searchWidgetByKey = find.byKey(
          const ValueKey<String>('todo_search_field'),
        );
        expect(searchField, findsOneWidget);

        await tester.tap(searchField);
        await tester.pump();
        await tester.enterText(searchField, 'a');
        await tester.pump(const Duration(milliseconds: 50));

        EditableTextState editableState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        expect(editableState.widget.focusNode.hasFocus, isTrue);
        final State<StatefulWidget> searchStateBefore = tester.state(
          searchWidgetByKey,
        );

        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        await tester.pump();
        tester.view.viewInsets = const FakeViewPadding(bottom: 0);
        await tester.pump();
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(TextField), findsOneWidget);
        final State<StatefulWidget> searchStateAfter = tester.state(
          searchWidgetByKey,
        );
        expect(identical(searchStateBefore, searchStateAfter), isTrue);

        editableState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        expect(editableState.widget.focusNode.hasFocus, isTrue);
      },
    );

    testWidgets(
      'does not overflow with iPhone-like fractional constraints and keyboard',
      (tester) async {
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.view.resetViewInsets();
        });
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = const Size(1082.4, 1784.8);

        await tester.pumpWidget(
          buildSubject(
            initialItems: <TodoItem>[
              _todoItem(id: '1', title: 'Overflow test'),
              _todoItem(id: '2', title: 'Overflow test 2'),
            ],
          ),
        );

        cubit.loadInitial();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();

        tester.view.viewInsets = const FakeViewPadding(bottom: 301.2);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsNothing);
      },
    );

    testWidgets('does not overflow on short-height wide layout', (
      tester,
    ) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(1639.6, 649.6); // 819.8 x 324.8

      await tester.pumpWidget(
        buildSubject(
          initialItems: <TodoItem>[
            _todoItem(id: '1', title: 'Short layout 1'),
            _todoItem(id: '2', title: 'Short layout 2'),
          ],
        ),
      );

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('keeps at least one todo item visible on wide desktop web', (
      tester,
    ) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(2560, 1440);

      await tester.pumpWidget(
        buildSubject(
          initialItems: <TodoItem>[
            _todoItem(id: '1', title: 'Wide desktop visible todo'),
          ],
        ),
      );

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final Finder todoTitle = find.text('Wide desktop visible todo');
      expect(todoTitle, findsOneWidget);

      final Rect todoRect = tester.getRect(todoTitle);
      expect(todoRect.bottom, greaterThan(0));
      expect(todoRect.top, lessThan(1440));
    });

    testWidgets('keeps at least one todo item visible on iPhone-sized layout', (
      tester,
    ) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 3;
      // 390 x 844 logical points.
      tester.view.physicalSize = const Size(1170, 2532);

      await tester.pumpWidget(
        buildSubject(
          initialItems: <TodoItem>[
            _todoItem(id: '1', title: 'Mobile visible todo'),
          ],
        ),
      );

      cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final Finder todoTitle = find.text('Mobile visible todo');
      expect(todoTitle, findsOneWidget);

      final Rect todoRect = tester.getRect(todoTitle);
      expect(todoRect.bottom, greaterThan(0));
      expect(todoRect.top, lessThan(844));
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

    testWidgets('ViewStatusSwitcher shows loading then ready content', (
      tester,
    ) async {
      ownedControllable = _ControllableTodoRepository(
        initialItems: <TodoItem>[_todoItem(id: '1', title: 'Ready item')],
      );
      final Completer<List<TodoItem>> pending = Completer<List<TodoItem>>();
      ownedControllable!.pendingFetch = pending;

      await tester.pumpWidget(
        buildSubject(repositoryOverride: ownedControllable),
      );
      unawaited(cubit.loadInitial());
      await tester.pump();

      expect(find.byType(CommonLoadingWidget), findsOneWidget);
      expect(find.byType(TodoListContent), findsNothing);

      pending.complete(<TodoItem>[_todoItem(id: '1', title: 'Ready item')]);
      ownedControllable!.pendingFetch = null;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byType(CommonLoadingWidget), findsNothing);
      expect(find.byType(TodoListContent), findsOneWidget);
      expect(find.text('Ready item'), findsOneWidget);
    });

    testWidgets('ViewStatusSwitcher shows error with retry and recovers', (
      tester,
    ) async {
      ownedControllable = _ControllableTodoRepository(
        initialItems: <TodoItem>[_todoItem(id: '1', title: 'Recovered')],
      );
      ownedControllable!.nextFetchError = Exception('load failed');

      await tester.pumpWidget(
        buildSubject(repositoryOverride: ownedControllable),
      );
      await cubit.loadInitial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CommonErrorView), findsOneWidget);
      expect(find.byType(CommonRetryButton), findsOneWidget);
      expect(find.text(AppLocalizationsEn().retryButtonLabel), findsOneWidget);

      await tester.tap(find.byType(CommonRetryButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byType(CommonErrorView), findsNothing);
      expect(find.byType(TodoListContent), findsOneWidget);
      expect(find.text('Recovered'), findsOneWidget);
      expect(ownedControllable!.fetchCount, greaterThanOrEqualTo(2));
    });
  });
}
