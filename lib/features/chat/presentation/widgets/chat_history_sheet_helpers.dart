import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

Future<bool> showClearHistoryDialog(
  final BuildContext context,
) async {
  final l10n = context.l10n;
  final bool isCupertino = PlatformAdaptive.isCupertino(context);
  return await showAdaptiveDialog<bool>(
        context: context,
        builder: (final dialogContext) {
          if (isCupertino) {
            return CupertinoAlertDialog(
              title: Text(l10n.chatHistoryClearAll),
              content: Text(l10n.chatHistoryClearAllWarning),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () =>
                      NavigationUtils.maybePop(dialogContext, result: false),
                  child: Text(l10n.cancelButtonLabel),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () =>
                      NavigationUtils.maybePop(dialogContext, result: true),
                  child: Text(l10n.deleteButtonLabel),
                ),
              ],
            );
          }
          return AlertDialog(
            title: Text(l10n.chatHistoryClearAll),
            content: Text(l10n.chatHistoryClearAllWarning),
            actions: <Widget>[
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.cancelButtonLabel,
                onPressed: () =>
                    NavigationUtils.maybePop(dialogContext, result: false),
              ),
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.deleteButtonLabel,
                isDestructive: true,
                onPressed: () =>
                    NavigationUtils.maybePop(dialogContext, result: true),
              ),
            ],
          );
        },
      ) ??
      false;
}

Future<bool> showDeleteConversationDialog(
  final BuildContext context,
  final String conversationTitle,
) async {
  final l10n = context.l10n;
  final bool isCupertino = PlatformAdaptive.isCupertino(context);
  return await showAdaptiveDialog<bool>(
        context: context,
        builder: (final dialogContext) {
          if (isCupertino) {
            return CupertinoAlertDialog(
              title: Text(l10n.chatHistoryDeleteConversation),
              content: Text(
                l10n.chatHistoryDeleteConversationWarning(conversationTitle),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () =>
                      NavigationUtils.maybePop(dialogContext, result: false),
                  child: Text(l10n.cancelButtonLabel),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () =>
                      NavigationUtils.maybePop(dialogContext, result: true),
                  child: Text(l10n.deleteButtonLabel),
                ),
              ],
            );
          }
          return AlertDialog(
            title: Text(l10n.chatHistoryDeleteConversation),
            content: Text(
              l10n.chatHistoryDeleteConversationWarning(conversationTitle),
            ),
            actions: <Widget>[
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.cancelButtonLabel,
                onPressed: () =>
                    NavigationUtils.maybePop(dialogContext, result: false),
              ),
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.deleteButtonLabel,
                isDestructive: true,
                onPressed: () =>
                    NavigationUtils.maybePop(dialogContext, result: true),
              ),
            ],
          );
        },
      ) ??
      false;
}

String conversationTitle(
  final BuildContext context,
  final int index,
  final ChatConversation conversation,
) {
  final l10n = context.l10n;
  return conversation.model ?? l10n.chatHistoryConversationTitle(index + 1);
}

String formatTimestamp(
  final MaterialLocalizations localizations,
  final DateTime timestamp,
) {
  final String date = localizations.formatMediumDate(timestamp);
  final TimeOfDay time = TimeOfDay.fromDateTime(timestamp);
  final String formattedTime = localizations.formatTimeOfDay(time);
  return '$date · $formattedTime';
}
