part of 'network_error_mapper.dart';

AppErrorCode _getErrorCodeForStatusCode(int statusCode) => switch (statusCode) {
  401 => AppErrorCode.auth,
  403 || 404 => AppErrorCode.client,
  408 => AppErrorCode.timeout,
  429 => AppErrorCode.rateLimit,
  503 => AppErrorCode.serviceUnavailable,
  500 || 502 || 504 => AppErrorCode.server,
  >= 400 && < 500 => AppErrorCode.client,
  >= 500 => AppErrorCode.server,
  _ => AppErrorCode.unknown,
};

AppErrorCode _getErrorCode(dynamic error) {
  if (error case HttpRequestFailure(:final statusCode)) {
    return _getErrorCodeForStatusCode(statusCode);
  }

  if (error case DioException(response: Response(:final statusCode?))) {
    return _getErrorCodeForStatusCode(statusCode);
  }

  if (error case DioException(:final type)) {
    final AppErrorCode? code = switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => AppErrorCode.timeout,
      DioExceptionType.connectionError => AppErrorCode.network,
      _ => null,
    };
    if (code != null) {
      return code;
    }
  }

  if (error == null) {
    return AppErrorCode.unknown;
  }

  final String errorString = error.toString().toLowerCase();
  if (_containsNetworkHint(errorString)) {
    return AppErrorCode.network;
  }
  if (_containsTimeoutHint(errorString)) {
    return AppErrorCode.timeout;
  }

  final int? extractedStatusCode = _extractHttpStatusCode(errorString);
  if (extractedStatusCode case final int statusCode) {
    return _getErrorCodeForStatusCode(statusCode);
  }

  if (_containsUnauthorizedHint(errorString)) {
    return AppErrorCode.auth;
  }
  if (_containsForbiddenHint(errorString) ||
      _containsNotFoundHint(errorString) ||
      errorString.contains('client') ||
      errorString.contains('bad request')) {
    return AppErrorCode.client;
  }
  if (_containsServiceUnavailableHint(errorString)) {
    return AppErrorCode.serviceUnavailable;
  }
  if (_containsRateLimitHint(errorString)) {
    return AppErrorCode.rateLimit;
  }
  if (_containsServerHint(errorString)) {
    return AppErrorCode.server;
  }
  return AppErrorCode.unknown;
}

int? _extractHttpStatusCode(String value) {
  final RegExpMatch? match = RegExp(r'\b([1-5]\d{2})\b').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1) ?? '');
}

bool _hasExplicitStatusMessage(int statusCode) => switch (statusCode) {
  401 || 403 || 404 || 408 || 429 || 500 || 502 || 503 || 504 => true,
  _ => false,
};

bool _isNetworkError(dynamic error) {
  if (error == null) return false;
  if (error is DioException && error.type == DioExceptionType.connectionError) {
    return true;
  }

  final String errorString = error.toString().toLowerCase();
  return _containsNetworkHint(errorString) ||
      errorString.contains('socket') ||
      errorString.contains('dns');
}

bool _isTimeoutError(dynamic error) {
  if (error == null) return false;
  if (error case DioException(:final type)) {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => true,
      _ =>
        _containsTimeoutHint(error.toString().toLowerCase()) ||
            error.toString().toLowerCase().contains('timed out'),
    };
  }

  return _containsTimeoutHint(error.toString().toLowerCase()) ||
      error.toString().toLowerCase().contains('timed out');
}

bool _isTransientError(int statusCode) =>
    statusCode == 408 ||
    statusCode == 429 ||
    statusCode == 500 ||
    statusCode == 502 ||
    statusCode == 503 ||
    statusCode == 504;

bool _containsNetworkHint(String value) =>
    value.contains('network') || value.contains('connection');

bool _containsTimeoutHint(String value) => value.contains('timeout');

bool _containsUnauthorizedHint(String value) =>
    value.contains('unauthorized') || value.contains('401');

bool _containsForbiddenHint(String value) =>
    value.contains('forbidden') || value.contains('403');

bool _containsNotFoundHint(String value) =>
    value.contains('not found') || value.contains('404');

bool _containsRateLimitHint(String value) =>
    value.contains('too many requests') || value.contains('429');

bool _containsServiceUnavailableHint(String value) =>
    value.contains('service unavailable') || value.contains('503');

bool _containsServerHint(String value) =>
    value.contains('500') ||
    value.contains('502') ||
    value.contains('504') ||
    value.contains('server');
