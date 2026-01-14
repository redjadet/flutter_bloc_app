import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/utils/state_restoration_mixin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StateRestorationMixin', () {
    test('applyRestorationOutcome emits state when not closed', () async {
      final TestCubit cubit = TestCubit();
      addTearDown(cubit.close);

      await cubit.testApplyRestorationOutcome((
        state: const TestState(value: 42),
        shouldPersist: false,
        holdSideEffects: false,
      ));

      expect(cubit.state.value, 42);
    });

    test('applyRestorationOutcome does not emit when closed', () async {
      final TestCubit cubit = TestCubit();
      await cubit.close();

      await cubit.testApplyRestorationOutcome((
        state: const TestState(value: 42),
        shouldPersist: false,
        holdSideEffects: false,
      ));

      // State should remain unchanged (initial state)
      expect(cubit.state.value, 0);
    });

    test('applyRestorationOutcome calls onHoldChanged when provided', () async {
      final TestCubit cubit = TestCubit();
      addTearDown(cubit.close);
      bool holdChangedCalled = false;
      bool? holdValue;

      await cubit.testApplyRestorationOutcome(
        (
          state: const TestState(value: 1),
          shouldPersist: false,
          holdSideEffects: true,
        ),
        onHoldChanged: ({required bool holdSideEffects}) {
          holdChangedCalled = true;
          holdValue = holdSideEffects;
        },
      );

      expect(holdChangedCalled, isTrue);
      expect(holdValue, isTrue);
    });

    test(
      'applyRestorationOutcome calls onHoldSideEffects when holdSideEffects is true',
      () async {
        final TestCubit cubit = TestCubit();
        addTearDown(cubit.close);
        bool holdSideEffectsCalled = false;

        await cubit.testApplyRestorationOutcome(
          (
            state: const TestState(value: 1),
            shouldPersist: false,
            holdSideEffects: true,
          ),
          onHoldSideEffects: () {
            holdSideEffectsCalled = true;
          },
        );

        expect(holdSideEffectsCalled, isTrue);
      },
    );

    test(
      'applyRestorationOutcome does not call onHoldSideEffects when holdSideEffects is false',
      () async {
        final TestCubit cubit = TestCubit();
        addTearDown(cubit.close);
        bool holdSideEffectsCalled = false;

        await cubit.testApplyRestorationOutcome(
          (
            state: const TestState(value: 1),
            shouldPersist: false,
            holdSideEffects: false,
          ),
          onHoldSideEffects: () {
            holdSideEffectsCalled = true;
          },
        );

        expect(holdSideEffectsCalled, isFalse);
      },
    );

    test('applyRestorationOutcome calls onAfterEmit when provided', () async {
      final TestCubit cubit = TestCubit();
      addTearDown(cubit.close);
      bool afterEmitCalled = false;
      TestState? emittedState;

      await cubit.testApplyRestorationOutcome(
        (
          state: const TestState(value: 42),
          shouldPersist: false,
          holdSideEffects: false,
        ),
        onAfterEmit: (final state) {
          afterEmitCalled = true;
          emittedState = state;
        },
      );

      expect(afterEmitCalled, isTrue);
      expect(emittedState?.value, 42);
    });

    test(
      'applyRestorationOutcome calls onPersist when shouldPersist is true',
      () async {
        final TestCubit cubit = TestCubit();
        addTearDown(cubit.close);
        bool persistCalled = false;
        TestState? persistedState;

        await cubit.testApplyRestorationOutcome(
          (
            state: const TestState(value: 42),
            shouldPersist: true,
            holdSideEffects: false,
          ),
          onPersist: (final state) async {
            persistCalled = true;
            persistedState = state;
          },
        );

        expect(persistCalled, isTrue);
        expect(persistedState?.value, 42);
      },
    );

    test(
      'applyRestorationOutcome does not call onPersist when shouldPersist is false',
      () async {
        final TestCubit cubit = TestCubit();
        addTearDown(cubit.close);
        bool persistCalled = false;

        await cubit.testApplyRestorationOutcome(
          (
            state: const TestState(value: 42),
            shouldPersist: false,
            holdSideEffects: false,
          ),
          onPersist: (final state) async {
            persistCalled = true;
          },
        );

        expect(persistCalled, isFalse);
      },
    );
  });
}

class TestCubit extends Cubit<TestState> with StateRestorationMixin<TestState> {
  TestCubit() : super(const TestState(value: 0));

  // Expose protected method for testing
  Future<void> testApplyRestorationOutcome(
    final StateRestorationOutcome<TestState> outcome, {
    final FutureOr<void> Function(TestState state)? onPersist,
    final void Function({required bool holdSideEffects})? onHoldChanged,
    final void Function()? onHoldSideEffects,
    final void Function(TestState state)? onAfterEmit,
    final String logContext = 'StateRestorationMixin.applyRestorationOutcome',
  }) async {
    return applyRestorationOutcome(
      outcome,
      onPersist: onPersist,
      onHoldChanged: onHoldChanged,
      onHoldSideEffects: onHoldSideEffects,
      onAfterEmit: onAfterEmit,
      logContext: logContext,
    );
  }
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
