import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Cubit for testing
class TestCubit extends Cubit<int> {
  TestCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

class AnotherTestCubit extends Cubit<String> {
  AnotherTestCubit() : super('initial');

  void update(String value) => emit(value);
}

void main() {
  group('CubitHelpers', () {
    testWidgets('readCubit returns correct cubit instance', (tester) async {
      final testCubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => testCubit,
            child: Builder(
              builder: (context) {
                final cubit = context.readCubit<TestCubit>();
                expect(cubit, equals(testCubit));
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('readCubit works with multiple cubit types', (tester) async {
      final testCubit = TestCubit();
      final anotherCubit = AnotherTestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<TestCubit>(create: (_) => testCubit),
              BlocProvider<AnotherTestCubit>(create: (_) => anotherCubit),
            ],
            child: Builder(
              builder: (context) {
                final intCubit = context.readCubit<TestCubit>();
                final stringCubit = context.readCubit<AnotherTestCubit>();

                expect(intCubit, equals(testCubit));
                expect(stringCubit, equals(anotherCubit));
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('readCubit throws when cubit not found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);

      // Test that readCubit throws when Cubit is not found
      expect(
        () => tester.element(find.byType(Builder).first).readCubit<TestCubit>(),
        throwsA(isA<ProviderNotFoundException>()),
      );
    });

    testWidgets('readCubit works in nested contexts', (tester) async {
      final testCubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => testCubit,
            child: Builder(
              builder: (context) {
                return Builder(
                  builder: (nestedContext) {
                    final cubit = nestedContext.readCubit<TestCubit>();
                    expect(cubit, equals(testCubit));
                    return const Text('Nested Test');
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Nested Test'), findsOneWidget);
    });

    testWidgets('readCubit works with BlocBuilder', (tester) async {
      final testCubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => testCubit,
            child: BlocBuilder<TestCubit, int>(
              builder: (context, state) {
                final cubit = context.readCubit<TestCubit>();
                expect(cubit, equals(testCubit));
                return Text('State: $state');
              },
            ),
          ),
        ),
      );

      expect(find.text('State: 0'), findsOneWidget);
    });

    testWidgets('readCubit works with BlocListener', (tester) async {
      final testCubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => testCubit,
            child: BlocListener<TestCubit, int>(
              listener: (context, state) {
                final cubit = context.readCubit<TestCubit>();
                expect(cubit, equals(testCubit));
              },
              child: const Text('Listener Test'),
            ),
          ),
        ),
      );

      expect(find.text('Listener Test'), findsOneWidget);
    });

    testWidgets('readCubit works with BlocConsumer', (tester) async {
      final testCubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => testCubit,
            child: BlocConsumer<TestCubit, int>(
              listener: (context, state) {
                final cubit = context.readCubit<TestCubit>();
                expect(cubit, equals(testCubit));
              },
              builder: (context, state) {
                final cubit = context.readCubit<TestCubit>();
                expect(cubit, equals(testCubit));
                return Text('Consumer State: $state');
              },
            ),
          ),
        ),
      );

      expect(find.text('Consumer State: 0'), findsOneWidget);
    });

    testWidgets('readCubit maintains type safety', (tester) async {
      final testCubit = TestCubit();
      final anotherCubit = AnotherTestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<TestCubit>(create: (_) => testCubit),
              BlocProvider<AnotherTestCubit>(create: (_) => anotherCubit),
            ],
            child: Builder(
              builder: (context) {
                // Type-safe access
                final intCubit = context.readCubit<TestCubit>();
                final stringCubit = context.readCubit<AnotherTestCubit>();

                // Verify types
                expect(intCubit, isA<TestCubit>());
                expect(stringCubit, isA<AnotherTestCubit>());

                // Verify they are different instances
                expect(intCubit, isNot(equals(stringCubit)));

                return const Text('Type Safety Test');
              },
            ),
          ),
        ),
      );

      expect(find.text('Type Safety Test'), findsOneWidget);
    });

    testWidgets('readCubit works with inherited widgets', (tester) async {
      final testCubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => testCubit,
            child: Builder(
              builder: (context) {
                final cubit = context.readCubit<TestCubit>();
                expect(cubit, equals(testCubit));
                return const Text('Inherited Test');
              },
            ),
          ),
        ),
      );

      expect(find.text('Inherited Test'), findsOneWidget);
    });
  });
}
