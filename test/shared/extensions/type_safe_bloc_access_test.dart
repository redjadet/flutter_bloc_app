import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TypeSafeBlocAccess', () {
    testWidgets('cubit returns cubit from context', (final tester) async {
      final TestCubit cubit = TestCubit();
      await tester.pumpWidget(
        BlocProvider<TestCubit>(
          create: (_) => cubit,
          child: Builder(
            builder: (final context) {
              final retrievedCubit = context.cubit<TestCubit>();
              expect(retrievedCubit, same(cubit));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('cubit throws StateError when cubit not found', (
      final tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (final context) {
            expect(
              () => context.cubit<TestCubit>(),
              throwsA(isA<StateError>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('state returns state from cubit', (final tester) async {
      const TestState initialState = TestState(value: 42);
      final TestCubit cubit = TestCubit(initialState);
      await tester.pumpWidget(
        BlocProvider<TestCubit>(
          create: (_) => cubit,
          child: Builder(
            builder: (final context) {
              final state = context.state<TestCubit, TestState>();
              expect(state.value, 42);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('watchCubit returns cubit and rebuilds on state change', (
      final tester,
    ) async {
      final TestCubit cubit = TestCubit();
      int buildCount = 0;
      await tester.pumpWidget(
        BlocProvider<TestCubit>(
          create: (_) => cubit,
          child: Builder(
            builder: (final context) {
              buildCount++;
              final watchedCubit = context.watchCubit<TestCubit>();
              expect(watchedCubit, same(cubit));
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);
      cubit.emit(const TestState(value: 1));
      await tester.pump();
      expect(buildCount, 2);
    });

    testWidgets('watchCubit throws StateError when cubit not found', (
      final tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (final context) {
            expect(
              () => context.watchCubit<TestCubit>(),
              throwsA(isA<StateError>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('watchState returns state and rebuilds on change', (
      final tester,
    ) async {
      final TestCubit cubit = TestCubit();
      int buildCount = 0;
      await tester.pumpWidget(
        BlocProvider<TestCubit>(
          create: (_) => cubit,
          child: Builder(
            builder: (final context) {
              buildCount++;
              final state = context.watchState<TestCubit, TestState>();
              return Text('${state.value}');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget);

      cubit.emit(const TestState(value: 42));
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets(
      'selectState returns selected value and rebuilds only on change',
      (final tester) async {
        final TestCubit cubit = TestCubit();
        int buildCount = 0;
        await tester.pumpWidget(
          BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: Builder(
              builder: (final context) {
                buildCount++;
                final value = context.selectState<TestCubit, TestState, int>(
                  selector: (final state) => state.value,
                );
                return Text('$value');
              },
            ),
          ),
        );

        expect(buildCount, 1);
        expect(find.text('0'), findsOneWidget);

        // Emit state with same value - should not rebuild
        cubit.emit(const TestState(value: 0));
        await tester.pump();
        expect(buildCount, 1);

        // Emit state with different value - should rebuild
        cubit.emit(const TestState(value: 42));
        await tester.pump();
        expect(buildCount, 2);
        expect(find.text('42'), findsOneWidget);
      },
    );

    testWidgets('selectState throws StateError when cubit not found', (
      final tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (final context) {
            expect(
              () => context.selectState<TestCubit, TestState, int>(
                selector: (final state) => state.value,
              ),
              throwsA(isA<StateError>()),
            );
            return const SizedBox();
          },
        ),
      );
    });
  });
}

class TestCubit extends Cubit<TestState> {
  TestCubit([final TestState? initialState])
    : super(initialState ?? const TestState(value: 0));
}

class TestState {
  const TestState({required this.value});

  final int value;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TestState &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
