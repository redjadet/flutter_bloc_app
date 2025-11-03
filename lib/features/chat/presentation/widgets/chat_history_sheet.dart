import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChatHistorySheet extends StatelessWidget {
  const ChatHistorySheet({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ChatCubit cubit = context.read<ChatCubit>();
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.responsiveCardRadius),
        ),
        child: Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.barMaxWidth),
                child: Padding(
                  key: const ValueKey('chat-history-sheet-content'),
                  padding: context.responsiveSheetPadding(),
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (final context, final state) {
                      final List<ChatConversation> conversations =
                          state.history;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  l10n.chatHistoryPanelTitle,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.chatHistoryHideTooltip,
                                onPressed: onClose,
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          SizedBox(height: context.responsiveGapS),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(l10n.chatHistoryStartNew),
                            onPressed: () async {
                              await cubit.resetConversation();
                              onClose();
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: Text(l10n.chatHistoryClearAll),
                            onPressed: state.hasHistory
                                ? () async {
                                    final bool confirmed =
                                        await showClearHistoryDialog(
                                          context,
                                          l10n,
                                        );
                                    if (!confirmed) return;
                                    await cubit.clearHistory();
                                    onClose();
                                  }
                                : null,
                          ),
                          SizedBox(height: context.responsiveGapS),
                          Expanded(
                            child: state.hasHistory
                                ? ListView.separated(
                                    itemBuilder: (final context, final index) {
                                      final ChatConversation conversation =
                                          conversations[index];
                                      final bool isActive =
                                          conversation.id ==
                                          state.activeConversationId;
                                      final String timestamp = formatTimestamp(
                                        materialLocalizations,
                                        conversation.updatedAt,
                                      );
                                      final String title = conversationTitle(
                                        l10n,
                                        index,
                                        conversation,
                                      );
                                      final String? preview =
                                          conversation.messages.isNotEmpty
                                          ? conversation.messages.last.text
                                          : null;

                                      final Color baseTextColor = isActive
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurface;

                                      return ListTile(
                                        onTap: () {
                                          cubit.selectConversation(
                                            conversation.id,
                                          );
                                          onClose();
                                        },
                                        trailing: IconButton(
                                          tooltip: l10n
                                              .chatHistoryDeleteConversation,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () async {
                                            final bool confirmed =
                                                await showDeleteConversationDialog(
                                                  context,
                                                  l10n,
                                                  title,
                                                );
                                            if (!confirmed) return;
                                            await cubit.deleteConversation(
                                              conversation.id,
                                            );
                                          },
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            context.responsiveCardRadius,
                                          ),
                                        ),
                                        tileColor: isActive
                                            ? theme.colorScheme.primaryContainer
                                            : theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        title: Text(
                                          title,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(color: baseTextColor),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              l10n.chatHistoryUpdatedAt(
                                                timestamp,
                                              ),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: isActive
                                                        ? baseTextColor
                                                              .withValues(
                                                                alpha: 0.85,
                                                              )
                                                        : theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                  ),
                                            ),
                                            if (preview != null &&
                                                preview.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: context.responsiveGapXS,
                                                ),
                                                child: Text(
                                                  preview,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: baseTextColor,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (final context, _) =>
                                        SizedBox(
                                          height: context.responsiveGapS,
                                        ),
                                    itemCount: conversations.length,
                                  )
                                : Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            context.responsiveHorizontalGapL,
                                      ),
                                      child: Text(
                                        l10n.chatHistoryEmpty,
                                        style: theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
