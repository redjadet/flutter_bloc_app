sealed class AppError {
  const AppError(this.message, {this.cause});

  final String message;
  final Object? cause;

  bool get isRetryable => false;
}

enum NetworkErrorKind {
  timeout,
  offline,
  serviceUnavailable,
  rateLimited,
  server,
  client,
  unknown,
}

enum StorageErrorKind { read, write, delete, migration, corruption }

enum AuthErrorKind { unauthorized, tokenExpired, forbidden }

final class NetworkError extends AppError {
  const NetworkError({
    required final String message,
    required this.kind,
    final Object? cause,
  }) : super(message, cause: cause);

  final NetworkErrorKind kind;

  @override
  bool get isRetryable => switch (kind) {
    NetworkErrorKind.timeout ||
    NetworkErrorKind.offline ||
    NetworkErrorKind.serviceUnavailable ||
    NetworkErrorKind.rateLimited ||
    NetworkErrorKind.server => true,
    NetworkErrorKind.client || NetworkErrorKind.unknown => false,
  };
}

final class StorageError extends AppError {
  const StorageError({
    required final String message,
    required this.kind,
    final Object? cause,
  }) : super(message, cause: cause);

  final StorageErrorKind kind;
}

final class AuthError extends AppError {
  const AuthError({
    required final String message,
    required this.kind,
    final Object? cause,
  }) : super(message, cause: cause);

  final AuthErrorKind kind;
}

final class UnknownError extends AppError {
  const UnknownError({required final String message, final Object? cause})
    : super(message, cause: cause);
}

NetworkErrorKind _networkKindFromStatusCode(final int statusCode) =>
    switch (statusCode) {
      408 => NetworkErrorKind.timeout,
      429 => NetworkErrorKind.rateLimited,
      503 => NetworkErrorKind.serviceUnavailable,
      >= 500 => NetworkErrorKind.server,
      >= 400 => NetworkErrorKind.client,
      _ => NetworkErrorKind.unknown,
    };

AppError appErrorFromHttpStatus(
  final int statusCode, {
  required final String message,
  final Object? cause,
}) => switch (statusCode) {
  401 => AuthError(
    message: message,
    kind: AuthErrorKind.unauthorized,
    cause: cause,
  ),
  403 => AuthError(
    message: message,
    kind: AuthErrorKind.forbidden,
    cause: cause,
  ),
  _ => NetworkError(
    message: message,
    kind: _networkKindFromStatusCode(statusCode),
    cause: cause,
  ),
};
