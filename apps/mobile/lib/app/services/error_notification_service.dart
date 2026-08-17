import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:flutter_bloc_app/app/utils/error_handling.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:material_ui/material_ui.dart';

abstract class ErrorNotificationService {
  Future<void> showSnackBar(BuildContext context, String message);
  Future<void> showAlertDialog(
    BuildContext context,
    String title,
    String message,
  );
}

class SnackbarErrorNotificationService implements ErrorNotificationService {
  @override
  Future<void> showSnackBar(
    BuildContext context,
    String message,
  ) async {
    if (!context.mounted) {
      ContextUtils.logNotMounted(
        'SnackbarErrorNotificationService.showSnackBar',
      );
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
    BuildContext context,
    String title,
    String message,
  ) {
    if (!context.mounted) {
      ContextUtils.logNotMounted(
        'SnackbarErrorNotificationService.showAlertDialog',
      );
      AppLogger.debug(
        'Skipping AlertDialog error message – context no longer mounted.',
      );
      return Future<void>.value();
    }
    AppLogger.info('Showing AlertDialog error message');
    final bool isCupertino = PlatformAdaptive.isCupertino(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (dialogContext) {
        if (isCupertino) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () => NavigationUtils.maybePop(dialogContext),
                child: Text(dialogContext.l10n.okButtonLabel),
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
              label: dialogContext.l10n.okButtonLabel,
              onPressed: () => NavigationUtils.maybePop(dialogContext),
            ),
          ],
        );
      },
    );
  }
}
