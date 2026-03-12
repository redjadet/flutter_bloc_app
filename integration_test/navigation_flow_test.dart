import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeIntegrationTestHarness);

  setUp(() async {
    await configureIntegrationTestDependencies();
  });

  tearDown(() async {
    await tearDownIntegrationTestDependencies();
  });

  group('Navigation flow', () {
    testWidgets('moves from counter to example and into library demo', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await tester.tap(find.byIcon(Icons.explore));
      await pumpUntilFound(tester, find.text('Example Page'));

      expect(find.text('Example Page'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Library Demo'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Library Demo'));
      await pumpUntilFound(tester, find.text('All Assets'));

      expect(find.text('Library Demo'), findsOneWidget);
      expect(find.text('All Assets'), findsOneWidget);

      await tester.tap(find.byTooltip('Grid view'));
      await pumpUntilFound(tester, find.byType(ScapesGridSliverContent));

      expect(find.byType(ScapesGridSliverContent), findsOneWidget);
    });
  });
}
