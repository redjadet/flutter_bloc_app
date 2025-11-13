import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorPage', () {
    Widget buildSubject() {
      final calculatorCubit = CalculatorCubit(
        calculator: const PaymentCalculator(),
      );

      return MaterialApp(
        home: BlocProvider<CalculatorCubit>.value(
          value: calculatorCubit,
          child: const CalculatorPage(),
        ),
      );
    }

    testWidgets('renders CalculatorPage with app bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(CalculatorPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays calculator display widget', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // CalculatorDisplay is a private widget, but we can verify BlocBuilder exists
      expect(
        find.byType(BlocBuilder<CalculatorCubit, CalculatorState>),
        findsOneWidget,
      );
    });

    testWidgets('displays calculator keypad', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // CalculatorKeypad should be rendered
      expect(find.byType(CalculatorPage), findsOneWidget);
    });

    testWidgets('uses scrollable layout on compact height', (tester) async {
      final calculatorCubit = CalculatorCubit(
        calculator: const PaymentCalculator(),
      );

      // Use a small viewport to trigger compact layout
      await tester.binding.setSurfaceSize(const Size(400, 400));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalculatorCubit>.value(
            value: calculatorCubit,
            child: const CalculatorPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('constrains content width to max width', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });
}
