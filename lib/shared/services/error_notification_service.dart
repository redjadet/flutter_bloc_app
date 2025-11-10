import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

abstract class ErrorNotificationService {
  Future<void> showSnackBar(final BuildContext context, final String message);
  Future<void> showAlertDialog(
    final BuildContext context,
    final String title,
    final String message,
  );
}

class SnackbarErrorNotificationService implements ErrorNotificationService {
  @override
  Future<void> showSnackBar(
    final BuildContext context,
    final String message,
  ) async {
    if (!context.mounted) {
      AppLogger.debug(
        'Skipping SnackBar error message – context no longer mounted.',
      );
      return;
    }
    AppLogger.info('Showing SnackBar error message');
    ErrorHandling.clearSnackBars(context);
    final controller = ErrorHandling.showErrorSnackBar(context, message);
    if (controller == null) {
      AppLogger.debug(
        'Skipping SnackBar error message – no ScaffoldMessenger available.',
      );
      return;
    }
    await controller.closed;
  }

  @override
  Future<void> showAlertDialog(
    final BuildContext context,
    final String title,
    final String message,
  ) {
    if (!context.mounted) {
      AppLogger.debug(
        'Skipping AlertDialog error message – context no longer mounted.',
      );
      return Future<void>.value();
    }
    AppLogger.info('Showing AlertDialog error message');
    return showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
