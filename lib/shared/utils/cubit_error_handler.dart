import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Mixin for standardized error handling in cubits.
///
/// This mixin provides a consistent pattern for handling errors across cubits,
/// including logging, state emission, and error type handling. It reduces
/// code duplication in error handling logic.
///
/// Example:
/// ```dart
/// class MyCubit extends Cubit<MyState> with CubitErrorHandler {
///   void loadData() async {
///     try {
///       final data = await _repository.fetch();
///       emit(state.copyWith(data: data, status: ViewStatus.success));
///     } catch (error, stackTrace) {
///       handleError(
///         error,
///         stackTrace,
///         (error) => state.copyWith(
///           errorMessage: error.toString(),
///           status: ViewStatus.error,
///         ),
///         'MyCubit.loadData',
///       );
///     }
///   }
/// }
/// ```
mixin CubitErrorHandler<S> on Cubit<S> {
  /// Handles an error with standardized logging and state emission.
  ///
  /// This method:
  /// 1. Logs the error with the provided context
  /// 2. Checks if the cubit is closed (returns early if so)
  /// 3. Emits the error state using the provided builder
  ///
  /// Parameters:
  /// - [error]: The error that occurred
  /// - [stackTrace]: The stack trace (if available)
  /// - [errorStateBuilder]: Function that creates the error state from the error
  /// - [logContext]: Context string for logging (e.g., 'MyCubit.loadData')
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await _repository.save(data);
  /// } catch (error, stackTrace) {
  ///   handleError(
  ///     error,
  ///     stackTrace,
  ///     (error) => state.copyWith(
  ///       error: MyError.fromException(error),
  ///       status: ViewStatus.error,
  ///     ),
  ///     'MyCubit.save',
  ///   );
  /// }
  /// ```
  void handleError(
    final Object error,
    final StackTrace? stackTrace,
    final S Function(Object error) errorStateBuilder,
    final String logContext,
  ) {
    AppLogger.error(logContext, error, stackTrace);
    if (isClosed) return;
    emit(errorStateBuilder(error));
  }

  /// Handles an error with a custom error factory function.
  ///
  /// Useful when you need to convert the error to a specific error type
  /// before building the state.
  ///
  /// Parameters:
  /// - [error]: The error that occurred
  /// - [stackTrace]: The stack trace (if available)
  /// - [errorFactory]: Function that converts the error to a specific error type
  /// - [errorStateBuilder]: Function that creates the error state from the converted error
  /// - [logContext]: Context string for logging
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await _repository.save(data);
  /// } catch (error, stackTrace) {
  ///   handleErrorWithFactory(
  ///     error,
  ///     stackTrace,
  ///     (originalError) => originalError is MyException
  ///         ? MyError.fromException(originalError)
  ///         : MyError.generic(originalError: originalError),
  ///     (myError) => state.copyWith(
  ///       error: myError,
  ///       status: ViewStatus.error,
  ///     ),
  ///     'MyCubit.save',
  ///   );
  /// }
  /// ```
  void handleErrorWithFactory<E>(
    final Object error,
    final StackTrace? stackTrace,
    final E Function(Object error) errorFactory,
    final S Function(E error) errorStateBuilder,
    final String logContext,
  ) {
    AppLogger.error(logContext, error, stackTrace);
    if (isClosed) return;
    final E convertedError = error is E ? error as E : errorFactory(error);
    emit(errorStateBuilder(convertedError));
  }
}
