import 'package:flutter/material.dart';

/// Common error handling utilities to reduce code duplication
class ErrorHandling {
  ErrorHandling._();

  /// Show a snackbar with error message
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle common Cubit errors with user-friendly messages
  static void handleCubitError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final String message = customMessage ?? _getErrorMessage(error);

    final SnackBarAction? action = onRetry != null
        ? SnackBarAction(label: 'Retry', onPressed: onRetry)
        : null;

    showErrorSnackBar(context, message, action: action);
  }

  /// Get user-friendly error message from various error types
  static String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

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
      return 'Access denied. You don\'t have permission for this action.';
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

  /// Clear all current snackbars
  static void clearSnackBars(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Show a loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
