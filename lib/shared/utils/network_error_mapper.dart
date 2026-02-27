import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/error_codes.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';

/// Centralized error mapper for consistent error message handling
/// across both UI layer and repository layer.
///
/// Differentiates error types (auth vs server vs service unavailable) so
/// users see accurate messages and we avoid retry storms (e.g. "Service
/// temporarily unavailable" instead of "Authentication failed" when backend
/// is down).
///
/// When l10n is provided (e.g. from UI), returns localized messages.
/// When l10n is null (e.g. repository layer), returns English fallbacks.
class NetworkErrorMapper {
  NetworkErrorMapper._();

  /// Get user-friendly error message from various error types.
  ///
  /// For [HttpRequestFailure], uses [getMessageForStatusCode] so 401 vs 503
  /// are differentiated. Pass [l10n] from UI for localized messages.
  static String getErrorMessage(
    final dynamic error, {
    final AppLocalizations? l10n,
  }) {
    if (error == null) {
      return l10n?.errorUnknown ?? 'An unknown error occurred';
    }

    if (error is HttpRequestFailure) {
      if (_hasExplicitStatusMessage(error.statusCode)) {
        final String? statusMessage = getMessageForStatusCode(
          error.statusCode,
          l10n: l10n,
        );
        if (statusMessage != null) {
          return statusMessage;
        }
      }

      if (error.message.trim().isNotEmpty) {
        return error.message;
      }

      final String? statusMessage = getMessageForStatusCode(
        error.statusCode,
        l10n: l10n,
      );
      if (statusMessage != null) {
        return statusMessage;
      }

      return l10n?.errorGeneric ?? 'Something went wrong.';
    }

    final String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return l10n?.errorNetwork ??
          'Network connection error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return l10n?.errorTimeout ?? 'Request timed out. Please try again.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return l10n?.errorUnauthorized ??
          'Authentication required. Please sign in again.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return l10n?.errorForbidden ??
          "Access denied. You don't have permission for this action.";
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return l10n?.errorNotFound ?? 'The requested resource was not found.';
    }

    if (errorString.contains('too many requests') ||
        errorString.contains('429')) {
      return l10n?.errorTooManyRequests ??
          'Too many requests. Please wait before trying again.';
    }

    if (errorString.contains('service unavailable') ||
        errorString.contains('503')) {
      return l10n?.errorServiceUnavailable ??
          'Service temporarily unavailable. Please try again in a minute.';
    }

    final int? extractedStatusCode = _extractHttpStatusCode(errorString);
    if (extractedStatusCode case final int statusCode) {
      final String? statusMessage = getMessageForStatusCode(
        statusCode,
        l10n: l10n,
      );
      if (statusMessage != null) {
        return statusMessage;
      }
    }

    if (errorString.contains('server')) {
      return l10n?.errorServer ?? 'Server error. Please try again later.';
    }

    return l10n?.errorGeneric ?? 'Something went wrong. Please try again.';
  }

  /// Map HTTP status code to [AppErrorCode] for branching and analytics.
  static AppErrorCode getErrorCodeForStatusCode(final int statusCode) {
    switch (statusCode) {
      case 401:
        return AppErrorCode.auth;
      case 403:
      case 404:
        return AppErrorCode.client;
      case 408:
        return AppErrorCode.timeout;
      case 429:
        return AppErrorCode.rateLimit;
      case 503:
        return AppErrorCode.serviceUnavailable;
      case 500:
      case 502:
      case 504:
        return AppErrorCode.server;
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return AppErrorCode.client;
        }
        if (statusCode >= 500) {
          return AppErrorCode.server;
        }
        return AppErrorCode.unknown;
    }
  }

  /// Get [AppErrorCode] from an error (e.g. [HttpRequestFailure] or generic).
  static AppErrorCode getErrorCode(final dynamic error) {
    if (error is HttpRequestFailure) {
      return getErrorCodeForStatusCode(error.statusCode);
    }
    if (error == null) {
      return AppErrorCode.unknown;
    }
    final String s = error.toString().toLowerCase();

    if (s.contains('network') || s.contains('connection')) {
      return AppErrorCode.network;
    }
    if (s.contains('timeout')) {
      return AppErrorCode.timeout;
    }
    final int? extractedStatusCode = _extractHttpStatusCode(s);
    if (extractedStatusCode case final int statusCode) {
      return getErrorCodeForStatusCode(statusCode);
    }
    if (s.contains('401') || s.contains('unauthorized')) {
      return AppErrorCode.auth;
    }
    if (s.contains('403') || s.contains('404') || s.contains('forbidden')) {
      return AppErrorCode.client;
    }
    if (s.contains('503') || s.contains('service unavailable')) {
      return AppErrorCode.serviceUnavailable;
    }
    if (s.contains('429') || s.contains('too many requests')) {
      return AppErrorCode.rateLimit;
    }
    if (s.contains('500') ||
        s.contains('502') ||
        s.contains('504') ||
        s.contains('server')) {
      return AppErrorCode.server;
    }
    if (s.contains('client') || s.contains('bad request')) {
      return AppErrorCode.client;
    }
    return AppErrorCode.unknown;
  }

  static int? _extractHttpStatusCode(final String value) {
    final RegExpMatch? match = RegExp(r'\b([1-5]\d{2})\b').firstMatch(value);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1) ?? '');
  }

  static bool _hasExplicitStatusMessage(final int statusCode) {
    switch (statusCode) {
      case 401:
      case 403:
      case 404:
      case 408:
      case 429:
      case 500:
      case 502:
      case 503:
      case 504:
        return true;
      default:
        return false;
    }
  }

  /// Map HTTP status code to user-friendly error message.
  ///
  /// Pass [l10n] for localized messages; omit for English fallback.
  /// Returns null if the status code doesn't map to a known error.
  static String? getMessageForStatusCode(
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

  /// Check if an error indicates a network connectivity issue.
  static bool isNetworkError(final dynamic error) {
    if (error == null) return false;
    final String errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('dns');
  }

  /// Check if an error indicates a timeout.
  static bool isTimeoutError(final dynamic error) {
    if (error == null) return false;
    final String errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') || errorString.contains('timed out');
  }

  /// Check if an HTTP status code indicates a transient error (should retry).
  static bool isTransientError(final int statusCode) =>
      statusCode == 408 || // Request Timeout
      statusCode == 429 || // Too Many Requests
      statusCode == 500 || // Internal Server Error
      statusCode == 502 || // Bad Gateway
      statusCode == 503 || // Service Unavailable
      statusCode == 504; // Gateway Timeout
}
