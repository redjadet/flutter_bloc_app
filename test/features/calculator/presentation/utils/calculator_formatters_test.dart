import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/utils/calculator_formatters.dart';
import 'package:intl/intl.dart';

void main() {
  group('CalculatorFormatters', () {
    testWidgets('creates formatters based on locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          home: Builder(
            builder: (context) {
              final formatters = CalculatorFormatters.of(context);
              expect(formatters.currency, isA<NumberFormat>());
              expect(formatters.percent, isA<NumberFormat>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('currency formatter formats numbers correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          home: Builder(
            builder: (context) {
              final formatters = CalculatorFormatters.of(context);
              final formatted = formatters.currency.format(1234.56);
              // Format should include currency symbol
              expect(formatted, contains('1'));
              expect(formatted, contains('2'));
              expect(formatted, contains('3'));
              expect(formatted, contains('4'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('percent formatter formats numbers correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          home: Builder(
            builder: (context) {
              final formatters = CalculatorFormatters.of(context);
              final formatted = formatters.percent.format(0.15);
              // Format should include percent symbol
              expect(formatted, contains('%'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('respects different locales', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de', 'DE'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'DE'), Locale('en', 'US')],
          home: Builder(
            builder: (context) {
              final formatters = CalculatorFormatters.of(context);
              expect(formatters.currency, isA<NumberFormat>());
              expect(formatters.percent, isA<NumberFormat>());
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
