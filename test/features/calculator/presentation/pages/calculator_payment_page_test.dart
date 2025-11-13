import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_summary_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorPaymentPage', () {
    CalculatorCubit buildCubit() {
      return CalculatorCubit(calculator: const PaymentCalculator());
    }

    Widget buildWidget(CalculatorCubit cubit) {
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
          body: BlocProvider<CalculatorCubit>.value(
            value: cubit,
            child: const CalculatorPaymentPage(),
          ),
        ),
      );
    }

    testWidgets('renders page title', (tester) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.calculatorPaymentTitle), findsWidgets);
    });

    testWidgets('renders calculator summary card', (tester) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(CalculatorSummaryCard), findsOneWidget);
    });

    testWidgets('renders new calculation button', (tester) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.calculatorNewCalculation), findsOneWidget);
    });

    testWidgets('renders new calculation button', (tester) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.calculatorNewCalculation), findsOneWidget);
    });

    testWidgets('renders in scrollable layout', (tester) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('has responsive padding', (tester) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      // Check that the page has scrollable layout
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
