part of 'network_error_mapper.dart';

AppError _getAppError(final dynamic error) {
  if (error == null) {
    return const UnknownError(message: 'An unknown error occurred');
  }

  if (error is AppError) {
    return error;
  }

  if (error is HttpRequestFailure) {
    return error.toAppError();
  }

  if (error is DioException) {
    return _getAppErrorFromDio(error);
  }

  return _getAppErrorFromStringHeuristics(
    error,
    error.toString().toLowerCase(),
  );
}

AppError _getAppErrorFromDio(final DioException error) {
  final int? statusCode = error.response?.statusCode;
  if (statusCode != null) {
    return appErrorFromHttpStatus(
      statusCode,
      message:
          _getMessageForStatusCode(statusCode) ??
          (error.message ?? 'Something went wrong.'),
      cause: error,
    );
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return _networkError(
        kind: NetworkErrorKind.timeout,
        cause: error,
      );
    case DioExceptionType.connectionError:
      return _networkError(
        kind: NetworkErrorKind.offline,
        cause: error,
      );
    default:
      break;
  }

  final String? msg = error.message;
  if (msg != null && msg.trim().isNotEmpty) {
    return UnknownError(message: msg, cause: error);
  }
  return const UnknownError(message: 'Something went wrong.');
}

AppError _getAppErrorFromStringHeuristics(
  final dynamic error,
  final String errorString,
) {
  if (_containsNetworkHint(errorString)) {
    return _networkError(
      kind: NetworkErrorKind.offline,
      cause: error,
    );
  }

  if (_containsTimeoutHint(errorString)) {
    return _networkError(
      kind: NetworkErrorKind.timeout,
      cause: error,
    );
  }

  if (_containsUnauthorizedHint(errorString)) {
    return _authError(
      kind: AuthErrorKind.unauthorized,
      cause: error,
    );
  }

  if (_containsForbiddenHint(errorString)) {
    return _authError(
      kind: AuthErrorKind.forbidden,
      cause: error,
    );
  }

  if (_containsNotFoundHint(errorString)) {
    return _networkError(
      kind: NetworkErrorKind.client,
      cause: error,
      message: _notFoundMessage(),
    );
  }

  if (_containsRateLimitHint(errorString)) {
    return _networkError(
      kind: NetworkErrorKind.rateLimited,
      cause: error,
    );
  }

  if (_containsServiceUnavailableHint(errorString)) {
    return _networkError(
      kind: NetworkErrorKind.serviceUnavailable,
      cause: error,
    );
  }

  final int? extractedStatusCode = _extractHttpStatusCode(errorString);
  if (extractedStatusCode case final int statusCode) {
    return appErrorFromHttpStatus(
      statusCode,
      message:
          _getMessageForStatusCode(statusCode) ??
          'Something went wrong. Please try again.',
      cause: error,
    );
  }

  if (errorString.contains('server')) {
    return _networkError(
      kind: NetworkErrorKind.server,
      cause: error,
    );
  }

  return const UnknownError(
    message: 'Something went wrong. Please try again.',
  );
}

String _getErrorMessage(
  final dynamic error, {
  final AppLocalizations? l10n,
}) {
  if (error is HttpRequestFailure) {
    return _getHttpRequestFailureMessage(error, l10n: l10n);
  }

  final AppError appError = _getAppError(error);
  final String? typedMessage = _getTypedErrorMessage(
    appError,
    originalError: error,
    l10n: l10n,
  );
  if (typedMessage != null) {
    return typedMessage;
  }

  if (error == null) {
    return l10n?.errorUnknown ?? appError.message;
  }

  final String errorString = error.toString().toLowerCase();
  final String? heuristicMessage = _getHeuristicMessage(
    errorString,
    l10n: l10n,
  );
  if (heuristicMessage != null) {
    return heuristicMessage;
  }

  return l10n?.errorGeneric ?? appError.message;
}

String _getHttpRequestFailureMessage(
  final HttpRequestFailure error, {
  final AppLocalizations? l10n,
}) {
  if (_hasExplicitStatusMessage(error.statusCode)) {
    final String? statusMessage = _getMessageForStatusCode(
      error.statusCode,
      l10n: l10n,
    );
    if (statusMessage != null) {
      return statusMessage;
    }
  }

  if (error.message.trim().isNotEmpty &&
      !_hasExplicitStatusMessage(error.statusCode)) {
    return error.message;
  }

  final String? statusMessage = _getMessageForStatusCode(
    error.statusCode,
    l10n: l10n,
  );
  if (statusMessage != null) {
    return statusMessage;
  }

  return l10n?.errorGeneric ?? 'Something went wrong.';
}

NetworkError _networkError({
  required final NetworkErrorKind kind,
  required final Object? cause,
  final String? message,
}) {
  return NetworkError(
    message: message ?? (_networkMessage(kind) ?? 'Something went wrong.'),
    kind: kind,
    cause: cause,
  );
}

AuthError _authError({
  required final AuthErrorKind kind,
  required final Object? cause,
}) {
  return AuthError(
    message: _authMessage(kind),
    kind: kind,
    cause: cause,
  );
}
