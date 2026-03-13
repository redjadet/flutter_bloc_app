part of 'flow_scenarios.dart';

void registerAppLaunchIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'App launch',
    testName: 'launches to the counter page and updates the count',
    body: (final tester) async {
      await launchTestApp(tester);

      expect(find.text('Home Page'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      await pumpUntilFound(tester, find.text('0'));
      expect(find.text('0'), findsWidgets);

      final Finder incrementButton = find
          .widgetWithIcon(FloatingActionButton, Icons.add)
          .first;
      await tapAndPump(tester, incrementButton);
      await pumpUntilFound(tester, find.text('1'));
      expect(find.text('1'), findsWidgets);

      final Finder decrementButton = find
          .widgetWithIcon(FloatingActionButton, Icons.remove)
          .first;
      await tapAndPump(tester, decrementButton);
      await pumpUntilFound(tester, find.text('0'));
      expect(find.text('0'), findsWidgets);
    },
  );
}

void registerCalculatorIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Calculator flow',
    testName: 'opens calculator from home and shows calculator page',
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open payment calculator'));
      await tapAndPump(tester, find.byTooltip('Open payment calculator'));
      await pumpUntilFound(tester, find.text('Payment calculator'));

      expect(find.text('Payment calculator'), findsWidgets);
    },
  );
}

void registerChartsIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Charts flow',
    testName: 'opens charts from overflow and shows chart page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open charts');
      await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));

      expect(find.text('Bitcoin Price (USD)'), findsWidgets);
    },
  );
}

void registerChatListIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Chat list flow',
    testName: 'opens chat list from example and shows conversation history',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Chat List Demo');
      await pumpUntilFound(tester, find.text('Conversation history'));

      expect(find.text('Conversation history'), findsWidgets);
    },
  );
}

void registerCounterPersistenceIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Counter persistence',
    testName: 'restores the saved count after rebuilding the app',
    options: const IntegrationDependencyOptions(
      overrideCounterRepository: false,
    ),
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.text('0'));

      final Finder incrementButton = find
          .widgetWithIcon(FloatingActionButton, Icons.add)
          .first;
      await tapAndPump(tester, incrementButton);
      await pumpUntilFound(tester, find.text('1'));

      expect(find.text('1'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tearDownIntegrationTestDependencies();
      await configureIntegrationTestDependencies(
        overrideCounterRepository: false,
      );
      await launchTestApp(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
      await pumpUntilFound(tester, find.text('1'));
      expect(find.text('1'), findsWidgets);
    },
  );
}

void registerGenUiDemoIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'GenUI demo flow',
    testName: 'opens GenUI demo from overflow and shows GenUI demo page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'GenUI Demo');
      await pumpUntilFound(tester, find.text('GenUI Demo'));

      expect(find.text('GenUI Demo'), findsWidgets);
    },
  );
}

void registerGraphqlDemoIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'GraphQL demo flow',
    testName: 'opens GraphQL demo from overflow and shows GraphQL page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Explore GraphQL sample');
      await pumpUntilFound(
        tester,
        find.text('GraphQL Countries'),
        timeout: const Duration(seconds: 10),
      );

      expect(find.text('GraphQL Countries'), findsWidgets);
    },
  );
}

void registerIgamingDemoIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'iGaming demo flow',
    testName: 'opens iGaming demo from overflow and shows iGaming demo lobby',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'iGaming Demo');
      await pumpUntilFound(tester, find.text('iGaming Demo'));

      expect(find.text('iGaming Demo'), findsWidgets);
    },
  );
}

void registerIotDemoIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'IoT demo flow',
    testName: 'opens IoT demo from overflow and shows IoT demo page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open IoT Demo');
      await pumpUntilFound(tester, find.text('IoT Demo'));

      expect(find.text('IoT Demo'), findsWidgets);
    },
  );
}

void registerMarkdownEditorIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Markdown editor flow',
    testName:
        'opens markdown editor from overflow and shows markdown editor page',
    body: (final tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open Markdown Editor');
      await pumpUntilFound(tester, find.text('Markdown Editor'));

      expect(find.text('Markdown Editor'), findsWidgets);
    },
  );
}
