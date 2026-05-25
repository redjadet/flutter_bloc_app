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
  });
}
