import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/state_transition_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example state for testing state transition validation.
class TestState {
  const TestState(this.status);

  final ViewStatus status;

  @override
  String toString() => 'TestState(status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestState && status == other.status;

  @override
  int get hashCode => status.hashCode;
}

/// Example validator for testing.
class TestStateValidator extends StateTransitionValidator<TestState> {
  @override
  bool isValidTransition(TestState from, TestState to) {
    return switch ((from.status, to.status)) {
      (ViewStatus.initial, ViewStatus.loading) => true,
      (ViewStatus.loading, ViewStatus.success) => true,
      (ViewStatus.loading, ViewStatus.error) => true,
      (ViewStatus.success, ViewStatus.loading) => true,
      (ViewStatus.error, ViewStatus.loading) => true,
      _ => false,
    };
  }
}

void main() {
  group('StateTransitionValidator', () {
    late TestStateValidator validator;

    setUp(() {
      validator = TestStateValidator();
    });

    test('validates allowed transitions', () {
      expect(
        validator.isValidTransition(
          const TestState(ViewStatus.initial),
          const TestState(ViewStatus.loading),
        ),
        isTrue,
      );

      expect(
        validator.isValidTransition(
          const TestState(ViewStatus.loading),
          const TestState(ViewStatus.success),
        ),
        isTrue,
      );
    });

    test('rejects invalid transitions', () {
      expect(
        validator.isValidTransition(
          const TestState(ViewStatus.initial),
          const TestState(ViewStatus.success),
        ),
        isFalse,
      );

      expect(
        validator.isValidTransition(
          const TestState(ViewStatus.success),
          const TestState(ViewStatus.error),
        ),
        isFalse,
      );
    });

    test('validateTransition throws on invalid transition', () {
      expect(
        () => validator.validateTransition(
          const TestState(ViewStatus.initial),
          const TestState(ViewStatus.success),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('validateTransition does not throw on valid transition', () {
      expect(
        () => validator.validateTransition(
          const TestState(ViewStatus.initial),
          const TestState(ViewStatus.loading),
        ),
        returnsNormally,
      );
    });
  });

  group('FunctionStateTransitionValidator', () {
    test('creates validator from function', () {
      final validator = FunctionStateTransitionValidator<TestState>(
        (from, to) => from.status != to.status,
      );

      expect(
        validator.isValidTransition(
          const TestState(ViewStatus.initial),
          const TestState(ViewStatus.loading),
        ),
        isTrue,
      );

      expect(
        validator.isValidTransition(
          const TestState(ViewStatus.initial),
          const TestState(ViewStatus.initial),
        ),
        isFalse,
      );
    });
  });
}
