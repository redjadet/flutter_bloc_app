import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

Future<bool> showClearHistoryDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.chatHistoryClearAll),
          content: Text(l10n.chatHistoryClearAllWarning),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteButtonLabel),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> showDeleteConversationDialog(
  BuildContext context,
  AppLocalizations l10n,
  String conversationTitle,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.chatHistoryDeleteConversation),
          content: Text(
            l10n.chatHistoryDeleteConversationWarning(conversationTitle),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteButtonLabel),
            ),
          ],
        ),
      ) ??
      false;
}

String conversationTitle(
  AppLocalizations l10n,
  int index,
  ChatConversation conversation,
) {
  return conversation.model ?? l10n.chatHistoryConversationTitle(index + 1);
}

String formatTimestamp(
  MaterialLocalizations localizations,
  DateTime timestamp,
) {
  final String date = localizations.formatMediumDate(timestamp);
  final TimeOfDay time = TimeOfDay.fromDateTime(timestamp);
  final String formattedTime = localizations.formatTimeOfDay(time);
  return '$date · $formattedTime';
}
