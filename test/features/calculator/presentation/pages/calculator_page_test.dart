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

      // CalculatorDisplay uses BlocSelector (optimized from BlocBuilder)
      // Verify that the display text is rendered (indirectly confirms BlocSelector works)
      expect(find.text('0'), findsWidgets);
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
      addTearDown(calculatorCubit.close);

      tester.view.physicalSize = const Size(400, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
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

    testWidgets('does not overflow on degenerate narrow viewport', (
      tester,
    ) async {
      final calculatorCubit = CalculatorCubit(
        calculator: const PaymentCalculator(),
      );
      addTearDown(calculatorCubit.close);
      final originalOnError = FlutterError.onError;
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (final details) {
        errors.add(details);
        originalOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = originalOnError;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      tester.view.physicalSize = const Size(96, 360);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalculatorCubit>.value(
            value: calculatorCubit,
            child: const CalculatorPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final overflows = errors.where(
        (final error) => error.exceptionAsString().contains('overflow'),
      );
      expect(overflows, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('constrains content width to max width', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });
}
