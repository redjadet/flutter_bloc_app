import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
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
    testWidgets('safeExecute executes action when cubit is available', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => TestCubit(),
            child: Builder(
              builder: (context) {
                var callCount = 0;

                final result = CubitHelpers.safeExecute<TestCubit, int>(
                  context,
                  (cubit) {
                    callCount++;
                    expect(cubit.state, 0);
                    cubit.increment();
                  },
                );

                expect(result, isTrue);
                expect(callCount, 1);
                expect(context.cubit<TestCubit>().state, 1);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('safeExecute returns false when cubit is unavailable', (
      tester,
    ) async {
      await _withSilencedDebugPrint(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: CubitHelpersTest._safeExecuteMissingCubitBuilder,
              ),
            ),
          ),
        );
      });
    });

    testWidgets('safeExecuteWithResult returns value when cubit is available', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => TestCubit(),
            child: Builder(
              builder: (context) {
                final cubit = context.cubit<TestCubit>();
                cubit
                  ..increment()
                  ..increment();

                final result =
                    CubitHelpers.safeExecuteWithResult<TestCubit, int, String>(
                      context,
                      (cubit) => 'state:${cubit.state}',
                    );

                expect(result, 'state:2');
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets(
      'safeExecuteWithResult returns null when cubit is unavailable',
      (tester) async {
        await _withSilencedDebugPrint(() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder:
                      CubitHelpersTest._safeExecuteWithResultMissingBuilder,
                ),
              ),
            ),
          );
        });
      },
    );

    testWidgets('isCubitAvailable returns true when cubit is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => TestCubit(),
            child: Builder(
              builder: (context) {
                expect(
                  CubitHelpers.isCubitAvailable<TestCubit, int>(context),
                  isTrue,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isCubitAvailable returns false when cubit is not provided', (
      tester,
    ) async {
      await _withSilencedDebugPrint(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: CubitHelpersTest._isCubitAvailableMissingBuilder,
              ),
            ),
          ),
        );
      });
    });

    testWidgets('getCurrentState returns current cubit state when available', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => TestCubit()..emit(3),
            child: Builder(
              builder: (context) {
                final state = CubitHelpers.getCurrentState<TestCubit, int>(
                  context,
                );
                expect(state, 3);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getCurrentState returns null when cubit is unavailable', (
      tester,
    ) async {
      await _withSilencedDebugPrint(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: CubitHelpersTest._getCurrentStateMissingBuilder,
              ),
            ),
          ),
        );
      });
    });

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
      await _withSilencedDebugPrint(() async {
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

        expect(
          () =>
              tester.element(find.byType(Builder).first).readCubit<TestCubit>(),
          throwsA(isA<StateError>()),
        );
      });
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
            child: TypeSafeBlocBuilder<TestCubit, int>(
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
            child: TypeSafeBlocListener<TestCubit, int>(
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
            child: TypeSafeBlocConsumer<TestCubit, int>(
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

    testWidgets('_tryCubit logs error when failureMessage is provided', (
      tester,
    ) async {
      await _withSilencedDebugPrint(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // This will trigger error logging path in _tryCubit
                  final result = CubitHelpers.safeExecute<TestCubit, int>(
                    context,
                    (_) {},
                  );
                  expect(result, isFalse);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });
  });
}

Future<void> _withSilencedDebugPrint(Future<void> Function() body) async {
  final previous = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {};
  try {
    await body();
  } finally {
    debugPrint = previous;
  }
}

/// Helpers for callbacks that must exist at compile-time constants.
class CubitHelpersTest {
  const CubitHelpersTest._();

  static Widget _safeExecuteMissingCubitBuilder(BuildContext context) {
    final result = CubitHelpers.safeExecute<TestCubit, int>(
      context,
      (_) => fail('Action should not run without cubit'),
    );
    expect(result, isFalse);
    return const SizedBox.shrink();
  }

  static Widget _safeExecuteWithResultMissingBuilder(BuildContext context) {
    final result = CubitHelpers.safeExecuteWithResult<TestCubit, int, String>(
      context,
      (_) => 'unexpected',
    );
    expect(result, isNull);
    return const SizedBox.shrink();
  }

  static Widget _isCubitAvailableMissingBuilder(BuildContext context) {
    final isAvailable = CubitHelpers.isCubitAvailable<TestCubit, int>(context);
    expect(isAvailable, isFalse);
    return const SizedBox.shrink();
  }

  static Widget _getCurrentStateMissingBuilder(BuildContext context) {
    final state = CubitHelpers.getCurrentState<TestCubit, int>(context);
    expect(state, isNull);
    return const SizedBox.shrink();
  }
}
