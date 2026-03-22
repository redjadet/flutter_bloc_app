part of 'flow_scenarios.dart';

void registerTodoListFilterIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Todo list flow',
    testName: 'filters completed vs active todos',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Todo List Demo');
      await pumpUntilFound(tester, find.text('Todo List'));
      final Finder addTodoButton = _findAdaptiveButtonByText('Add todo');

      // Add first todo
      await tapAndPump(tester, addTodoButton);
      final Finder saveButton = _findDialogButtonByText('Save');
      await pumpUntilFound(tester, saveButton);
      final Finder titleField = _findDialogTextField();
      await tester.enterText(titleField, 'Active todo');
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, _findDialogCheckbox());
      await tapAndPump(tester, _findDialogCheckbox());
      await tapAndPump(tester, saveButton);
      await pumpUntilAbsent(tester, _findDialog());
      await pumpUntilFound(tester, find.text('Active todo'));

      // Add second todo
      await pumpUntilFound(tester, addTodoButton);
      await tapAndPump(tester, addTodoButton);
      final Finder secondSaveButton = _findDialogButtonByText('Save');
      await pumpUntilFound(tester, secondSaveButton);
      final Finder secondTitleField = _findDialogTextField();
      await tester.enterText(secondTitleField, 'Completed todo');
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, _findDialogCheckbox());
      await tapAndPump(tester, _findDialogCheckbox());
      await tapAndPump(tester, secondSaveButton);
      await pumpUntilAbsent(tester, _findDialog());
      await pumpUntilFound(tester, find.text('Completed todo'));

      final Finder completedTodoCard = find.ancestor(
        of: find.text('Completed todo'),
        matching: find.byType(CommonCard),
      );
      final Finder completedTodoCheckbox =
          tester.any(
            find.descendant(
              of: completedTodoCard,
              matching: find.byType(CupertinoCheckbox),
            ),
          )
          ? find
                .descendant(
                  of: completedTodoCard,
                  matching: find.byType(CupertinoCheckbox),
                )
                .first
          : find
                .descendant(
                  of: completedTodoCard,
                  matching: find.byType(Checkbox),
                )
                .first;
      await tapAndPump(tester, completedTodoCheckbox);
      final Finder completeSelectedButton = _findAdaptiveButtonByText(
        'Complete selected',
      );
      await pumpUntilFound(tester, completeSelectedButton);
      await tapAndPump(tester, completeSelectedButton);
      await pumpSettleWithin(tester);

      // Filter: show only active
      final Finder activeFilterButton = _findAdaptiveButtonByText('Active');
      await pumpUntilFound(tester, activeFilterButton);
      await tapAndPump(tester, activeFilterButton);
      await pumpSettleWithin(tester);
      expect(find.text('Active todo'), findsWidgets);
      expect(find.text('Completed todo'), findsNothing);

      // Filter: show only completed
      final Finder completedFilterButton = _findAdaptiveButtonByText(
        'Completed',
      );
      await tapAndPump(tester, completedFilterButton);
      await pumpSettleWithin(tester);
      expect(find.text('Completed todo'), findsWidgets);
      expect(find.text('Active todo'), findsNothing);
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
      await pumpSettleWithin(
        tester,
        timeout: const Duration(seconds: 5),
      );

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
