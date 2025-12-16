/// Centralized error mapper for consistent error message handling
/// across both UI layer and repository layer.
///
/// Extracted from `ErrorHandling._getErrorMessage()` to enable reuse
/// in repository layer for consistent error handling.
class NetworkErrorMapper {
  NetworkErrorMapper._();

  /// Get user-friendly error message from various error types.
  ///
  /// Maps common error patterns (network, timeout, HTTP status codes)
  /// to user-friendly messages that can be used in both UI and logging.
  static String getErrorMessage(final dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    final String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Authentication required. Please sign in again.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return "Access denied. You don't have permission for this action.";
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('server') || errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }

    // Default fallback
    return 'Something went wrong. Please try again.';
  }

  /// Map HTTP status code to user-friendly error message.
  ///
  /// Returns null if the status code doesn't map to a known error.
  static String? getMessageForStatusCode(final int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Authentication required. Please sign in again.';
      case 403:
        return "Access denied. You don't have permission for this action.";
      case 404:
        return 'The requested resource was not found.';
      case 408:
        return 'Request timed out. Please try again.';
      case 429:
        return 'Too many requests. Please wait before trying again.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server error. Please try again later.';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return 'Client error. Please check your request and try again.';
        }
        if (statusCode >= 500) {
          return 'Server error. Please try again later.';
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
