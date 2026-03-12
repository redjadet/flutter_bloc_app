import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeIntegrationTestHarness);

  setUp(() async {
    await configureIntegrationTestDependencies();
  });

  tearDown(() async {
    await tearDownIntegrationTestDependencies();
  });

  group('Todo list flow', () {
    testWidgets(
      'opens todo list from example, adds a todo and sees it in list',
      (
        final tester,
      ) async {
        await launchTestApp(tester);

        await pumpUntilFound(tester, find.byTooltip('Open example page'));
        await tester.tap(find.byTooltip('Open example page'));
        await pumpUntilFound(tester, find.text('Example Page'));

        await tester.scrollUntilVisible(
          find.text('Todo List Demo'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        final Finder todoListDemoButton = find.text('Todo List Demo');
        await tester.ensureVisible(todoListDemoButton);
        await tester.pumpAndSettle();
        await tester.tap(todoListDemoButton);
        await pumpUntilFound(tester, find.byTooltip('Add todo'));

        expect(find.text('Todo List'), findsWidgets);

        final Finder addTodoButton = find.byTooltip('Add todo');
        await tester.ensureVisible(addTodoButton);
        await tester.pumpAndSettle();
        await tester.tap(addTodoButton);
        await pumpUntilFound(tester, find.text('Save'));

        final Finder titleField = find
            .byWidgetPredicate(
              (final w) => w is TextField || w is CupertinoTextField,
            )
            .first;
        await tester.ensureVisible(titleField);
        await tester.enterText(titleField, 'Integration test todo');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Save'));
        await pumpUntilFound(tester, find.text('Integration test todo'));

        expect(find.text('Integration test todo'), findsWidgets);
      },
    );
  });
}
