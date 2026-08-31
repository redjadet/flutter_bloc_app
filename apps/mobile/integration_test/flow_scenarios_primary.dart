part of 'flow_scenarios.dart';

void registerGuestSignInIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Guest sign-in',
    testName: 'continue as guest reaches counter with anonymous session',
    options: const IntegrationDependencyOptions(
      authMode: IntegrationAuthMode.realFirebaseAuth,
    ),
    body: (tester) async {
      if (FirebaseBootstrapService.isFirebaseInitialized) {
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.signOut();
        }
        addTearDown(FirebaseAuth.instance.signOut);
      }

      await launchTestApp(tester, requireAuth: true);
      final Finder guestButton = find.byKey(signInGuestButtonKey);
      await pumpUntilFound(tester, guestButton);
      // FirebaseUI footer can sit a few px below a short viewport; nudge up.
      await tester.drag(find.byType(MaterialApp), const Offset(0, -120));
      await tester.pump(const Duration(milliseconds: 200));
      await tapAndPump(tester, guestButton);
      await pumpUntilFound(
        tester,
        find.text('Home Page'),
        timeout: const Duration(seconds: 20),
      );

      final AuthRepository authRepository = getIt<AuthRepository>();
      expect(authRepository.currentUser, isNotNull);
      expect(authRepository.currentUser!.isAnonymous, isTrue);

      final User? firebaseUser = FirebaseBootstrapService.isFirebaseInitialized
          ? FirebaseAuth.instance.currentUser
          : null;
      final bool hasFirebaseAnon = firebaseUser?.isAnonymous ?? false;
      final String guestId = authRepository.currentUser!.id;
      final bool hasDebugLocalGuest =
          guestId == 'ios-simulator-debug-local-guest' ||
          guestId == 'android-emulator-debug-local-guest' ||
          guestId == 'macos-debug-local-guest';
      expect(
        hasFirebaseAnon || hasDebugLocalGuest,
        isTrue,
        reason:
            'Guest flow must yield Firebase anonymous auth or a debug '
            'simulator/emulator local guest user.',
      );

      // Desktop IT may not expose Text.semanticsLabel to finders; assert the
      // counter widget itself (Hive/mock may retain a non-zero value).
      final Finder countFinder = find.byType(CounterValueText);
      await pumpUntilFound(tester, countFinder);
      expect(countFinder, findsWidgets);
    },
  );
}

void registerAppLaunchIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'App launch',
    testName: 'launches to the counter page and updates the count',
    body: (tester) async {
      await launchTestApp(tester);

      expect(find.text('Home Page'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      // Desktop Hive can retain a non-zero count across flows; drive relative
      // to CounterValueText (semantics finders are unreliable on macOS IT).
      final Finder countFinder = find.byType(CounterValueText);
      await pumpUntilFound(tester, countFinder);
      final int startCount = tester
          .widget<CounterValueText>(countFinder.first)
          .count;

      final Finder incrementButton = find
          .widgetWithIcon(FloatingActionButton, Icons.add)
          .first;
      await tapAndPump(tester, incrementButton);
      await pumpUntilFound(
        tester,
        find.descendant(
          of: countFinder,
          matching: find.byKey(ValueKey<int>(startCount + 1)),
        ),
      );
      expect(
        tester.widget<CounterValueText>(countFinder.first).count,
        startCount + 1,
      );

      final Finder decrementButton = find
          .widgetWithIcon(FloatingActionButton, Icons.remove)
          .first;
      await tapAndPump(tester, decrementButton);
      await pumpUntilFound(
        tester,
        find.descendant(
          of: countFinder,
          matching: find.byKey(ValueKey<int>(startCount)),
        ),
      );
      expect(
        tester.widget<CounterValueText>(countFinder.first).count,
        startCount,
      );
    },
  );
}

void registerCalculatorIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Calculator flow',
    testName: 'opens calculator from home and shows calculator page',
    body: (tester) async {
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
    body: (tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open charts');
      await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));

      expect(find.text('Bitcoin Price (USD)'), findsWidgets);
    },
  );
}

void registerChartsRefreshIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Charts flow',
    testName: 'refreshes chart data via pull-to-refresh',
    body: (tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open charts');
      await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));

      final Finder list = find.byType(ListView);
      await tester.fling(list, const Offset(0, 300), 1000);
      await tester.pump(const Duration(milliseconds: 400));
      await pumpSettleWithin(
        tester,
        timeout: const Duration(seconds: 4),
      );

      expect(find.text('Bitcoin Price (USD)'), findsWidgets);
    },
  );
}

void registerChatListIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Chat list flow',
    testName: 'opens chat list from example and shows conversation history',
    body: (tester) async {
      await launchTestApp(tester);

      await _openExampleDestination(tester, 'Chat List Demo');
      await pumpUntilFound(
        tester,
        find.text('Conversation history'),
        timeout: const Duration(seconds: 10),
      );

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
    body: (tester) async {
      // Desktop Hive (`hive_macos_debug`) persists across suite runs; reset so
      // the baseline "0" assertion is deterministic.
      await getIt<CounterRepository>().save(const CounterSnapshot(count: 0));

      await launchTestApp(tester);

      await pumpUntilFound(tester, find.text('0'));

      final Finder incrementButton = find
          .widgetWithIcon(FloatingActionButton, Icons.add)
          .first;
      await tapAndPump(tester, incrementButton);
      await pumpUntilFound(tester, find.text('1'));

      expect(find.text('1'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpSettleWithin(
        tester,
        timeout: const Duration(seconds: 5),
      );

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
    body: (tester) async {
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
    body: (tester) async {
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
    body: (tester) async {
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
    body: (tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open IoT Demo');
      await pumpUntilFound(
        tester,
        find.text('IoT Demo'),
        timeout: const Duration(seconds: 10),
      );

      expect(find.text('IoT Demo'), findsWidgets);
    },
  );
}

void registerIotDemoBleTabIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'IoT demo BLE tab flow',
    testName: 'opens IoT demo BLE tab and shows mock BLE showcase',
    body: (tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open IoT Demo');
      await pumpUntilFound(
        tester,
        find.text('IoT Demo'),
        timeout: const Duration(seconds: 10),
      );

      await tapAndPump(tester, find.text('BLE'));
      await pumpUntilFound(tester, find.text('Bluetooth status'));

      expect(find.text('Bluetooth status'), findsOneWidget);
      expect(find.text('Mock'), findsWidgets);
    },
  );
}

void registerMarkdownEditorIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Markdown editor flow',
    testName:
        'opens markdown editor from overflow and shows markdown editor page',
    body: (tester) async {
      await launchTestApp(tester);

      await _openOverflowDestination(tester, 'Open Markdown Editor');
      await pumpUntilFound(tester, find.text('Markdown Editor'));

      expect(find.text('Markdown Editor'), findsWidgets);
    },
  );
}
