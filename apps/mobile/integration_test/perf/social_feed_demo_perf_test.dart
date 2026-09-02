import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test_harness.dart';
import 'perf_helpers.dart';

/// Captures social-feed scroll frame timing via the seeded demo journey.
void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerIntegrationHarness();

  group('Social feed demo perf', () {
    testWidgets('captures social feed scroll trace', (tester) async {
      await configureIntegrationTestDependencies();
      await launchTestApp(tester);

      await binding.traceAction(
        () async {
          await timelineTask('perf.social_feed.open', () async {
            await openExampleDestination(tester, 'Social feed demo');
            await pumpUntilFound(
              tester,
              find.byKey(const ValueKey('social-feed-list')),
            );
            await pumpUntilFound(
              tester,
              find.byKey(const ValueKey('social-feed-post-post-060')),
            );
          });

          await timelineTask('perf.social_feed.scroll.long', () async {
            final Finder scrollTarget = await awaitScrollTarget(tester);
            for (int i = 0; i < 6; i++) {
              await tester.fling(
                scrollTarget,
                const Offset(0, -900),
                1800,
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 250));
            }
          });
          await pumpSettleWithin(tester, timeout: const Duration(seconds: 6));
        },
        reportKey: 'social_feed_scroll_trace',
      );

      // Host-side tooling extracts this marker from `flutter test` logs.
      // ignore: avoid_print
      print(
        '__PERF_REPORT_DATA__=${jsonEncode(binding.reportData)}',
      );

      await tearDownIntegrationTestDependencies();
    });
  });
}
