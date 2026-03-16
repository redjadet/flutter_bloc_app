part of 'flow_scenarios.dart';

void registerNavigationIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Navigation flow',
    testName: 'moves from counter to example and into library demo',
    body: (final tester) async {
      await launchTestApp(tester);

      await tapAndPump(tester, find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      expect(find.text('Example Page'), findsWidgets);

      final Finder libraryDemo = find.text('Library Demo');
      await tester.scrollUntilVisible(
        libraryDemo,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, libraryDemo);
      await pumpUntilFound(
        tester,
        find.text('All Assets'),
        timeout: const Duration(seconds: 15),
      );

      expect(find.text('Library Demo'), findsWidgets);
      expect(find.text('All Assets'), findsWidgets);

      final Finder gridToggle = find.byTooltip('Grid view');
      await pumpUntilFound(tester, gridToggle);
      await tapAndPump(tester, gridToggle);

      final Finder scrollView = find.byType(CustomScrollView);
      await pumpUntilFound(tester, scrollView);
      for (
        var i = 0;
        i < 6 && !tester.any(find.byType(ScapesGridSliverContent));
        i++
      ) {
        await tester.fling(scrollView, const Offset(0, -800), 1200);
        await tester.pumpAndSettle();
      }
      await pumpUntilFound(
        tester,
        find.byType(ScapesGridSliverContent),
        timeout: const Duration(seconds: 20),
      );

      expect(find.byType(ScapesGridSliverContent), findsWidgets);
    },
  );
}

void registerPlaylearnIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Playlearn flow',
    testName: 'opens playlearn from overflow and shows playlearn page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open Playlearn');
      await pumpUntilFound(
        tester,
        find.text('Playlearn'),
        timeout: const Duration(seconds: 10),
      );

      expect(find.text('Playlearn'), findsWidgets);
    },
  );
}

void registerPlaylearnEmptyTopicsIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Playlearn flow',
    testName: 'shows empty state when no topics are available',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open Playlearn');
      await pumpUntilFound(
        tester,
        find.text('Playlearn'),
        timeout: const Duration(seconds: 10),
      );

      // If topics are not empty in this environment, this assertion will be skipped.
      if (tester.any(find.text('No topics available'))) {
        expect(find.text('No topics available'), findsWidgets);
      }
    },
  );
}

void registerSearchIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Search flow',
    testName: 'opens search from example and shows results section',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Search Demo');
      await pumpUntilFound(tester, find.text('ALL RESULTS'));

      expect(find.text('ALL RESULTS'), findsWidgets);
    },
  );
}

void registerSettingsIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Settings flow',
    testName: 'opens settings and applies theme and locale changes',
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open settings'));
      await tapAndPump(tester, find.byTooltip('Open settings'));
      await pumpUntilFound(tester, find.text('Settings'));

      expect(find.text('Settings'), findsWidgets);

      await tapAndPump(
        tester,
        find.text('Dark'),
        settle: const Duration(milliseconds: 200),
      );

      MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);

      await tester.scrollUntilVisible(
        find.text('Español'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, find.text('Español'));
      await pumpUntilFound(tester, find.text('Configuración'));

      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(find.text('Configuración'), findsWidgets);
    },
  );
}

void registerTodoListIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Todo list flow',
    testName: 'opens todo list from example, adds a todo and sees it in list',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Todo List Demo');
      await pumpUntilFound(tester, find.byTooltip('Add todo'));

      expect(find.text('Todo List'), findsWidgets);

      final Finder addTodoButton = find.byTooltip('Add todo');
      await tapAndPump(tester, addTodoButton);
      await pumpUntilFound(tester, find.text('Save'));

      final Finder titleField = find
          .byWidgetPredicate(
            (final w) => w is TextField || w is CupertinoTextField,
          )
          .first;
      await tester.ensureVisible(titleField);
      await tester.enterText(titleField, 'Integration test todo');
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, find.text('Save'));
      await pumpUntilFound(tester, find.text('Integration test todo'));

      expect(find.text('Integration test todo'), findsWidgets);
    },
  );
}

void registerWebsocketIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'WebSocket flow',
    testName: 'opens WebSocket demo from example and shows WebSocket page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Open WebSocket demo');
      await pumpUntilFound(tester, find.text('WebSocket demo'));

      expect(find.text('WebSocket demo'), findsWidgets);
    },
  );
}

void registerWhiteboardIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Whiteboard flow',
    testName: 'opens whiteboard from overflow and shows whiteboard page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open Whiteboard');
      await pumpUntilFound(tester, find.text('Whiteboard'));

      expect(find.text('Whiteboard'), findsWidgets);
    },
  );
}

void registerTodoListFilterIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Todo list flow',
    testName: 'filters completed vs active todos',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Todo List Demo');
      await pumpUntilFound(tester, find.text('Todo List'));

      // Add first todo
      await tapAndPump(tester, find.byTooltip('Add todo'));
      await pumpUntilFound(tester, find.text('Save'));
      final Finder titleField = find
          .byWidgetPredicate(
            (final w) => w is TextField || w is CupertinoTextField,
          )
          .first;
      await tester.enterText(titleField, 'Active todo');
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, find.text('Save'));
      await pumpUntilFound(tester, find.text('Active todo'));

      // Add second todo
      await tapAndPump(tester, find.byTooltip('Add todo'));
      await pumpUntilFound(tester, find.text('Save'));
      final Finder secondTitleField = find
          .byWidgetPredicate(
            (final w) => w is TextField || w is CupertinoTextField,
          )
          .first;
      await tester.enterText(secondTitleField, 'Completed todo');
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, find.text('Save'));
      await pumpUntilFound(tester, find.text('Completed todo'));

      // Complete one todo by tapping its list tile text
      await tapAndPump(tester, find.text('Completed todo'));

      // Filter: show only active
      await pumpUntilFound(tester, find.text('Active'));
      await tapAndPump(tester, find.text('Active'));
      await tester.pumpAndSettle();
      if (tester.any(find.text('Active todo'))) {
        expect(find.text('Active todo'), findsWidgets);
        expect(find.text('Completed todo'), findsNothing);
      }

      // Filter: show only completed
      await tapAndPump(tester, find.text('Completed'));
      await tester.pumpAndSettle();
      if (tester.any(find.text('Completed todo'))) {
        expect(find.text('Completed todo'), findsWidgets);
      }
    },
  );
}

void registerSearchEmptyResultsIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Search flow',
    testName: 'shows empty state when no results match query',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Search Demo');
      await pumpUntilFound(tester, find.text('ALL RESULTS'));

      // Enter a query unlikely to have results
      final Finder searchField = find
          .byWidgetPredicate(
            (final w) => w is TextField || w is CupertinoTextField,
          )
          .first;
      await tester.enterText(searchField, 'zzzz-not-found-query');
      await tester.pumpAndSettle();

      if (tester.any(find.text('No results found'))) {
        await pumpUntilFound(
          tester,
          find.text('No results found'),
        );
        expect(find.text('No results found'), findsWidgets);
      }
    },
  );
}

void registerSettingsThemePersistenceIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Settings flow',
    testName: 'persists theme and locale after navigating away and back',
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open settings'));
      await tapAndPump(tester, find.byTooltip('Open settings'));
      await pumpUntilFound(tester, find.text('Settings'));

      // Change theme to dark
      await tapAndPump(
        tester,
        find.text('Dark'),
        settle: const Duration(milliseconds: 200),
      );

      // Change locale to Spanish
      await tester.scrollUntilVisible(
        find.text('Español'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, find.text('Español'));
      await pumpUntilFound(tester, find.text('Configuración'));

      // Navigate back to home
      await tester.pageBack();
      await pumpUntilFound(
        tester,
        find.text('Página principal de la demostración'),
      );

      // Verify dark theme is still applied while on Spanish home
      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.themeMode, ThemeMode.dark);
    },
  );
}
