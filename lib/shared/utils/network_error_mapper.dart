import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Centralized error mapper for consistent error message handling
/// across both UI layer and repository layer.
///
/// When l10n is provided (e.g. from UI), returns localized messages.
/// When l10n is null (e.g. repository layer), returns English fallbacks.
class NetworkErrorMapper {
  NetworkErrorMapper._();

  /// Get user-friendly error message from various error types.
  ///
  /// Pass [l10n] from UI (e.g. context.l10n) for localized messages.
  /// Omit for repository layer; English fallback is used.
  static String getErrorMessage(
    final dynamic error, {
    final AppLocalizations? l10n,
  }) {
    if (error == null) {
      return l10n?.errorUnknown ?? 'An unknown error occurred';
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

    if (errorString.contains('server') || errorString.contains('500')) {
      return l10n?.errorServer ?? 'Server error. Please try again later.';
    }

    return l10n?.errorGeneric ?? 'Something went wrong. Please try again.';
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
      case 500:
      case 502:
      case 503:
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
