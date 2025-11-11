import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
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
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.registerTermsRejectButton),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.registerTermsRejectButton),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.registerTermsAcceptButton),
        ),
      ],
    );
  }
}
