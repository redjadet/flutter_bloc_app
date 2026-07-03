import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_set_value_dialog.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

class _DialogResultStore {
  double? value;
}

Future<void> _pumpDialogHarness(
  final WidgetTester tester,
  final _DialogResultStore resultStore,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (final context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                final AppLocalizations l10n = AppLocalizations.of(context);
                resultStore.value = await showAdaptiveDialog<double>(
                  context: context,
                  builder: (final _) => IotDemoSetValueDialogBody(
                    initialValue: 21,
                    l10n: l10n,
                    minValue: iotDemoValueMin,
                    maxValue: iotDemoValueMax,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('IotDemoSetValueDialogBody', () {
    final AppLocalizationsEn l10n = AppLocalizationsEn();

    testWidgets('shows out-of-range message and does not close', (
      final tester,
    ) async {
      final _DialogResultStore resultStore = _DialogResultStore();
      await _pumpDialogHarness(tester, resultStore);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '100');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.iotDemoSetValueOutOfRange('0', '50')),
        findsOneWidget,
      );
      expect(resultStore.value, isNull);
      expect(find.byType(IotDemoSetValueDialogBody), findsOneWidget);
    });

    testWidgets('accepts comma decimal input and returns value', (
      final tester,
    ) async {
      final _DialogResultStore resultStore = _DialogResultStore();
      await _pumpDialogHarness(tester, resultStore);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '23,5');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(resultStore.value, 23.5);
      expect(find.byType(IotDemoSetValueDialogBody), findsNothing);
    });
  });
}
