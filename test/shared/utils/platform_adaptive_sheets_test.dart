import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive_sheets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformAdaptiveSheets', () {
    testWidgets('showAdaptiveModalBottomSheet shows Material bottom sheet', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      bool sheetShown = false;
      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          builder: (final context) {
            sheetShown = true;
            return const SizedBox();
          },
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(sheetShown, isTrue);
    });

    testWidgets('showAdaptiveModalBottomSheet respects isScrollControlled', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          isScrollControlled: true,
          builder: (final context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('showAdaptiveModalBottomSheet respects useSafeArea', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          useSafeArea: true,
          builder: (final context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('showAdaptiveModalBottomSheet respects isDismissible', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          isDismissible: false,
          builder: (final context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('showAdaptiveModalBottomSheet respects enableDrag', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          enableDrag: false,
          builder: (final context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });
  });
}
