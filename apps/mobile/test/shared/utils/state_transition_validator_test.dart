import 'package:flutter_bloc_app/shared/utils/state_transition_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StateTransitionValidator', () {
    test('isValidTransition returns true for valid transition', () {
      final TestValidator validator = TestValidator();
      const TestState from = TestState(value: 0);
      const TestState to = TestState(value: 1);

      final bool result = validator.isValidTransition(from, to);

      expect(result, isTrue);
    });

    test('isValidTransition returns false for invalid transition', () {
      final TestValidator validator = TestValidator();
      const TestState from = TestState(value: 0);
      const TestState to = TestState(value: 2);

      final bool result = validator.isValidTransition(from, to);

      expect(result, isFalse);
    });

    test('validateTransition does not throw for valid transition', () {
      final TestValidator validator = TestValidator();
      const TestState from = TestState(value: 0);
      const TestState to = TestState(value: 1);

      expect(() => validator.validateTransition(from, to), returnsNormally);
    });

    test('validateTransition throws StateError for invalid transition', () {
      final TestValidator validator = TestValidator();
      const TestState from = TestState(value: 0);
      const TestState to = TestState(value: 2);

      expect(
        () => validator.validateTransition(from, to),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('FunctionStateTransitionValidator', () {
    test('isValidTransition uses provided function', () {
      final validator = FunctionStateTransitionValidator<TestState>(
        (from, to) => from.value < to.value,
      );
      const TestState from = TestState(value: 0);
      const TestState to = TestState(value: 1);

      final bool result = validator.isValidTransition(from, to);

      expect(result, isTrue);
    });
  });

  group('StateTransitionValidatorExtension', () {
    test('fromFunction creates validator from function', () {
      final validator =
          StateTransitionValidatorExtension.fromFunction<TestState>(
            (from, to) => from.value < to.value,
          );
      const TestState from = TestState(value: 0);
      const TestState to = TestState(value: 1);

      final bool result = validator.isValidTransition(from, to);

      expect(result, isTrue);
    });
  });

  group('createStateTransitionValidator', () {
    test('creates validator from function', () {
      final validator = createStateTransitionValidator<TestState>(
        (from, to) => from.value < to.value,
      );
      const TestState from = TestState(value: 0);
      const TestState to = TestState(value: 1);

      final bool result = validator.isValidTransition(from, to);

      expect(result, isTrue);
    });
  });

  // Note: StateTransitionValidation mixin uses a private _validator field
  // which makes it difficult to test directly. The mixin is tested indirectly
  // through its usage in production code. The validator classes themselves
  // are well-tested above.
}

class TestValidator extends StateTransitionValidator<TestState> {
  @override
  bool isValidTransition(final TestState from, final TestState to) {
    // Allow transitions where value increases by 1
    return to.value == from.value + 1;
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
