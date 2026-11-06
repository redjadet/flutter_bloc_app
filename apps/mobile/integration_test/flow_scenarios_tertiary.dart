part of 'flow_scenarios.dart';

void registerTodoListFilterIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Todo list flow',
    testName: 'filters completed vs active todos',
    body: (tester) async {
      await launchTestApp(tester);

      // Unique titles: macOS desktop Hive persists across IT runs in Application
      // Support, so fixed titles collide with leftovers from prior failures.
      final String stamp = DateTime.now().microsecondsSinceEpoch.toString();
      final String activeTitle = 'Filter active todo $stamp';
      final String completedTitle = 'Filter completed todo $stamp';

      await _openExampleDestination(tester, 'Todo List Demo');
      await pumpUntilFound(tester, find.text('Todo List'));
      final Finder addTodoButton = _findTodoAddControl();
      await pumpUntilFound(tester, addTodoButton);

      // Add first todo (active)
      await tapAndPump(tester, addTodoButton);
      final Finder saveButton = _findDialogButtonByText('Save');
      await pumpUntilFound(tester, saveButton);
      final Finder titleField = _findDialogTextField();
      await tester.enterText(titleField, activeTitle);
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, saveButton);
      await pumpUntilAbsent(tester, _findDialog());
      await pumpUntilFound(tester, find.text(activeTitle));

      // Add second todo completed at create time (dialog "Complete" label).
      // Prefer create-time completion over selection + batch complete: on macOS
      // desktop the batch bar is height-gated and overflow complete is flaky.
      await pumpUntilFound(tester, addTodoButton);
      await tapAndPump(tester, addTodoButton);
      final Finder secondSaveButton = _findDialogButtonByText('Save');
      await pumpUntilFound(tester, secondSaveButton);
      final Finder secondTitleField = _findDialogTextField();
      await tester.enterText(secondTitleField, completedTitle);
      await tester.pump(const Duration(milliseconds: 100));
      // One tap on the dialog completion control leaves isCompleted=true.
      await tapAndPump(
        tester,
        _findDialogCheckbox(),
        scrollIntoView: false,
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, secondSaveButton);
      await pumpUntilAbsent(tester, _findDialog());
      await pumpUntilFound(tester, find.text(completedTitle));

      // Filter: show only active
      final Finder activeFilterButton = _findAdaptiveButtonByText('Active');
      await pumpUntilFound(tester, activeFilterButton);
      await tester.scrollUntilVisible(
        activeFilterButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, activeFilterButton);
      await pumpUntilAbsent(
        tester,
        find.text(completedTitle),
        timeout: const Duration(seconds: 8),
      );
      expect(find.text(activeTitle), findsWidgets);

      // Filter: show only completed
      final Finder completedFilterButton = _findAdaptiveButtonByText(
        'Completed',
      );
      await pumpUntilFound(tester, completedFilterButton);
      await tester.scrollUntilVisible(
        completedFilterButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, completedFilterButton);
      await pumpUntilAbsent(
        tester,
        find.text(activeTitle),
        timeout: const Duration(seconds: 8),
      );
      expect(find.text(completedTitle), findsWidgets);
    },
  );
}

void registerSearchEmptyResultsIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Search flow',
    testName: 'shows empty state when no results match query',
    body: (tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Search Demo');
      await pumpUntilFound(tester, find.text('ALL RESULTS'));

      // Enter a query unlikely to have results
      final Finder searchField = find
          .byWidgetPredicate((w) => w is TextField || w is CupertinoTextField)
          .first;
      await tester.enterText(searchField, 'zzzz-not-found-query');
      await pumpUntilFound(
        tester,
        find.text('No results found'),
        timeout: const Duration(seconds: 8),
      );
      expect(find.text('No results found'), findsWidgets);
    },
  );
}

void registerSettingsThemePersistenceIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Settings flow',
    testName: 'persists theme and locale after navigating away and back',
    body: (tester) async {
      await launchTestApp(tester, ensureSignedIn: true);

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
        300,
        scrollable: find.byType(Scrollable).first,
      );
      // Analytics consent section lengthens Settings; ensureVisible avoids
      // tapping a partially-obscured locale chip.
      await tester.ensureVisible(find.text('Español'));
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, find.text('Español'), scrollIntoView: false);
      await pumpUntilFound(tester, find.text('Configuración'));

      // Navigate back to home (Material + Cupertino)
      await _pageBack(tester);
      // homeTitle ES after branding refresh (#959); keep in sync with app_es.arb
      await pumpUntilFound(tester, find.text('Inicio'));

      // Verify dark theme is still applied while on Spanish home
      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.themeMode, ThemeMode.dark);
    },
  );
}

/// Exhaustive-tier only: deterministic GraphQL network error via fake repo,
/// then recovery through the same Try again path as production UI.
void registerGraphqlNetworkRetryIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'GraphQL demo flow',
    testName: 'shows network error then loads data after Try again',
    options: const IntegrationDependencyOptions(
      graphqlFailOnceThenSuccess: true,
    ),
    body: (tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Explore GraphQL sample');
      await pumpUntilFound(
        tester,
        find.text('Try again'),
        timeout: const Duration(seconds: 15),
      );
      expect(find.text('Something went wrong'), findsWidgets);

      await tapAndPump(tester, find.text('Try again'));
      await pumpUntilFound(
        tester,
        find.text('GraphQL Countries'),
        timeout: const Duration(seconds: 15),
      );
      expect(find.text('Germany'), findsWidgets);
    },
  );
}
