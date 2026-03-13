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

enum StorageErrorKind {
  read,
  write,
  migration,
  corruption,
}

enum AuthErrorKind {
  unauthorized,
  tokenExpired,
  forbidden,
}

final class NetworkError extends AppError {
  const NetworkError({
    required final String message,
    required this.kind,
    final Object? cause,
  }) : super(message, cause: cause);

  final NetworkErrorKind kind;

  @override
  bool get isRetryable {
    switch (kind) {
      case NetworkErrorKind.timeout:
      case NetworkErrorKind.offline:
      case NetworkErrorKind.serviceUnavailable:
      case NetworkErrorKind.rateLimited:
      case NetworkErrorKind.server:
        return true;
      case NetworkErrorKind.client:
      case NetworkErrorKind.unknown:
        return false;
    }
  }
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
  const UnknownError({
    required final String message,
    final Object? cause,
  }) : super(message, cause: cause);
}

NetworkErrorKind _networkKindFromStatusCode(final int statusCode) {
  if (statusCode == 408) {
    return NetworkErrorKind.timeout;
  }
  if (statusCode == 429) {
    return NetworkErrorKind.rateLimited;
  }
  if (statusCode == 503) {
    return NetworkErrorKind.serviceUnavailable;
  }
  if (statusCode >= 500) {
    return NetworkErrorKind.server;
  }
  if (statusCode >= 400) {
    return NetworkErrorKind.client;
  }
  return NetworkErrorKind.unknown;
}

AppError appErrorFromHttpStatus(
  final int statusCode, {
  required final String message,
  final Object? cause,
}) {
  if (statusCode == 401) {
    return AuthError(
      message: message,
      kind: AuthErrorKind.unauthorized,
      cause: cause,
    );
  }
  if (statusCode == 403) {
    return AuthError(
      message: message,
      kind: AuthErrorKind.forbidden,
      cause: cause,
    );
  }

  final NetworkErrorKind kind = _networkKindFromStatusCode(statusCode);
  return NetworkError(
    message: message,
    kind: kind,
    cause: cause,
  );
}
