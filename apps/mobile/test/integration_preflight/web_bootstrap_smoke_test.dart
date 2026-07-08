@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
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
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions during home launch.',
    );

    expect(find.text('Home Page'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    await pumpUntilFound(tester, find.text('0'));
    expect(find.text('0'), findsWidgets);

    // Mirror the high-signal half of `registerAppLaunchIntegrationFlow` on web.
    final Finder incrementButton = find
        .widgetWithIcon(FloatingActionButton, Icons.add)
        .first;
    await tapAndPump(tester, incrementButton);
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after increment.',
    );
    await pumpUntilFound(tester, find.text('1'));
    expect(find.text('1'), findsWidgets);

    final Finder decrementButton = find
        .widgetWithIcon(FloatingActionButton, Icons.remove)
        .first;
    await tapAndPump(tester, decrementButton);
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after decrement.',
    );
    await pumpUntilFound(tester, find.text('0'));
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('opens native platform showcase from Example on web', (
    tester,
  ) async {
    await launchTestApp(tester);
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions during launch.',
    );

    await pumpUntilFound(tester, find.byTooltip('Open example page'));
    await tapAndPump(tester, find.byTooltip('Open example page'));
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after opening Example.',
    );
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
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after opening showcase.',
    );
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

  testWidgets('opens staff app demo shell on web after sign-in', (
    tester,
  ) async {
    await launchTestApp(tester, ensureSignedIn: true);
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions during signed-in launch.',
    );

    tester
        .widget<AppScope>(find.byType(AppScope))
        .router
        .go(AppRoutes.staffAppDemoPath);
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after routing to staff demo.',
    );
    await pumpUntilFound(
      tester,
      find.text('Home'),
      timeout: const Duration(seconds: 15),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after staff demo settle.',
    );

    expect(find.text('Staff demo'), findsWidgets);
    expect(find.text('0', skipOffstage: true), findsNothing);
  });

  testWidgets('opens case study demo home on web after sign-in', (
    tester,
  ) async {
    await launchTestApp(tester, ensureSignedIn: true);
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions during signed-in launch.',
    );

    tester
        .widget<AppScope>(find.byType(AppScope))
        .router
        .go(AppRoutes.caseStudyDemoPath);
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after routing to case study demo.',
    );
    await pumpUntilFound(
      tester,
      find.text('Case study demo'),
      timeout: const Duration(seconds: 15),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.takeException(),
      isNull,
      reason: 'No layout/runtime exceptions after case study demo settle.',
    );

    expect(find.text('Home Page', skipOffstage: true), findsNothing);
  });
}
