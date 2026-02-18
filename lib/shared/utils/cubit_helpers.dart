import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Utility functions for common Cubit operations to reduce code duplication.
///
/// Uses type-safe `context.tryCubit<T>()` under the hood; prefer
/// `context.cubit<T>()` / `context.state<C, S>()` in UI when the cubit is required.
class CubitHelpers {
  CubitHelpers._();

  static T? _tryCubit<T extends Cubit<Object?>>(
    final BuildContext context, {
    final String? failureMessage,
  }) {
    final T? result = context.tryCubit<T>();
    if (result == null && failureMessage != null) {
      AppLogger.error('$failureMessage $T: cubit not found');
    }
    return result;
  }

  /// Safely read a Cubit from context and execute an action.
  /// Returns true if successful, false if Cubit is not found.
  static bool safeExecute<T extends Cubit<S>, S>(
    final BuildContext context,
    final void Function(T cubit) action,
  ) {
    final T? cubit = _tryCubit<T>(
      context,
      failureMessage: 'Failed to execute action on Cubit',
    );
    if (cubit == null) return false;
    action(cubit);
    return true;
  }

  /// Safely read a Cubit from context and execute an action with return value.
  /// Returns the result if successful, null if Cubit is not found.
  static R? safeExecuteWithResult<T extends Cubit<S>, S, R>(
    final BuildContext context,
    final R Function(T cubit) action,
  ) {
    final T? cubit = _tryCubit<T>(
      context,
      failureMessage: 'Failed to execute action on Cubit',
    );
    if (cubit == null) return null;
    return action(cubit);
  }

  /// Check if a Cubit is available in the widget tree.
  static bool isCubitAvailable<T extends Cubit<S>, S>(
    final BuildContext context,
  ) => context.tryCubit<T>() != null;

  /// Get the current state of a Cubit safely.
  /// Returns null if Cubit is not found.
  static S? getCurrentState<T extends Cubit<S>, S>(
    final BuildContext context,
  ) {
    final T? cubit = _tryCubit<T>(
      context,
      failureMessage: 'Failed to get state from Cubit',
    );
    return cubit?.state;
  }
}

/// Utility extension for common Cubit operations on [BuildContext].
extension CubitContextHelpers on BuildContext {
  /// Reads a Cubit of type [T] from the widget tree (one-off, no rebuild).
  ///
  /// Prefer [TypeSafeBlocAccess.cubit] (`context.cubit<T>()`) for
  /// type-safe access and clearer errors when the cubit is missing.
  @Deprecated('Use context.cubit<T>() from type_safe_bloc_access.dart')
  T readCubit<T extends Cubit<dynamic>>() => cubit<T>();
}
