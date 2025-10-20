import 'package:flutter/material.dart';
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
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) {
      AppLogger.debug(
        'Skipping SnackBar error message – no ScaffoldMessenger available.',
      );
      return;
    }
    AppLogger.info('Showing SnackBar error message');
    messenger.hideCurrentSnackBar();
    await messenger
        .showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        )
        .closed;
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
