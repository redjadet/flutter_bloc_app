import 'package:core/core.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';

/// Maps domain [Failure] to presentation [AppError].
AppError appErrorFromFailure(final Failure failure) => switch (failure) {
  PermissionFailure(:final PermissionFailureReason reason) => UnknownError(
    message: switch (reason) {
      PermissionFailureReason.denied => 'Permission denied.',
      PermissionFailureReason.permanentlyDenied =>
        'Permission permanently denied.',
      PermissionFailureReason.restricted => 'Permission restricted.',
      PermissionFailureReason.limited => 'Limited permission granted.',
    },
    cause: failure.cause,
  ),
  PlatformFailure() => UnknownError(
    message: 'Platform capability unavailable.',
    cause: failure.cause,
  ),
  StorageFailure(:final StorageFailureKind kind, :final String? key) =>
    StorageError(
      message: key == null
          ? 'Secure storage operation failed.'
          : 'Secure storage operation failed for "$key".',
      kind: _storageErrorKind(kind),
      cause: failure.cause,
    ),
  TimeoutFailure() => NetworkError(
    message: 'Operation timed out.',
    kind: NetworkErrorKind.timeout,
    cause: failure.cause,
  ),
  ValidationFailure(:final String code) => UnknownError(
    message: 'Validation failed: $code',
    cause: failure.cause,
  ),
  UnknownFailure(:final String? message) => UnknownError(
    message: message ?? 'An unexpected error occurred.',
    cause: failure.cause,
  ),
};

StorageErrorKind _storageErrorKind(final StorageFailureKind kind) =>
    switch (kind) {
      StorageFailureKind.read => StorageErrorKind.read,
      StorageFailureKind.write => StorageErrorKind.write,
      StorageFailureKind.delete => StorageErrorKind.delete,
    };
