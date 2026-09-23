import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/widgets/todo_search_field.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../test_helpers.dart';

class _FakeTodoRepository
    with TodoRepositoryNoPendingSync
    implements TodoRepository {
  @override
  Future<void> clearCompleted() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<TodoItem>> fetchAll() async => const <TodoItem>[];

  @override
  Future<void> save(TodoItem item) async {}

  @override
  Stream<List<TodoItem>> watchAll() => const Stream<List<TodoItem>>.empty();
}

void main() {
  group('TodoSearchField', () {
    late TodoListCubit cubit;
    late FakeTimerService timerService;

    setUp(() {
      timerService = FakeTimerService();
      cubit = TodoListCubit(
        repository: _FakeTodoRepository(),
        timerService: timerService,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    Future<void> pumpField(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<TodoListCubit>.value(
              value: cubit,
              child: const TodoSearchField(),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    void applySearchDebounce() {
      timerService.elapse(const Duration(milliseconds: 300));
    }

    testWidgets('initializes text from existing cubit searchQuery', (
      WidgetTester tester,
    ) async {
      cubit.setSearchQuery('prefilled');
      applySearchDebounce();
      await pumpField(tester);

      expect(find.text('prefilled'), findsOneWidget);
      final TextField field = tester.widget(find.byType(TextField));
      expect(field.controller?.text, 'prefilled');
    });

    testWidgets('mirrors programmatic nonempty query changes', (
      WidgetTester tester,
    ) async {
      await pumpField(tester);

      cubit.setSearchQuery('from-cubit');
      applySearchDebounce();
      await tester.pump();

      expect(find.text('from-cubit'), findsOneWidget);
      final TextField field = tester.widget(find.byType(TextField));
      expect(field.controller?.text, 'from-cubit');
    });

    testWidgets('clears when cubit searchQuery becomes empty', (
      WidgetTester tester,
    ) async {
      cubit.setSearchQuery('keep');
      applySearchDebounce();
      await pumpField(tester);
      expect(find.text('keep'), findsOneWidget);

      cubit.setSearchQuery('');
      await tester.pump();

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.controller?.text, isEmpty);
    });
  });
}
