import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

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
    final bool isCupertino = PlatformAdaptive.isCupertino(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) {
        if (isCupertino) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () => NavigationUtils.maybePop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        }
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            PlatformAdaptive.dialogAction(
              context: dialogContext,
              label: 'OK',
              onPressed: () => NavigationUtils.maybePop(dialogContext),
            ),
          ],
        );
      },
    );
  }
}
