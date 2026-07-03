import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class RegisterTermsDialog extends StatelessWidget {
  const RegisterTermsDialog({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isCupertino = PlatformAdaptive.isCupertino(context);

    if (isCupertino) {
      return CupertinoAlertDialog(
        title: Text(l10n.registerTermsDialogTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SingleChildScrollView(
            child: Text(l10n.registerTermsDialogBody),
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => NavigationUtils.maybePop(context, result: false),
            child: Text(l10n.registerTermsRejectButton),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => NavigationUtils.maybePop(
              context,
              result: true,
            ),
            child: Text(l10n.registerTermsAcceptButton),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(l10n.registerTermsDialogTitle),
      content: SingleChildScrollView(
        child: Text(l10n.registerTermsDialogBody),
      ),
      actions: <Widget>[
        PlatformAdaptive.dialogAction(
          context: context,
          label: l10n.registerTermsRejectButton,
          onPressed: () => NavigationUtils.maybePop(context, result: false),
        ),
        PlatformAdaptive.dialogAction(
          context: context,
          label: l10n.registerTermsAcceptButton,
          onPressed: () => NavigationUtils.maybePop(context, result: true),
        ),
      ],
    );
  }
}
