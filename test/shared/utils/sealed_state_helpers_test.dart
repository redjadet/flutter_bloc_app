import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/shared/utils/sealed_state_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SealedStateHelpers', () {
    test('when throws UnimplementedError', () {
      final TestState state = TestState();
      expect(
        () => state.when(idle: () => 'idle'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('SealedStateMatcher', () {
    test('caseIdle handles idle state', () {
      final TestIdleState state = TestIdleState();
      final result = SealedStateMatcher<TestIdleState, String>(
        state,
      ).caseIdle(() => 'idle').build();

      expect(result, 'idle');
    });

    test('caseLoading handles loading state', () {
      final TestLoadingState state = TestLoadingState();
      final result = SealedStateMatcher<TestLoadingState, String>(
        state,
      ).caseLoading(() => 'loading').build();

      expect(result, 'loading');
    });

    test('caseNavigate handles navigate state', () {
      final TestNavigateState state = TestNavigateState();
      final result = SealedStateMatcher<TestNavigateState, String>(
        state,
      ).caseNavigate((target, origin) => 'navigate').build();

      expect(result, 'navigate');
    });

    test('caseError handles error state', () {
      final TestErrorState state = TestErrorState();
      final result = SealedStateMatcher<TestErrorState, String>(
        state,
      ).caseError((message) => 'error').build();

      expect(result, 'error');
    });

    test('build throws StateError when no handler matches', () {
      final TestState state = TestState();
      expect(
        () => SealedStateMatcher<TestState, String>(state).build(),
        throwsA(isA<StateError>()),
      );
    });

    test('build returns first matching handler result', () {
      final TestIdleState state = TestIdleState();
      final result = SealedStateMatcher<TestIdleState, String>(
        state,
      ).caseIdle(() => 'idle').caseLoading(() => 'loading').build();

      expect(result, 'idle');
    });
  });
}

class TestState extends Equatable {
  const TestState();

  @override
  List<Object?> get props => [];
}

class TestIdleState extends TestState {
  @override
  String toString() => 'TestIdleState';
}

class TestLoadingState extends TestState {
  @override
  String toString() => 'TestLoadingState';
}

class TestNavigateState extends TestState {
  @override
  String toString() => 'TestNavigateState';
}

class TestErrorState extends TestState {
  @override
  String toString() => 'TestErrorState';
}
