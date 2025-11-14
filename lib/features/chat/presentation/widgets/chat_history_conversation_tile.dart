import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChatHistoryConversationTile extends StatelessWidget {
  const ChatHistoryConversationTile({
    required this.conversation,
    required this.index,
    required this.isActive,
    required this.onClose,
    super.key,
  });

  final ChatConversation conversation;
  final int index;
  final bool isActive;
  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cubit = context.read<ChatCubit>();
    final materialLocalizations = MaterialLocalizations.of(context);

    final String timestamp = formatTimestamp(
      materialLocalizations,
      conversation.updatedAt,
    );
    final String title = conversationTitle(
      l10n,
      index,
      conversation,
    );
    final String? preview = conversation.messages.isNotEmpty
        ? conversation.messages.last.text
        : null;

    final Color baseTextColor = isActive
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return ListTile(
      onTap: () {
        cubit.selectConversation(conversation.id);
        onClose();
      },
      trailing: IconButton(
        tooltip: l10n.chatHistoryDeleteConversation,
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final bool confirmed = await showDeleteConversationDialog(
            context,
            l10n,
            title,
          );
          if (!confirmed) return;
          await cubit.deleteConversation(conversation.id);
        },
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
      ),
      tileColor: isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(color: baseTextColor),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.chatHistoryUpdatedAt(timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive
                  ? baseTextColor.withValues(alpha: 0.85)
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (preview != null && preview.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: context.responsiveGapXS),
              child: Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: baseTextColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
