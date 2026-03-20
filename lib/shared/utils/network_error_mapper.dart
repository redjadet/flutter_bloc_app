import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';
import 'package:flutter_bloc_app/shared/utils/error_codes.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';

part 'network_error_mapper_app_error.dart';
part 'network_error_mapper_classification.dart';
part 'network_error_mapper_messages.dart';

/// Centralized error mapper for consistent error message handling
/// across both UI layer and repository layer.
///
/// Differentiates error types (auth vs server vs service unavailable) so
/// users see accurate messages and we avoid retry storms (e.g. "Service
/// temporarily unavailable" instead of "Authentication failed" when backend
/// is down).
///
/// When l10n is provided (e.g. from UI), returns localized messages.
/// When l10n is null (e.g. repository layer), returns non-localized
/// English fallbacks intended for logging or repository-layer use.
class NetworkErrorMapper {
  NetworkErrorMapper._();

  /// Get user-friendly typed error from various error inputs.
  static AppError getAppError(final dynamic error) => _getAppError(error);

  /// Get user-friendly error message from various error inputs.
  static String getErrorMessage(
    final dynamic error, {
    final AppLocalizations? l10n,
  }) => _getErrorMessage(error, l10n: l10n);

  /// Map HTTP status code to [AppErrorCode] for branching and analytics.
  static AppErrorCode getErrorCodeForStatusCode(final int statusCode) =>
      _getErrorCodeForStatusCode(statusCode);

  /// Get [AppErrorCode] from an error (e.g. [HttpRequestFailure], [DioException] or generic).
  static AppErrorCode getErrorCode(final dynamic error) => _getErrorCode(error);

  /// Map HTTP status code to user-friendly error message.
  ///
  /// Pass [l10n] for localized messages; omit for English fallback.
  /// Returns null if the status code doesn't map to a known error.
  static String? getMessageForStatusCode(
    final int statusCode, {
    final AppLocalizations? l10n,
  }) => _getMessageForStatusCode(statusCode, l10n: l10n);

  /// Check if an error indicates a network connectivity issue.
  static bool isNetworkError(final dynamic error) => _isNetworkError(error);

  /// Check if an error indicates a timeout.
  static bool isTimeoutError(final dynamic error) => _isTimeoutError(error);

  /// Check if an HTTP status code indicates a transient error (should retry).
  static bool isTransientError(final int statusCode) =>
      _isTransientError(statusCode);
}
