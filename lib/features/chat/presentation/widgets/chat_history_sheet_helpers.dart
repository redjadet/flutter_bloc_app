import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

Future<bool> showClearHistoryDialog(
  final BuildContext context,
  final AppLocalizations l10n,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(l10n.chatHistoryClearAll),
        content: Text(l10n.chatHistoryClearAllWarning),
        actions: <Widget>[
          PlatformAdaptive.dialogAction(
            context: context,
            label: l10n.cancelButtonLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          PlatformAdaptive.dialogAction(
            context: context,
            label: l10n.deleteButtonLabel,
            isDestructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
    false;

Future<bool> showDeleteConversationDialog(
  final BuildContext context,
  final AppLocalizations l10n,
  final String conversationTitle,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(l10n.chatHistoryDeleteConversation),
        content: Text(
          l10n.chatHistoryDeleteConversationWarning(conversationTitle),
        ),
        actions: <Widget>[
          PlatformAdaptive.dialogAction(
            context: context,
            label: l10n.cancelButtonLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          PlatformAdaptive.dialogAction(
            context: context,
            label: l10n.deleteButtonLabel,
            isDestructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
    false;

String conversationTitle(
  final AppLocalizations l10n,
  final int index,
  final ChatConversation conversation,
) => conversation.model ?? l10n.chatHistoryConversationTitle(index + 1);

String formatTimestamp(
  final MaterialLocalizations localizations,
  final DateTime timestamp,
) {
  final String date = localizations.formatMediumDate(timestamp);
  final TimeOfDay time = TimeOfDay.fromDateTime(timestamp);
  final String formattedTime = localizations.formatTimeOfDay(time);
  return '$date · $formattedTime';
}
