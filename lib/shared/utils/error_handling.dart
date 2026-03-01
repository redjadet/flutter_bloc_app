import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/network_error_mapper.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Common error handling utilities to reduce code duplication
class ErrorHandling {
  ErrorHandling._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _showSnackBar(
    final BuildContext context,
    final SnackBar snackBar,
  ) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ErrorHandling._showSnackBar');
      return null;
    }
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
      persist: false,
      action: action,
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// Show a success snackbar using theme colors.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  showSuccessSnackBar(
    final BuildContext context,
    final String message, {
    final Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ErrorHandling.showSuccessSnackBar');
      return null;
    }
    final ColorScheme colors = Theme.of(context).colorScheme;
    return _showSnackBar(
      context,
      SnackBar(
        content: Text(message),
        duration: duration,
        persist: false,
        backgroundColor: colors.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle common Cubit errors with user-friendly messages.
  ///
  /// Uses BuildContext l10n for localized error message and retry button label.
  static void handleCubitError(
    final BuildContext context,
    final dynamic error, {
    final String? customMessage,
    final VoidCallback? onRetry,
  }) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ErrorHandling.handleCubitError');
      return;
    }
    final String message =
        customMessage ??
        NetworkErrorMapper.getErrorMessage(error, l10n: context.l10n);

    final SnackBarAction? action = onRetry != null
        ? SnackBarAction(
            label: context.l10n.retryButtonLabel,
            onPressed: onRetry,
          )
        : null;

    showErrorSnackBar(context, message, action: action);
  }

  /// Clear all current snackbars
  static void clearSnackBars(final BuildContext context) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ErrorHandling.clearSnackBars');
      return;
    }
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
    if (!context.mounted) {
      ContextUtils.logNotMounted('ErrorHandling.showLoadingDialog');
      return;
    }

    await showAdaptiveDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (final dialogContext) {
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
    if (!context.mounted) {
      ContextUtils.logNotMounted('ErrorHandling.hideLoadingDialog');
      return;
    }
    NavigationUtils.maybePop(
      context,
      useRootNavigator: true,
    );
  }
}
