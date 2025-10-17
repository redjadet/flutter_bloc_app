import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Utility functions for common Cubit operations to reduce code duplication
class CubitHelpers {
  CubitHelpers._();

  /// Safely read a Cubit from context and execute an action
  /// Returns true if successful, false if Cubit is not found
  static bool safeExecute<T extends StateStreamable<S>, S>(
    BuildContext context,
    void Function(T cubit) action,
  ) {
    try {
      final T cubit = context.read<T>();
      action(cubit);
      return true;
    } on Exception catch (e) {
      debugPrint('Failed to execute action on Cubit $T: $e');
      return false;
    }
  }

  /// Safely read a Cubit from context and execute an action with return value
  /// Returns the result if successful, null if Cubit is not found
  static R? safeExecuteWithResult<T extends StateStreamable<S>, S, R>(
    BuildContext context,
    R Function(T cubit) action,
  ) {
    try {
      final T cubit = context.read<T>();
      return action(cubit);
    } on Exception catch (e) {
      debugPrint('Failed to execute action on Cubit $T: $e');
      return null;
    }
  }

  /// Check if a Cubit is available in the widget tree
  static bool isCubitAvailable<T extends StateStreamable<S>, S>(
    BuildContext context,
  ) {
    try {
      context.read<T>();
      return true;
    } on Exception {
      return false;
    }
  }

  /// Get the current state of a Cubit safely
  /// Returns null if Cubit is not found
  static S? getCurrentState<T extends StateStreamable<S>, S>(
    BuildContext context,
  ) {
    try {
      final T cubit = context.read<T>();
      return cubit.state;
    } on Exception catch (e) {
      debugPrint('Failed to get state from Cubit $T: $e');
      return null;
    }
  }
}

/// Utility extension for common Cubit operations on [BuildContext].
extension CubitContextHelpers on BuildContext {
  /// A convenient way to access a Cubit of type [T] from the widget tree.
  ///
  /// This is a shorthand for `BlocProvider.of<T>(this)`.
  T readCubit<T extends Cubit<dynamic>>() {
    return read<T>();
  }
}
