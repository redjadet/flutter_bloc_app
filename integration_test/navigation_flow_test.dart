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

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tester.tap(find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      expect(find.text('Example Page'), findsWidgets);

      final Finder libraryDemo = find.text('Library Demo');
      await tester.scrollUntilVisible(
        libraryDemo,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(libraryDemo);
      await tester.pumpAndSettle();
      await tester.tap(libraryDemo);
      await tester.pumpAndSettle();
      await pumpUntilFound(
        tester,
        find.text('All Assets'),
        timeout: const Duration(seconds: 15),
      );

      expect(find.text('Library Demo'), findsWidgets);
      expect(find.text('All Assets'), findsWidgets);

      final Finder gridToggle = find.byTooltip('Grid view');
      await pumpUntilFound(tester, gridToggle);
      await tester.ensureVisible(gridToggle);
      await tester.pumpAndSettle();
      await tester.tap(gridToggle);
      await tester.pumpAndSettle();

      // The scapes grid is below the header; slivers are built lazily, so we
      // need to scroll a bit before asserting on the sliver content.
      final Finder scrollView = find.byType(CustomScrollView);
      await pumpUntilFound(tester, scrollView);
      for (
        var i = 0;
        i < 6 && !tester.any(find.byType(ScapesGridSliverContent));
        i++
      ) {
        await tester.fling(scrollView, const Offset(0, -800), 1200);
        await tester.pumpAndSettle();
      }
      await pumpUntilFound(
        tester,
        find.byType(ScapesGridSliverContent),
        timeout: const Duration(seconds: 20),
      );

      expect(find.byType(ScapesGridSliverContent), findsWidgets);
    });
  });
}
