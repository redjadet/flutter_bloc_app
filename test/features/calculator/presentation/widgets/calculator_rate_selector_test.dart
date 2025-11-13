import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_rate_selector.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:intl/intl.dart';

void main() {
  group('CalculatorRateSelector', () {
    late CalculatorRateSelectorConfig config;
    late double selectedRate;
    late bool onChangedCalled;
    late double? onChangedValue;
    late bool onResetCalled;

    setUp(() {
      config = CalculatorRateSelectorConfig(
        title: 'Tax Rate',
        options: const [0, 0.05, 0.1, 0.18],
        customLabel: 'Custom',
        customDialogTitle: 'Custom Tax Rate',
        customFieldLabel: 'Enter rate',
        customApplyLabel: 'Apply',
        customCancelLabel: 'Cancel',
        resetLabel: 'Reset',
      );
      selectedRate = 0.1;
      onChangedCalled = false;
      onChangedValue = null;
      onResetCalled = false;
    });

    Widget buildWidget({bool enabled = true, double? rate}) {
      return MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CalculatorRateSelector(
            config: config,
            selectedRate: rate ?? selectedRate,
            onChanged: (value) {
              onChangedCalled = true;
              onChangedValue = value;
            },
            onReset: () {
              onResetCalled = true;
            },
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tax Rate'), findsOneWidget);
    });

    testWidgets('renders all option chips', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Check for option chips (formatted as percentages)
      final percentFormat = NumberFormat.percentPattern('en_US');
      for (final option in config.options) {
        expect(find.text(percentFormat.format(option)), findsOneWidget);
      }
    });

    testWidgets('renders custom label chip', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('renders reset chip', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('selects correct rate chip', (tester) async {
      await tester.pumpWidget(buildWidget(rate: 0.1));
      await tester.pumpAndSettle();

      final percentFormat = NumberFormat.percentPattern('en_US');
      final selectedChip = tester.widget<ChoiceChip>(
        find
            .ancestor(
              of: find.text(percentFormat.format(0.1)),
              matching: find.byType(ChoiceChip),
            )
            .first,
      );
      expect(selectedChip.selected, isTrue);
    });

    testWidgets('calls onChanged when option chip is tapped', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final percentFormat = NumberFormat.percentPattern('en_US');
      await tester.tap(find.text(percentFormat.format(0.05)));
      await tester.pumpAndSettle();

      expect(onChangedCalled, isTrue);
      expect(onChangedValue, 0.05);
    });

    testWidgets('calls onReset when reset chip is tapped', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(onResetCalled, isTrue);
    });

    testWidgets('opens custom dialog when custom chip is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Tax Rate'), findsOneWidget);
      expect(find.text('Enter rate'), findsOneWidget);
    });

    testWidgets('applies custom rate from dialog', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Enter custom rate (15% = 15 in the field, which becomes 0.15)
      await tester.enterText(find.byType(TextField), '15');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(onChangedCalled, isTrue);
      expect(onChangedValue, 0.15);
    });

    testWidgets('cancels custom rate dialog', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '20');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(onChangedCalled, isFalse);
      expect(find.text('Custom Tax Rate'), findsNothing);
    });

    testWidgets('disables chips when enabled is false', (tester) async {
      await tester.pumpWidget(buildWidget(enabled: false));
      await tester.pumpAndSettle();

      final percentFormat = NumberFormat.percentPattern('en_US');
      final optionChip = tester.widget<ChoiceChip>(
        find
            .ancestor(
              of: find.text(percentFormat.format(0.05)),
              matching: find.byType(ChoiceChip),
            )
            .first,
      );
      expect(optionChip.onSelected, isNull);

      final resetChip = tester.widget<InputChip>(
        find
            .ancestor(of: find.text('Reset'), matching: find.byType(InputChip))
            .first,
      );
      expect(resetChip.onPressed, isNull);
    });

    testWidgets('shows custom selection when rate is not in options', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(rate: 0.15));
      await tester.pumpAndSettle();

      final customChip = tester.widget<ChoiceChip>(
        find
            .ancestor(
              of: find.text('Custom'),
              matching: find.byType(ChoiceChip),
            )
            .first,
      );
      expect(customChip.selected, isTrue);
    });

    testWidgets('uses suffixText when provided', (tester) async {
      final customConfig = CalculatorRateSelectorConfig(
        title: 'Rate',
        options: const [0, 0.1],
        customLabel: 'Custom',
        customDialogTitle: 'Custom Rate',
        customFieldLabel: 'Enter rate',
        customApplyLabel: 'Apply',
        customCancelLabel: 'Cancel',
        resetLabel: 'Reset',
        suffixText: 'pts',
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CalculatorRateSelector(
              config: customConfig,
              selectedRate: 0.1,
              onChanged: (_) {},
              onReset: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Check that suffixText appears in the dialog
      expect(find.text('pts'), findsOneWidget);
    });
  });

  group('CalculatorRateSelectorConfig factories', () {
    test('taxRateSelectorConfig creates correct config', () {
      final l10n = AppLocalizationsEn();
      final config = taxRateSelectorConfig(l10n);

      expect(config.title, l10n.calculatorTaxPresetsLabel);
      expect(config.options, calculatorTaxRateOptions);
      expect(config.customLabel, l10n.calculatorCustomTaxLabel);
    });

    test('tipRateSelectorConfig creates correct config', () {
      final l10n = AppLocalizationsEn();
      final config = tipRateSelectorConfig(l10n);

      expect(config.title, l10n.calculatorTipRateLabel);
      expect(config.options, calculatorTipRateOptions);
      expect(config.customLabel, l10n.calculatorCustomTipLabel);
    });
  });
}
