import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

Future<bool?> showTodoDeleteConfirmDialog({
  required final BuildContext context,
  required final String title,
}) async {
  final l10n = context.l10n;
  final bool isCupertino = PlatformAdaptive.isCupertino(context);
  return showAdaptiveDialog<bool>(
    context: context,
    builder: (final context) => isCupertino
        ? CupertinoAlertDialog(
            title: Text(l10n.todoListDeleteDialogTitle),
            content: Padding(
              padding: EdgeInsets.only(top: context.responsiveGapS),
              child: Text(
                l10n.todoListDeleteDialogMessage(title),
              ),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(false),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(true),
                label: l10n.todoListDeleteAction,
                isDestructive: true,
              ),
            ],
          )
        : AlertDialog(
            title: Text(l10n.todoListDeleteDialogTitle),
            content: Text(
              l10n.todoListDeleteDialogMessage(title),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(false),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(true),
                label: l10n.todoListDeleteAction,
                isDestructive: true,
              ),
            ],
          ),
  );
}

Future<bool?> showTodoBatchDeleteConfirmDialog({
  required final BuildContext context,
  required final int count,
}) async {
  final l10n = context.l10n;
  final bool isCupertino = PlatformAdaptive.isCupertino(context);
  return showAdaptiveDialog<bool>(
    context: context,
    builder: (final context) => isCupertino
        ? CupertinoAlertDialog(
            title: Text(l10n.todoListBatchDeleteDialogTitle),
            content: Padding(
              padding: EdgeInsets.only(top: context.responsiveGapS),
              child: Text(
                l10n.todoListBatchDeleteDialogMessage(count),
              ),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(false),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(true),
                label: l10n.todoListDeleteAction,
                isDestructive: true,
              ),
            ],
          )
        : AlertDialog(
            title: Text(l10n.todoListBatchDeleteDialogTitle),
            content: Text(
              l10n.todoListBatchDeleteDialogMessage(count),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(false),
                label: l10n.todoListCancelAction,
              ),
              PlatformAdaptive.dialogAction(
                context: context,
                onPressed: () => Navigator.of(context).pop(true),
                label: l10n.todoListDeleteAction,
                isDestructive: true,
              ),
            ],
          ),
  );
}
