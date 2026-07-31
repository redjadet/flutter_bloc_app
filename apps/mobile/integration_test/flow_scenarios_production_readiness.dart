part of 'flow_scenarios.dart';

void registerProductionReadinessIntegrationFlow() {
  registerIntegrationFlow(
    groupName: 'Production readiness flow',
    testName:
        'opens production readiness, emits simulated notification, toggles consent, refreshes release flag',
    body: (final tester) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tapAndPump(tester, find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      final Finder entry = find.byKey(
        const ValueKey('example-production-readiness-button'),
      );
      await tester.scrollUntilVisible(
        entry,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, entry);
      await pumpUntilFound(
        tester,
        find.byKey(const ValueKey('production-readiness-list')),
        timeout: const Duration(seconds: 20),
      );

      expect(
        find.byKey(const ValueKey('production-readiness-mode-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-fcm-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-frame-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-release-card')),
        findsOneWidget,
      );

      final Finder emitSimulated = find.byKey(
        const ValueKey('production-readiness-emit-simulated'),
      );
      if (tester.any(emitSimulated)) {
        await tester.scrollUntilVisible(
          emitSimulated,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tapAndPump(tester, emitSimulated);
        await tester.pump(const Duration(milliseconds: 300));
      }

      final Finder consentSwitch = find.byKey(
        const ValueKey('production-readiness-consent-switch'),
      );
      await tester.scrollUntilVisible(
        consentSwitch,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, consentSwitch);
      await tester.pump(const Duration(milliseconds: 300));

      final Finder releaseRetry = find.byKey(
        const ValueKey('production-readiness-release-retry'),
      );
      await tester.scrollUntilVisible(
        releaseRetry,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndPump(tester, releaseRetry);
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.byKey(const ValueKey('production-readiness-list')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-event-count')),
        findsOneWidget,
      );
    },
  );
}
