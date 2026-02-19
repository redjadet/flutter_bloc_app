import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TypeSafeBlocSelector', () {
    testWidgets('builds widget with selected value', (final tester) async {
      final TestCubit cubit = TestCubit();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocSelector<TestCubit, TestState, int>(
              selector: (final state) => state.value,
              builder: (final context, final value) => Text('Value: $value'),
            ),
          ),
        ),
      );

      expect(find.text('Value: 0'), findsOneWidget);
    });

    testWidgets('rebuilds only when selected value changes', (
      final tester,
    ) async {
      final TestCubit cubit = TestCubit();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocSelector<TestCubit, TestState, int>(
              selector: (final state) => state.value,
              builder: (final context, final value) => Text('Value: $value'),
            ),
          ),
        ),
      );

      expect(find.text('Value: 0'), findsOneWidget);

      // Emit state with different selected value - should rebuild
      cubit.emit(const TestState(value: 42, label: 'New'));
      await tester.pump();
      expect(find.text('Value: 42'), findsOneWidget);
    });

    testWidgets('works with Bloc state sources', (final tester) async {
      final TestBloc bloc = TestBloc();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            create: (_) => bloc,
            child: TypeSafeBlocSelector<TestBloc, TestState, int>(
              selector: (final state) => state.value,
              builder: (final context, final value) => Text('Value: $value'),
            ),
          ),
        ),
      );

      expect(find.text('Value: 0'), findsOneWidget);

      bloc.add(const TestIncremented());
      await tester.pump();
      expect(find.text('Value: 1'), findsOneWidget);
    });
  });

  group('TypeSafeBlocBuilder', () {
    testWidgets('builds widget with current state', (final tester) async {
      final TestCubit cubit = TestCubit();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocBuilder<TestCubit, TestState>(
              builder: (final context, final state) =>
                  Text('${state.value}: ${state.label}'),
            ),
          ),
        ),
      );

      expect(find.text('0: Initial'), findsOneWidget);
    });

    testWidgets('rebuilds on every state change', (final tester) async {
      final TestCubit cubit = TestCubit();
      int buildCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocBuilder<TestCubit, TestState>(
              builder: (final context, final state) {
                buildCount++;
                return Text('${state.value}: ${state.label}');
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);

      cubit.emit(const TestState(value: 1, label: 'Changed'));
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('1: Changed'), findsOneWidget);
    });

    testWidgets('respects buildWhen condition', (final tester) async {
      final TestCubit cubit = TestCubit();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocBuilder<TestCubit, TestState>(
              buildWhen: (final previous, final current) =>
                  previous.value != current.value,
              builder: (final context, final state) =>
                  Text('${state.value}: ${state.label}'),
            ),
          ),
        ),
      );

      expect(find.text('0: Initial'), findsOneWidget);

      // Different value - should rebuild
      cubit.emit(const TestState(value: 42, label: 'New'));
      await tester.pump();
      expect(find.text('42: New'), findsOneWidget);
    });

    testWidgets('works with Bloc state sources', (final tester) async {
      final TestBloc bloc = TestBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            create: (_) => bloc,
            child: TypeSafeBlocBuilder<TestBloc, TestState>(
              builder: (final context, final state) =>
                  Text('${state.value}: ${state.label}'),
            ),
          ),
        ),
      );

      expect(find.text('0: Initial'), findsOneWidget);

      bloc.add(const TestIncremented());
      await tester.pump();
      expect(find.text('1: Bloc'), findsOneWidget);
    });
  });

  group('TypeSafeBlocListener', () {
    testWidgets('calls listener on state change', (final tester) async {
      final TestCubit cubit = TestCubit();
      int listenerCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocListener<TestCubit, TestState>(
              listener: (final context, final state) {
                listenerCount++;
              },
              child: const Text('Child'),
            ),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);
      expect(listenerCount, 0);

      cubit.emit(const TestState(value: 1, label: 'Changed'));
      await tester.pump();
      expect(listenerCount, 1);
    });

    testWidgets('respects listenWhen condition', (final tester) async {
      final TestCubit cubit = TestCubit();
      int listenerCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocListener<TestCubit, TestState>(
              listenWhen: (final previous, final current) =>
                  previous.value != current.value,
              listener: (final context, final state) {
                listenerCount++;
              },
              child: const Text('Child'),
            ),
          ),
        ),
      );

      expect(listenerCount, 0);

      cubit.emit(const TestState(value: 0, label: 'LabelChanged'));
      await tester.pump();
      expect(listenerCount, 0);

      cubit.emit(const TestState(value: 42, label: 'New'));
      await tester.pump();
      expect(listenerCount, 1);
    });

    testWidgets('passes child widget', (final tester) async {
      final TestCubit cubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocListener<TestCubit, TestState>(
              listener: (final _, final _) {},
              child: const Text('Custom Child'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Child'), findsOneWidget);
    });

    testWidgets('works inside MultiBlocListener', (final tester) async {
      final TestCubit cubit = TestCubit();
      int listenerCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: MultiBlocListener(
              listeners: [
                TypeSafeBlocListener<TestCubit, TestState>(
                  listener: (final context, final state) {
                    listenerCount++;
                  },
                ),
              ],
              child: const Text('Injected Child'),
            ),
          ),
        ),
      );

      expect(find.text('Injected Child'), findsOneWidget);
      expect(listenerCount, 0);

      cubit.emit(const TestState(value: 7, label: 'Changed'));
      await tester.pump();
      expect(listenerCount, 1);
    });

    testWidgets('works with Bloc state sources', (final tester) async {
      final TestBloc bloc = TestBloc();
      int listenerCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            create: (_) => bloc,
            child: TypeSafeBlocListener<TestBloc, TestState>(
              listener: (final context, final state) {
                listenerCount++;
              },
              child: const Text('Bloc Child'),
            ),
          ),
        ),
      );

      expect(find.text('Bloc Child'), findsOneWidget);
      expect(listenerCount, 0);

      bloc.add(const TestIncremented());
      await tester.pump();
      expect(listenerCount, 1);
    });
  });

  group('TypeSafeBlocConsumer', () {
    testWidgets('calls listener and builder', (final tester) async {
      final TestCubit cubit = TestCubit();
      bool listenerCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocConsumer<TestCubit, TestState>(
              listener: (final context, final state) {
                listenerCalled = true;
              },
              builder: (final context, final state) =>
                  Text('${state.value}: ${state.label}'),
            ),
          ),
        ),
      );

      expect(find.text('0: Initial'), findsOneWidget);
      expect(listenerCalled, isFalse); // Listener not called on initial build

      cubit.emit(const TestState(value: 1, label: 'Changed'));
      await tester.pump();

      expect(listenerCalled, isTrue); // Listener called on state change
      expect(find.text('1: Changed'), findsOneWidget);
    });

    testWidgets('respects listenWhen condition', (final tester) async {
      final TestCubit cubit = TestCubit();
      int listenerCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocConsumer<TestCubit, TestState>(
              listenWhen: (final previous, final current) =>
                  previous.value != current.value,
              listener: (final context, final state) {
                listenerCount++;
              },
              builder: (final context, final state) =>
                  Text('${state.value}: ${state.label}'),
            ),
          ),
        ),
      );

      // Initial state - listener is not called on first build
      expect(listenerCount, 0);

      // Same value - listener should not be called
      cubit.emit(const TestState(value: 0, label: 'Changed'));
      await tester.pump();
      expect(listenerCount, 0);

      // Different value - listener should be called
      cubit.emit(const TestState(value: 42, label: 'New'));
      await tester.pump();
      expect(listenerCount, 1);
    });

    testWidgets('respects buildWhen condition', (final tester) async {
      final TestCubit cubit = TestCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestCubit>(
            create: (_) => cubit,
            child: TypeSafeBlocConsumer<TestCubit, TestState>(
              listener: (final context, final state) {},
              buildWhen: (final previous, final current) =>
                  previous.value != current.value,
              builder: (final context, final state) =>
                  Text('${state.value}: ${state.label}'),
            ),
          ),
        ),
      );

      expect(find.text('0: Initial'), findsOneWidget);

      // Different value - should rebuild (buildWhen returns true)
      cubit.emit(const TestState(value: 42, label: 'New'));
      await tester.pump();
      expect(find.text('42: New'), findsOneWidget);
    });

    testWidgets('works with Bloc state sources', (final tester) async {
      final TestBloc bloc = TestBloc();
      int listenerCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TestBloc>(
            create: (_) => bloc,
            child: TypeSafeBlocConsumer<TestBloc, TestState>(
              listener: (final context, final state) {
                listenerCount++;
              },
              builder: (final context, final state) =>
                  Text('${state.value}: ${state.label}'),
            ),
          ),
        ),
      );

      expect(find.text('0: Initial'), findsOneWidget);
      expect(listenerCount, 0);

      bloc.add(const TestIncremented());
      await tester.pump();
      expect(find.text('1: Bloc'), findsOneWidget);
      expect(listenerCount, 1);
    });
  });
}

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(const TestState(value: 0, label: 'Initial'));
}

sealed class TestEvent {
  const TestEvent();
}

class TestIncremented extends TestEvent {
  const TestIncremented();
}

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc() : super(const TestState(value: 0, label: 'Initial')) {
    on<TestIncremented>((final event, final emit) {
      emit(TestState(value: state.value + 1, label: 'Bloc'));
    });
  }
}

class TestState {
  const TestState({required this.value, required this.label});

  final int value;
  final String label;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TestState &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          label == other.label;

  @override
  int get hashCode => Object.hash(value, label);
}
