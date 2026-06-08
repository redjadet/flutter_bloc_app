import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/test_harness.dart';
import '../../integration_test/test_harness_log_filtering.dart'
    as test_harness_log_filtering;
import '../../integration_test/test_helpers_bridge.dart' as test_helpers;

void main() {
  final List<AppLogEntry> unexpectedLogs = <AppLogEntry>[];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    unexpectedLogs.clear();
    AppLogger.observer = (final entry) {
      if (test_harness_log_filtering.isUnexpectedIntegrationLog(
        entry,
        isWeb: true,
      )) {
        unexpectedLogs.add(entry);
      }
    };
    await configureIntegrationTestDependencies();
  });

  tearDown(() async {
    AppLogger.observer = null;
    final String details = unexpectedLogs
        .map(test_harness_log_filtering.formatIntegrationLogEntry)
        .join('\n');
    unexpectedLogs.clear();
    await tearDownIntegrationTestDependencies();
    if (details.isNotEmpty) {
      fail(
        'Unexpected warning/error logs during web bootstrap preflight:\n$details',
      );
    }
  });

  testWidgets('launches home screen through web bootstrap path', (
    tester,
  ) async {
    await launchTestApp(tester);

    expect(find.text('Home Page'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    await pumpUntilFound(tester, find.text('0'));
    expect(find.text('0'), findsWidgets);

    // Mirror the high-signal half of `registerAppLaunchIntegrationFlow` on web.
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
  });

  testWidgets('opens native platform showcase from Example on web', (
    tester,
  ) async {
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
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('native-platform-showcase-summary')),
    );

    expect(find.text('Native platform showcase'), findsWidgets);
    expect(find.text('Runtime platform'), findsOneWidget);
    expect(find.text('UI family'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('native-platform-showcase-interop-swift')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-platform-showcase-interop-kotlin')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('native-platform-showcase-interop-cpp')),
      findsOneWidget,
    );
    final Finder lessonZero = find.byKey(
      const ValueKey('native-platform-showcase-lesson-0'),
    );
    await tester.scrollUntilVisible(
      lessonZero,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(lessonZero, findsOneWidget);
  });
}
