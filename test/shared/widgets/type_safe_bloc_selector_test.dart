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
  });
}

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(const TestState(value: 0, label: 'Initial'));
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
