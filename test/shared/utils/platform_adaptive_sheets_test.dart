import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive_sheets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

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

    testWidgets('showPickerModal renders title and selected item state', (
      final WidgetTester tester,
    ) async {
      await _pumpMaterialAppWithMixTheme(tester);

      unawaited(
        PlatformAdaptiveSheets.showPickerModal<String>(
          context: tester.element(find.byType(Scaffold)),
          items: const <String>['Alpha', 'Beta'],
          selectedItem: 'Alpha',
          title: 'Pick One',
          itemLabel: (final item) => item,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pick One'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('showPickerModal returns tapped material item', (
      final WidgetTester tester,
    ) async {
      await _pumpMaterialAppWithMixTheme(tester);

      String? selectedValue;
      unawaited(
        PlatformAdaptiveSheets.showPickerModal<String>(
          context: tester.element(find.byType(Scaffold)),
          items: const <String>['Alpha', 'Beta'],
          selectedItem: 'Alpha',
          itemLabel: (final item) => item,
        ).then((final value) => selectedValue = value),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'Beta');
    });
  });
}

Future<void> _pumpMaterialAppWithMixTheme(final WidgetTester tester) {
  return tester.pumpWidget(
    MaterialApp(
      builder: (final context, final child) => MixTheme(
        data: buildAppMixThemeData(context),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const Scaffold(body: SizedBox()),
    ),
  );
}
