import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Common error handling utilities to reduce code duplication
class ErrorHandling {
  ErrorHandling._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _showSnackBar(
    final BuildContext context,
    final SnackBar snackBar,
  ) {
    if (!context.mounted) return null;
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) {
      return null;
    }
    return messenger.showSnackBar(snackBar);
  }

  /// Show a snackbar with error message
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  showErrorSnackBar(
    final BuildContext context,
    final String message, {
    final Duration duration = const Duration(seconds: 4),
    final SnackBarAction? action,
  }) => _showSnackBar(
    context,
    SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// Show a success snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  showSuccessSnackBar(
    final BuildContext context,
    final String message, {
    final Duration duration = const Duration(seconds: 3),
  }) => _showSnackBar(
    context,
    SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// Handle common Cubit errors with user-friendly messages
  static void handleCubitError(
    final BuildContext context,
    final dynamic error, {
    final String? customMessage,
    final VoidCallback? onRetry,
  }) {
    final String message = customMessage ?? _getErrorMessage(error);

    final SnackBarAction? action = onRetry != null
        ? SnackBarAction(label: 'Retry', onPressed: onRetry)
        : null;

    showErrorSnackBar(context, message, action: action);
  }

  /// Get user-friendly error message from various error types
  static String _getErrorMessage(final dynamic error) {
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

  /// Clear all current snackbars
  static void clearSnackBars(final BuildContext context) {
    if (!context.mounted) return;
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    messenger?.clearSnackBars();
  }

  /// Show a loading dialog
  static Future<void> showLoadingDialog(
    final BuildContext context,
    final String message,
  ) async {
    if (!context.mounted) return;

    await showAdaptiveDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext dialogContext) {
        final bool isCupertino = PlatformAdaptive.isCupertino(context);
        if (isCupertino) {
          return CupertinoAlertDialog(
            content: Row(
              children: [
                const CupertinoActivityIndicator(),
                SizedBox(width: context.responsiveHorizontalGapL),
                Expanded(child: Text(message)),
              ],
            ),
          );
        }
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              SizedBox(width: context.responsiveHorizontalGapL),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(final BuildContext context) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
