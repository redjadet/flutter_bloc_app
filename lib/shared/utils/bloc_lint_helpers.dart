/// Helper utilities for BLoC/Cubit linting and validation.
///
/// These utilities provide runtime checks that complement static analysis,
/// helping catch BLoC-related issues during development and testing.
///
/// **Note:** These are runtime helpers. For true compile-time validation,
/// consider creating custom analyzer plugins (see [Code Generation Guide](../docs/code_generation_guide.md)).
library;

import 'package:flutter_bloc/flutter_bloc.dart';

/// Validates that a cubit has proper lifecycle guards.
///
/// Use this in tests or debug mode to ensure cubits follow best practices.
///
/// **Usage Example:**
/// ```dart
/// void validateCubitLifecycle(Cubit<CounterState> cubit) {
///   BlocLintHelpers.validateLifecycleGuards(cubit);
/// }
/// ```
class BlocLintHelpers {
  BlocLintHelpers._();

  /// Validates that async operations in a cubit check `isClosed` before emitting.
  ///
  /// This is a runtime check. For compile-time validation, use analyzer plugins.
  ///
  /// **Note:** This requires reflection or code analysis, which is limited in Dart.
  /// Consider using static analysis tools or code generation for true compile-time checks.
  static void validateLifecycleGuards<T extends Cubit<Object?>>(final T cubit) {
    // Runtime validation would require reflection or code analysis
    // This is a placeholder for future implementation
    // For now, rely on static analysis and testing
  }

  /// Validates that all state variants are handled in a switch expression.
  ///
  /// Use this in tests to ensure exhaustiveness for sealed state classes.
  ///
  /// **Usage Example:**
  /// ```dart
  /// test('handles all state variants', () {
  ///   final states = [
  ///     DeepLinkIdle(),
  ///     DeepLinkLoading(),
  ///     DeepLinkNavigate(target, origin),
  ///     DeepLinkError('test'),
  ///   ];
  ///
  ///   for (final state in states) {
  ///     final result = switch (state) {
  ///       DeepLinkIdle() => 'idle',
  ///       DeepLinkLoading() => 'loading',
  ///       DeepLinkNavigate() => 'navigate',
  ///       DeepLinkError() => 'error',
  ///     };
  ///     expect(result, isNotNull);
  ///   }
  /// });
  /// ```
  ///
  /// **Note:** Dart 3.0+ compiler ensures exhaustiveness at compile time.
  /// This helper is for documentation and testing purposes.
  static bool validateStateExhaustiveness<T, R>(
    final List<T> allStates,
    final R Function(T) handler,
  ) {
    // This is a runtime check - compile-time exhaustiveness is handled by Dart
    for (final state in allStates) {
      try {
        handler(state);
      } on Exception {
        return false;
      }
    }
    return true;
  }

  /// Validates that event handlers exist for all event types in a BLoC.
  ///
  /// Use this in tests to ensure all events are handled.
  ///
  /// **Usage Example:**
  /// ```dart
  /// test('handles all events', () {
  ///   final bloc = CounterBloc();
  ///   final events = [
  ///     IncrementEvent(),
  ///     DecrementEvent(),
  ///     ResetEvent(),
  ///   ];
  ///
  ///   for (final event in events) {
  ///     expect(() => bloc.add(event), returnsNormally);
  ///   }
  /// });
  /// ```
  static bool validateEventHandlers<TEvent, TState>(
    final Bloc<TEvent, TState> bloc,
    final List<TEvent> allEvents,
  ) {
    // Runtime check - compile-time validation requires code generation
    for (final event in allEvents) {
      try {
        bloc.add(event);
      } on Exception {
        return false;
      }
    }
    return true;
  }
}

/// Extension methods for validating BLoC patterns.
extension BlocValidationHelpers<T extends Cubit<Object?>> on T {
  /// Validates that the cubit properly guards async operations.
  ///
  /// This is a documentation helper. Actual validation requires static analysis.
  ///
  /// **Best Practice:** Always check `isClosed` before `emit()` in async callbacks:
  /// ```dart
  /// Future<void> loadData() async {
  ///   final data = await repository.fetch();
  ///   if (isClosed) return; // Guard against disposal
  ///   emit(state.copyWith(data: data));
  /// }
  /// ```
  void validateAsyncGuards() {
    // Runtime validation placeholder
    // Use static analysis tools for compile-time validation
  }
}
