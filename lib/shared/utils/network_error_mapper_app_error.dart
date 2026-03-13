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
      return NetworkError(
        message: 'Request timed out. Please try again.',
        kind: NetworkErrorKind.timeout,
        cause: error,
      );
    case DioExceptionType.connectionError:
      return NetworkError(
        message:
            'Network connection error. Please check your internet connection.',
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
    return NetworkError(
      message:
          'Network connection error. Please check your internet connection.',
      kind: NetworkErrorKind.offline,
      cause: error,
    );
  }

  if (_containsTimeoutHint(errorString)) {
    return NetworkError(
      message: 'Request timed out. Please try again.',
      kind: NetworkErrorKind.timeout,
      cause: error,
    );
  }

  if (_containsUnauthorizedHint(errorString)) {
    return AuthError(
      message: 'Authentication required. Please sign in again.',
      kind: AuthErrorKind.unauthorized,
      cause: error,
    );
  }

  if (_containsForbiddenHint(errorString)) {
    return AuthError(
      message: "Access denied. You don't have permission for this action.",
      kind: AuthErrorKind.forbidden,
      cause: error,
    );
  }

  if (_containsNotFoundHint(errorString)) {
    return NetworkError(
      message: 'The requested resource was not found.',
      kind: NetworkErrorKind.client,
      cause: error,
    );
  }

  if (_containsRateLimitHint(errorString)) {
    return NetworkError(
      message: 'Too many requests. Please wait before trying again.',
      kind: NetworkErrorKind.rateLimited,
      cause: error,
    );
  }

  if (_containsServiceUnavailableHint(errorString)) {
    return NetworkError(
      message: 'Service temporarily unavailable. Please try again in a minute.',
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
    return NetworkError(
      message: 'Server error. Please try again later.',
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

String? _getTypedErrorMessage(
  final AppError appError, {
  required final dynamic originalError,
  required final AppLocalizations? l10n,
}) {
  if (appError case final NetworkError networkError) {
    switch (networkError.kind) {
      case NetworkErrorKind.timeout:
        return l10n?.errorTimeout ?? 'Request timed out. Please try again.';
      case NetworkErrorKind.offline:
        return l10n?.errorNetwork ??
            'Network connection error. Please check your internet connection.';
      case NetworkErrorKind.serviceUnavailable:
        return l10n?.errorServiceUnavailable ??
            'Service temporarily unavailable. Please try again in a minute.';
      case NetworkErrorKind.rateLimited:
        return l10n?.errorTooManyRequests ??
            'Too many requests. Please wait before trying again.';
      case NetworkErrorKind.server:
        return l10n?.errorServer ?? 'Server error. Please try again later.';
      case NetworkErrorKind.client:
        if (originalError.toString().contains('404')) {
          return l10n?.errorNotFound ?? 'The requested resource was not found.';
        }
        return l10n?.errorClient ??
            'Client error. Please check your request and try again.';
      case NetworkErrorKind.unknown:
        return null;
    }
  }

  if (appError case final AuthError authError) {
    switch (authError.kind) {
      case AuthErrorKind.unauthorized:
      case AuthErrorKind.tokenExpired:
        return l10n?.errorUnauthorized ??
            'Authentication required. Please sign in again.';
      case AuthErrorKind.forbidden:
        return l10n?.errorForbidden ??
            "Access denied. You don't have permission for this action.";
    }
  }

  return null;
}

String? _getHeuristicMessage(
  final String errorString, {
  required final AppLocalizations? l10n,
}) {
  if (_containsNetworkHint(errorString)) {
    return l10n?.errorNetwork ??
        'Network connection error. Please check your internet connection.';
  }

  if (_containsTimeoutHint(errorString)) {
    return l10n?.errorTimeout ?? 'Request timed out. Please try again.';
  }

  if (_containsUnauthorizedHint(errorString)) {
    return l10n?.errorUnauthorized ??
        'Authentication required. Please sign in again.';
  }

  if (_containsForbiddenHint(errorString)) {
    return l10n?.errorForbidden ??
        "Access denied. You don't have permission for this action.";
  }

  if (_containsNotFoundHint(errorString)) {
    return l10n?.errorNotFound ?? 'The requested resource was not found.';
  }

  if (_containsRateLimitHint(errorString)) {
    return l10n?.errorTooManyRequests ??
        'Too many requests. Please wait before trying again.';
  }

  if (_containsServiceUnavailableHint(errorString)) {
    return l10n?.errorServiceUnavailable ??
        'Service temporarily unavailable. Please try again in a minute.';
  }

  if (errorString.contains('server')) {
    return l10n?.errorServer ?? 'Server error. Please try again later.';
  }

  return null;
}

String? _getMessageForStatusCode(
  final int statusCode, {
  final AppLocalizations? l10n,
}) {
  switch (statusCode) {
    case 401:
      return l10n?.errorUnauthorized ??
          'Authentication required. Please sign in again.';
    case 403:
      return l10n?.errorForbidden ??
          "Access denied. You don't have permission for this action.";
    case 404:
      return l10n?.errorNotFound ?? 'The requested resource was not found.';
    case 408:
      return l10n?.errorTimeout ?? 'Request timed out. Please try again.';
    case 429:
      return l10n?.errorTooManyRequests ??
          'Too many requests. Please wait before trying again.';
    case 503:
      return l10n?.errorServiceUnavailable ??
          'Service temporarily unavailable. Please try again in a minute.';
    case 500:
    case 502:
    case 504:
      return l10n?.errorServer ?? 'Server error. Please try again later.';
    default:
      if (statusCode >= 400 && statusCode < 500) {
        return l10n?.errorClient ??
            'Client error. Please check your request and try again.';
      }
      if (statusCode >= 500) {
        return l10n?.errorServer ?? 'Server error. Please try again later.';
      }
      return null;
  }
}
