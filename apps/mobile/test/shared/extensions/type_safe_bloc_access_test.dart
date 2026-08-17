import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('TypeSafeBlocAccess', () {
    testWidgets('bloc returns bloc from context', (tester) async {
      final TestBloc bloc = TestBloc();
      await tester.pumpWidget(
        BlocProvider<TestBloc>(
          create: (_) => bloc,
          child: Builder(
            builder: (context) {
              final retrievedBloc = context.bloc<TestBloc>();
              expect(retrievedBloc, same(bloc));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('cubit returns cubit from context', (tester) async {
      final TestCubit cubit = TestCubit();
      await tester.pumpWidget(
        BlocProvider<TestCubit>(
          create: (_) => cubit,
          child: Builder(
            builder: (context) {
              final retrievedCubit = context.cubit<TestCubit>();
              expect(retrievedCubit, same(cubit));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('cubit throws StateError when cubit not found', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => context.cubit<TestCubit>(),
              throwsA(isA<StateError>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('tryBloc returns null when bloc not found', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final TestBloc? bloc = context.tryBloc<TestBloc>();
            expect(bloc, isNull);
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('tryCubit returns null when cubit not found', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final TestCubit? cubit = context.tryCubit<TestCubit>();
            expect(cubit, isNull);
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('state returns state from cubit', (tester) async {
      const TestState initialState = TestState(value: 42);
      final TestCubit cubit = TestCubit(initialState);
      await tester.pumpWidget(
        BlocProvider<TestCubit>(
          create: (_) => cubit,
          child: Builder(
            builder: (context) {
              final state = context.state<TestCubit, TestState>();
              expect(state.value, 42);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('state returns state from bloc', (tester) async {
      final TestBloc bloc = TestBloc();
      await tester.pumpWidget(
        BlocProvider<TestBloc>(
          create: (_) => bloc,
          child: Builder(
            builder: (context) {
              final state = context.state<TestBloc, TestState>();
              expect(state.value, 0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('watchCubit returns cubit and rebuilds on state change', (
      tester,
    ) async {
      final TestCubit cubit = TestCubit();
      int buildCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: Builder(
              builder: (context) {
                buildCount++;
                final watchedCubit = context.watchCubit<TestCubit>();
                expect(watchedCubit, same(cubit));
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);
      cubit.emit(const TestState(value: 1));
      await tester.pump();
      expect(buildCount, 2);
    });

    testWidgets('watchCubit throws StateError when cubit not found', (
      tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => context.watchCubit<TestCubit>(),
              throwsA(isA<StateError>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('watchBloc returns bloc and rebuilds on state change', (
      tester,
    ) async {
      final TestBloc bloc = TestBloc();
      int buildCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            create: (_) => bloc,
            child: Builder(
              builder: (context) {
                buildCount++;
                final watchedBloc = context.watchBloc<TestBloc>();
                expect(watchedBloc, same(bloc));
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);
      bloc.add(const TestIncremented());
      await tester.pump();
      expect(buildCount, 2);
    });

    testWidgets('watchState returns state and rebuilds on change', (
      tester,
    ) async {
      final TestCubit cubit = TestCubit();
      int buildCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: Builder(
              builder: (context) {
                buildCount++;
                final state = context.watchState<TestCubit, TestState>();
                return Text('${state.value}');
              },
            ),
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
      (tester) async {
        final TestCubit cubit = TestCubit();
        int buildCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<TestCubit>(
              create: (_) => cubit,
              child: Builder(
                builder: (context) {
                  buildCount++;
                  final value = context.selectState<TestCubit, TestState, int>(
                    selector: (state) => state.value,
                  );
                  return Text('$value');
                },
              ),
            ),
          ),
        );

        expect(buildCount, 1);
        expect(find.text('0'), findsOneWidget);

        // Emit state with same value - should not rebuild
        cubit.emit(const TestState(value: 0));
        await tester.pump();
        // Note: context.select from provider may not detect BLoC state changes
        // as it compares the cubit instance, not the state
        // This is a limitation of using provider's select with BLoC
        expect(buildCount, 1);

        // Emit state with different value - should rebuild
        cubit.emit(const TestState(value: 42));
        await tester.pump();
        // Note: context.select from flutter_bloc should detect state changes
        // but may need an extra pump to propagate
        await tester.pump();
        // Verify rebuild happened (should be 2: initial + state change)
        expect(buildCount, 2);
        expect(find.text('42'), findsOneWidget);
      },
    );

    testWidgets('selectState throws StateError when cubit not found', (
      tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => context.selectState<TestCubit, TestState, int>(
                selector: (state) => state.value,
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
  TestCubit([TestState? initialState])
    : super(initialState ?? const TestState(value: 0));
}

sealed class TestEvent {
  const TestEvent();
}

class TestIncremented extends TestEvent {
  const TestIncremented();
}

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc() : super(const TestState(value: 0)) {
    on<TestIncremented>((event, emit) {
      emit(TestState(value: state.value + 1));
    });
  }
}

class TestState {
  const TestState({required this.value});

  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestState &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
