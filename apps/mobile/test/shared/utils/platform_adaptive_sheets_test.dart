import 'dart:async';

import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/app/utils/platform_adaptive_sheets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('PlatformAdaptiveSheets', () {
    testWidgets('showAdaptiveModalBottomSheet shows Material bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      bool sheetShown = false;
      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          builder: (context) {
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
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          isScrollControlled: true,
          builder: (context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('showAdaptiveModalBottomSheet respects useSafeArea', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          useSafeArea: true,
          builder: (context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('showAdaptiveModalBottomSheet respects isDismissible', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          isDismissible: false,
          builder: (context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('showAdaptiveModalBottomSheet respects enableDrag', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
          context: tester.element(find.byType(Scaffold)),
          enableDrag: false,
          builder: (context) => const SizedBox(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('showPickerModal renders title and selected item state', (
      WidgetTester tester,
    ) async {
      await _pumpMaterialAppWithMixTheme(tester);

      unawaited(
        PlatformAdaptiveSheets.showPickerModal<String>(
          context: tester.element(find.byType(Scaffold)),
          items: const <String>['Alpha', 'Beta'],
          selectedItem: 'Alpha',
          title: 'Pick One',
          itemLabel: (item) => item,
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
      WidgetTester tester,
    ) async {
      await _pumpMaterialAppWithMixTheme(tester);

      String? selectedValue;
      unawaited(
        PlatformAdaptiveSheets.showPickerModal<String>(
          context: tester.element(find.byType(Scaffold)),
          items: const <String>['Alpha', 'Beta'],
          selectedItem: 'Alpha',
          itemLabel: (item) => item,
        ).then((value) => selectedValue = value),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'Beta');
    });

    testWidgets('showPickerModal keys material rows with itemKey', (
      WidgetTester tester,
    ) async {
      await _pumpMaterialAppWithMixTheme(tester);

      unawaited(
        PlatformAdaptiveSheets.showPickerModal<String>(
          context: tester.element(find.byType(Scaffold)),
          items: const <String>['Alpha', 'Beta'],
          selectedItem: 'Alpha',
          itemLabel: (item) => item,
          itemKey: (item) => 'id-$item',
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const ValueKey<Object?>('id-Alpha')), findsOneWidget);
      expect(find.byKey(const ValueKey<Object?>('id-Beta')), findsOneWidget);
    });
  });
}

Future<void> _pumpMaterialAppWithMixTheme(WidgetTester tester) {
  return tester.pumpWidget(
    MaterialApp(
      builder: (context, child) =>
          buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
      home: const Scaffold(body: SizedBox()),
    ),
  );
}
