import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Utility functions for common Cubit operations to reduce code duplication
class CubitHelpers {
  CubitHelpers._();

  static T? _tryRead<T>(
    final BuildContext context, {
    final String? failureMessage,
  }) {
    try {
      return context.read<T>();
    } on Exception catch (e) {
      if (failureMessage != null) {
        AppLogger.error('$failureMessage $T: $e', e);
      }
      return null;
    }
  }

  /// Safely read a Cubit from context and execute an action
  /// Returns true if successful, false if Cubit is not found
  static bool safeExecute<T extends StateStreamable<S>, S>(
    final BuildContext context,
    final void Function(T cubit) action,
  ) {
    final T? cubit = _tryRead<T>(
      context,
      failureMessage: 'Failed to execute action on Cubit',
    );
    if (cubit == null) return false;
    action(cubit);
    return true;
  }

  /// Safely read a Cubit from context and execute an action with return value
  /// Returns the result if successful, null if Cubit is not found
  static R? safeExecuteWithResult<T extends StateStreamable<S>, S, R>(
    final BuildContext context,
    final R Function(T cubit) action,
  ) {
    final T? cubit = _tryRead<T>(
      context,
      failureMessage: 'Failed to execute action on Cubit',
    );
    if (cubit == null) return null;
    return action(cubit);
  }

  /// Check if a Cubit is available in the widget tree
  static bool isCubitAvailable<T extends StateStreamable<S>, S>(
    final BuildContext context,
  ) => _tryRead<T>(context) != null;

  /// Get the current state of a Cubit safely
  /// Returns null if Cubit is not found
  static S? getCurrentState<T extends StateStreamable<S>, S>(
    final BuildContext context,
  ) {
    final T? cubit = _tryRead<T>(
      context,
      failureMessage: 'Failed to get state from Cubit',
    );
    return cubit?.state;
  }
}

/// Utility extension for common Cubit operations on [BuildContext].
extension CubitContextHelpers on BuildContext {
  /// A convenient way to access a Cubit of type [T] from the widget tree.
  ///
  /// This is a shorthand for `BlocProvider.of<T>(this)`.
  T readCubit<T extends Cubit<dynamic>>() => read<T>();
}
