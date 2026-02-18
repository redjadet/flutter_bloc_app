import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Type-safe extensions for accessing BLoC/Cubit instances from BuildContext.
///
/// These extensions provide compile-time safety by ensuring that:
/// - Cubit types are checked at compile time
/// - Missing cubits throw clear errors
/// - Type inference works correctly
///
/// **Usage Example:**
/// ```dart
/// // Type-safe cubit access
/// final counterCubit = context.cubit<CounterCubit>();
/// counterCubit.increment();
///
/// // Type-safe state access
/// final count = context.state<CounterCubit, CounterState>().count;
/// ```
extension TypeSafeBlocAccess on BuildContext {
  /// Gets a cubit of type [T] from the widget tree.
  ///
  /// Throws a [StateError] if the cubit is not found in the widget tree.
  ///
  /// **Compile-time safety:** The generic type [T] must extend `Cubit<Object?>`.
  ///
  /// **Example:**
  /// ```dart
  /// final counterCubit = context.cubit<CounterCubit>();
  /// ```
  T cubit<T extends Cubit<Object?>>() {
    try {
      return read<T>();
    } on ProviderNotFoundException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        StateError(
          'Cubit of type $T not found in widget tree. '
          'Make sure $T is provided via BlocProvider.',
        ),
        stackTrace,
      );
    }
  }

  /// Optionally gets a cubit of type [T] from the widget tree.
  ///
  /// Returns null if the cubit is not found (e.g. optional feature).
  /// Use [cubit] when the cubit is required.
  T? tryCubit<T extends Cubit<Object?>>() {
    try {
      return read<T>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// Gets the current state of a cubit of type [C] from the widget tree.
  ///
  /// Throws a [StateError] if the cubit is not found in the widget tree.
  ///
  /// **Compile-time safety:** The generic types [C] and [S] are checked at compile time.
  ///
  /// **Example:**
  /// ```dart
  /// final state = context.state<CounterCubit, CounterState>();
  /// final count = state.count;
  /// ```
  S state<C extends Cubit<S>, S>() {
    final cubit = this.cubit<C>();
    return cubit.state;
  }

  /// Watches a cubit of type [T] and rebuilds when its state changes.
  ///
  /// This is a type-safe wrapper around `context.watch<T>()`.
  ///
  /// **Compile-time safety:** The generic type [T] must extend `Cubit<Object?>`.
  ///
  /// **Example:**
  /// ```dart
  /// final counterCubit = context.watchCubit<CounterCubit>();
  /// ```
  T watchCubit<T extends Cubit<Object?>>() {
    try {
      return watch<T>();
    } on ProviderNotFoundException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        StateError(
          'Cubit of type $T not found in widget tree. '
          'Make sure $T is provided via BlocProvider.',
        ),
        stackTrace,
      );
    }
  }

  /// Watches the state of a cubit of type [C] and rebuilds when it changes.
  ///
  /// This is a type-safe wrapper that returns the state directly.
  ///
  /// **Compile-time safety:** The generic types [C] and [S] are checked at compile time.
  ///
  /// **Example:**
  /// ```dart
  /// final state = context.watchState<CounterCubit, CounterState>();
  /// ```
  S watchState<C extends Cubit<S>, S>() => watchCubit<C>().state;

  /// Selects a value from a cubit's state and rebuilds only when that value changes.
  ///
  /// This provides compile-time type safety for state selection.
  ///
  /// **Compile-time safety:** All generic types are checked at compile time.
  ///
  /// **Example:**
  /// ```dart
  /// final count = context.selectState<CounterCubit, CounterState, int>(
  ///   selector: (state) => state.count,
  /// );
  /// ```
  T selectState<C extends Cubit<S>, S, T>({
    required final T Function(S state) selector,
  }) {
    try {
      return select<C, T>((final cubit) => selector(cubit.state));
    } on ProviderNotFoundException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        StateError(
          'Cubit of type $C not found in widget tree. '
          'Make sure $C is provided via BlocProvider.',
        ),
        stackTrace,
      );
    }
  }
}
