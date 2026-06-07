part of 'network_error_mapper.dart';

String? _getTypedErrorMessage(
  final AppError appError, {
  required final dynamic originalError,
  required final AppLocalizations? l10n,
}) {
  if (appError case final NetworkError networkError) {
    return _networkMessage(
      networkError.kind,
      originalError: originalError,
      l10n: l10n,
    );
  }

  if (appError case final AuthError authError) {
    return _authMessage(authError.kind, l10n: l10n);
  }

  return null;
}

String? _getHeuristicMessage(
  final String errorString, {
  required final AppLocalizations? l10n,
}) {
  if (_containsNetworkHint(errorString)) {
    return _networkMessage(NetworkErrorKind.offline, l10n: l10n);
  }

  if (_containsTimeoutHint(errorString)) {
    return _networkMessage(NetworkErrorKind.timeout, l10n: l10n);
  }

  if (_containsUnauthorizedHint(errorString)) {
    return _authMessage(AuthErrorKind.unauthorized, l10n: l10n);
  }

  if (_containsForbiddenHint(errorString)) {
    return _authMessage(AuthErrorKind.forbidden, l10n: l10n);
  }

  if (_containsNotFoundHint(errorString)) {
    return _networkMessage(
      NetworkErrorKind.client,
      originalError: '404',
      l10n: l10n,
    );
  }

  if (_containsRateLimitHint(errorString)) {
    return _networkMessage(NetworkErrorKind.rateLimited, l10n: l10n);
  }

  if (_containsServiceUnavailableHint(errorString)) {
    return _networkMessage(
      NetworkErrorKind.serviceUnavailable,
      l10n: l10n,
    );
  }

  if (errorString.contains('server')) {
    return _networkMessage(NetworkErrorKind.server, l10n: l10n);
  }

  return null;
}

String? _getMessageForStatusCode(
  final int statusCode, {
  final AppLocalizations? l10n,
}) => switch (statusCode) {
  401 => _authMessage(AuthErrorKind.unauthorized, l10n: l10n),
  403 => _authMessage(AuthErrorKind.forbidden, l10n: l10n),
  404 => _notFoundMessage(l10n: l10n),
  408 => _networkMessage(NetworkErrorKind.timeout, l10n: l10n),
  429 => _networkMessage(NetworkErrorKind.rateLimited, l10n: l10n),
  503 => _networkMessage(
    NetworkErrorKind.serviceUnavailable,
    l10n: l10n,
  ),
  500 || 502 || 504 => _networkMessage(NetworkErrorKind.server, l10n: l10n),
  >= 400 && < 500 => _networkMessage(NetworkErrorKind.client, l10n: l10n),
  >= 500 => _networkMessage(NetworkErrorKind.server, l10n: l10n),
  _ => null,
};

String? _networkMessage(
  final NetworkErrorKind kind, {
  final Object? originalError,
  final AppLocalizations? l10n,
}) => switch (kind) {
  NetworkErrorKind.timeout =>
    l10n?.errorTimeout ?? 'Request timed out. Please try again.',
  NetworkErrorKind.offline =>
    l10n?.errorNetwork ??
        'Network connection error. Please check your internet connection.',
  NetworkErrorKind.serviceUnavailable =>
    l10n?.errorServiceUnavailable ??
        'Service temporarily unavailable. Please try again in a minute.',
  NetworkErrorKind.rateLimited =>
    l10n?.errorTooManyRequests ??
        'Too many requests. Please wait before trying again.',
  NetworkErrorKind.server =>
    l10n?.errorServer ?? 'Server error. Please try again later.',
  NetworkErrorKind.client when originalError.toString().contains('404') =>
    _notFoundMessage(l10n: l10n),
  NetworkErrorKind.client =>
    l10n?.errorClient ??
        'Client error. Please check your request and try again.',
  NetworkErrorKind.unknown => null,
};

String _authMessage(
  final AuthErrorKind kind, {
  final AppLocalizations? l10n,
}) => switch (kind) {
  AuthErrorKind.unauthorized || AuthErrorKind.tokenExpired =>
    l10n?.errorUnauthorized ?? 'Authentication required. Please sign in again.',
  AuthErrorKind.forbidden =>
    l10n?.errorForbidden ??
        "Access denied. You don't have permission for this action.",
};

String _notFoundMessage({final AppLocalizations? l10n}) =>
    l10n?.errorNotFound ?? 'The requested resource was not found.';
