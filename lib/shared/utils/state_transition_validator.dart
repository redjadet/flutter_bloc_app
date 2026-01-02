import 'package:flutter_bloc/flutter_bloc.dart';

/// Utilities for validating state transitions in BLoC/Cubit.
///
/// These utilities provide runtime validation of state transitions,
/// helping catch invalid state changes during development and testing.
///
/// **Usage Example:**
/// ```dart
/// class CounterStateValidator extends StateTransitionValidator<CounterState> {
///   @override
///   bool isValidTransition(CounterState from, CounterState to) {
///     return switch ((from.status, to.status)) {
///       (ViewStatus.initial, ViewStatus.loading) => true,
///       (ViewStatus.loading, ViewStatus.success) => true,
///       (ViewStatus.loading, ViewStatus.error) => true,
///       (ViewStatus.success, ViewStatus.loading) => true,
///       _ => false,
///     };
///   }
/// }
/// ```
abstract class StateTransitionValidator<S> {
  /// Validates if a transition from [from] to [to] is allowed.
  ///
  /// Returns `true` if the transition is valid, `false` otherwise.
  ///
  /// **Example:**
  /// ```dart
  /// bool isValidTransition(CounterState from, CounterState to) {
  ///   // Define valid transitions
  ///   return switch ((from.status, to.status)) {
  ///     (ViewStatus.initial, ViewStatus.loading) => true,
  ///     (ViewStatus.loading, ViewStatus.success) => true,
  ///     _ => false,
  ///   };
  /// }
  /// ```
  bool isValidTransition(final S from, final S to);

  /// Validates a transition and throws if invalid.
  ///
  /// Use this in development/testing to catch invalid transitions early.
  ///
  /// **Example:**
  /// ```dart
  /// void emitState(CounterState newState) {
  ///   validator.validateTransition(state, newState);
  ///   emit(newState);
  /// }
  /// ```
  void validateTransition(final S from, final S to) {
    if (!isValidTransition(from, to)) {
      throw StateError(
        'Invalid state transition from $from to $to. '
        'This transition is not allowed by the state machine.',
      );
    }
  }
}

/// Helper for creating state transition validators with a function.
///
/// **Usage Example:**
/// ```dart
/// final validator = StateTransitionValidator.fromFunction<CounterState>(
///   (from, to) => switch ((from.status, to.status)) {
///     (ViewStatus.initial, ViewStatus.loading) => true,
///     (ViewStatus.loading, ViewStatus.success) => true,
///     _ => false,
///   },
/// );
/// ```
class FunctionStateTransitionValidator<S> extends StateTransitionValidator<S> {
  /// Creates a validator from a validation function.
  FunctionStateTransitionValidator(this._validator);

  final bool Function(S from, S to) _validator;

  @override
  bool isValidTransition(final S from, final S to) => _validator(from, to);
}

/// Extension methods for StateTransitionValidator.
extension StateTransitionValidatorExtension<S> on StateTransitionValidator<S> {
  /// Creates a validator from a function.
  static StateTransitionValidator<T> fromFunction<T>(
    final bool Function(T from, T to) validator,
  ) => FunctionStateTransitionValidator<T>(validator);
}

/// Creates a validator from a function.
///
/// **Usage Example:**
/// ```dart
/// final validator = createStateTransitionValidator<CounterState>(
///   (from, to) => switch ((from.status, to.status)) {
///     (ViewStatus.initial, ViewStatus.loading) => true,
///     (ViewStatus.loading, ViewStatus.success) => true,
///     _ => false,
///   },
/// );
/// ```
StateTransitionValidator<T> createStateTransitionValidator<T>(
  final bool Function(T from, T to) validator,
) => FunctionStateTransitionValidator<T>(validator);

/// Mixin for cubits that want to validate state transitions.
///
/// **Usage Example:**
/// ```dart
/// class CounterCubit extends Cubit<CounterState>
///     with StateTransitionValidation<CounterState> {
///   CounterCubit() : super(CounterState.initial()) {
///     _validator = CounterStateValidator();
///   }
///
///   void loadData() {
///     validateAndEmit(state.copyWith(status: ViewStatus.loading));
///   }
/// }
/// ```
mixin StateTransitionValidation<S> on Cubit<S> {
  /// The validator to use for state transitions.
  ///
  /// Set this in the cubit's constructor.
  late final StateTransitionValidator<S> _validator;

  /// Validates and emits a new state.
  ///
  /// Throws a [StateError] if the transition is invalid.
  ///
  /// **Note:** Only use this in debug mode or tests. In production,
  /// consider logging invalid transitions instead of throwing.
  void validateAndEmit(final S newState) {
    assert(
      () {
        _validator.validateTransition(state, newState);
        return true;
      }(),
      'Invalid state transition from $state to $newState',
    );
    emit(newState);
  }
}
