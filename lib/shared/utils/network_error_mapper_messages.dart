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
}) {
  switch (statusCode) {
    case 401:
      return _authMessage(AuthErrorKind.unauthorized, l10n: l10n);
    case 403:
      return _authMessage(AuthErrorKind.forbidden, l10n: l10n);
    case 404:
      return _notFoundMessage(l10n: l10n);
    case 408:
      return _networkMessage(NetworkErrorKind.timeout, l10n: l10n);
    case 429:
      return _networkMessage(NetworkErrorKind.rateLimited, l10n: l10n);
    case 503:
      return _networkMessage(
        NetworkErrorKind.serviceUnavailable,
        l10n: l10n,
      );
    case 500:
    case 502:
    case 504:
      return _networkMessage(NetworkErrorKind.server, l10n: l10n);
    default:
      if (statusCode >= 400 && statusCode < 500) {
        return _networkMessage(NetworkErrorKind.client, l10n: l10n);
      }
      if (statusCode >= 500) {
        return _networkMessage(NetworkErrorKind.server, l10n: l10n);
      }
      return null;
  }
}

String? _networkMessage(
  final NetworkErrorKind kind, {
  final Object? originalError,
  final AppLocalizations? l10n,
}) {
  switch (kind) {
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
        return _notFoundMessage(l10n: l10n);
      }
      return l10n?.errorClient ??
          'Client error. Please check your request and try again.';
    case NetworkErrorKind.unknown:
      return null;
  }
}

String _authMessage(
  final AuthErrorKind kind, {
  final AppLocalizations? l10n,
}) {
  switch (kind) {
    case AuthErrorKind.unauthorized:
    case AuthErrorKind.tokenExpired:
      return l10n?.errorUnauthorized ??
          'Authentication required. Please sign in again.';
    case AuthErrorKind.forbidden:
      return l10n?.errorForbidden ??
          "Access denied. You don't have permission for this action.";
  }
}

String _notFoundMessage({final AppLocalizations? l10n}) =>
    l10n?.errorNotFound ?? 'The requested resource was not found.';
