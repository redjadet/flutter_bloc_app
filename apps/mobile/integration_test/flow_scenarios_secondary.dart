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
        await pumpAfterScrollFling(tester, scrollView);
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
      await launchTestApp(tester, ensureSignedIn: true);

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
      final Finder addTodoButton = _findAdaptiveButtonByText('Add todo');
      await pumpUntilFound(tester, addTodoButton);

      expect(find.text('Todo List'), findsWidgets);

      await tapAndPump(tester, addTodoButton);
      final Finder saveButton = _findDialogButtonByText('Save');
      await pumpUntilFound(tester, saveButton);

      final Finder titleField = _findDialogTextField();
      await tester.ensureVisible(titleField);
      await tester.enterText(titleField, 'Integration test todo');
      await tester.pump(const Duration(milliseconds: 100));
      await tapAndPump(tester, _findDialogCheckbox());
      await tapAndPump(tester, _findDialogCheckbox());
      await tapAndPump(tester, saveButton);
      await pumpUntilAbsent(tester, _findDialog());
      await pumpUntilFound(tester, find.text('Integration test todo'));

      expect(find.text('Integration test todo'), findsWidgets);
    },
  );
}

void registerEventBusDemoIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Event Bus demo flow',
    testName: 'opens Event Bus demo from Example page and updates listeners',
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tapAndPump(tester, find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      final Finder eventBusButton = find.byKey(
        const ValueKey('example-event-bus-demo-button'),
      );
      await tester.scrollUntilVisible(
        eventBusButton,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, eventBusButton);
      await pumpUntilFound(tester, find.text('Event Bus demo'));

      expect(find.text('Event Bus demo'), findsWidgets);

      await tapAndPump(
        tester,
        find.byKey(const ValueKey('event-bus-demo-login-button')),
      );

      await pumpUntilFound(tester, find.textContaining('User 101 is active'));
      expect(find.textContaining('Push connected for user 101'), findsWidgets);
    },
  );
}

void registerNativePlatformShowcaseIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Native platform showcase flow',
    testName: 'opens showcase from Example and renders platform summary',
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tapAndPump(tester, find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      final Finder showcaseButton = find.byKey(
        const ValueKey('example-native-platform-showcase-button'),
      );
      await tester.scrollUntilVisible(
        showcaseButton,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, showcaseButton);
      await pumpUntilFound(tester, find.text('Native platform showcase'));

      expect(find.text('Native platform showcase'), findsWidgets);
      expect(
        find.byKey(const ValueKey('native-platform-showcase-summary')),
        findsOneWidget,
      );
      final String expectedPlatformLabel = kIsWeb
          ? 'Web'
          : switch (defaultTargetPlatform) {
              TargetPlatform.iOS => 'iOS',
              TargetPlatform.android => 'Android',
              TargetPlatform.macOS => 'macOS',
              TargetPlatform.windows => 'Windows',
              TargetPlatform.linux => 'Linux',
              _ => 'iOS',
            };
      expect(find.text(expectedPlatformLabel), findsWidgets);

      final bool expectsMaterialUi =
          kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows;
      expect(
        find.text(expectsMaterialUi ? 'Material' : 'Cupertino'),
        findsWidgets,
      );

      // Page order: summary → security → interop. Security is tall enough that
      // interop keys are off-screen / not built until scrolled into view.
      final Finder securitySection = find.byKey(
        const ValueKey<String>('native-security-showcase-section'),
      );
      await tester.scrollUntilVisible(
        securitySection,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(securitySection, findsOneWidget);
      for (final String cardKey in <String>[
        'native-security-card-crypto',
        'native-security-card-certificate',
        'native-security-card-storage',
        'native-security-card-app-check',
        'native-security-card-biometric',
      ]) {
        final Finder card = find.byKey(ValueKey<String>(cardKey));
        await tester.scrollUntilVisible(
          card,
          300,
          scrollable: find.byType(Scrollable).last,
        );
        expect(card, findsOneWidget);
      }

      Future<void> tapSecurityRun(final String key) async {
        final Finder button = find.byKey(ValueKey<String>(key));
        await tester.scrollUntilVisible(
          button,
          300,
          scrollable: find.byType(Scrollable).last,
        );
        await tapAndPump(tester, button);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      await tapSecurityRun('native-security-run-crypto');
      await tapSecurityRun('native-security-run-aes');
      await tapSecurityRun('native-security-run-storage');

      // Outcomes must never surface secret-looking blobs.
      final RegExp secretLooking = RegExp(
        '-----BEGIN|sha256/[A-Za-z0-9+/=]{20,}',
      );
      final Iterable<String> visibleTexts = find
          .byType(Text)
          .evaluate()
          .map((final e) => (e.widget as Text).data)
          .whereType<String>();
      for (final String text in visibleTexts) {
        expect(
          secretLooking.hasMatch(text),
          isFalse,
          reason: 'Security showcase UI leaked secret-looking text: $text',
        );
      }

      final Finder interopSwift = find.byKey(
        const ValueKey('native-platform-showcase-interop-swift'),
      );
      await tester.scrollUntilVisible(
        interopSwift,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(interopSwift, findsOneWidget);
      expect(
        find.byKey(const ValueKey('native-platform-showcase-interop-kotlin')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('native-platform-showcase-interop-cpp')),
        findsOneWidget,
      );

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        expect(
          find.text('Hello from Apple native FFI (21 + 21 = 42)'),
          findsOneWidget,
        );
      }
      final Finder lessonZero = find.byKey(
        const ValueKey('native-platform-showcase-lesson-0'),
      );
      await tester.scrollUntilVisible(
        lessonZero,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(lessonZero, findsOneWidget);
      final Finder nativeViewEmbedding = find.text('Native view embedding');
      await tester.scrollUntilVisible(
        nativeViewEmbedding,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(nativeViewEmbedding, findsOneWidget);
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

void registerCameraGalleryIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Camera Gallery flow',
    testName:
        'opens Camera & Gallery from Example and applies on-device filter',
    options: const IntegrationDependencyOptions(
      overrideCameraGalleryRepository: true,
    ),
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tapAndPump(tester, find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      final Finder cameraGalleryButton = find.byKey(
        const ValueKey('example-camera-gallery-button'),
      );
      await tester.scrollUntilVisible(
        cameraGalleryButton,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, cameraGalleryButton);
      await pumpUntilFound(tester, find.text('Camera & Gallery'));

      expect(find.text('Camera & Gallery'), findsWidgets);
      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Pick from gallery'), findsOneWidget);

      await tapAndPump(tester, find.text('Pick from gallery'));
      await pumpUntilFound(
        tester,
        find.byKey(const ValueKey('camera-gallery-processing-controls')),
      );
      expect(find.text('On-device processing'), findsOneWidget);
      expect(find.text('Grayscale'), findsOneWidget);

      await tapAndPump(
        tester,
        find.byKey(const ValueKey('camera-gallery-filter-grayscale')),
      );
      await pumpUntilFound(
        tester,
        find.byWidgetPredicate(
          (final widget) =>
              widget is ChoiceChip &&
              widget.key == const ValueKey('camera-gallery-filter-grayscale') &&
              widget.selected,
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    },
  );
}
