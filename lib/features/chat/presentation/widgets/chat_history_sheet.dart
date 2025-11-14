import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_conversation_tile.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_empty_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

@immutable
class _HistorySheetData extends Equatable {
  const _HistorySheetData({
    required this.history,
    required this.hasHistory,
    required this.activeConversationId,
  });

  final List<ChatConversation> history;
  final bool hasHistory;
  final String? activeConversationId;

  @override
  List<Object?> get props => [history, hasHistory, activeConversationId];
}

class ChatHistorySheet extends StatelessWidget {
  const ChatHistorySheet({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ChatCubit cubit = context.read<ChatCubit>();

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
                  child: BlocSelector<ChatCubit, ChatState, _HistorySheetData>(
                    selector: (final state) => _HistorySheetData(
                      history: state.history,
                      hasHistory: state.hasHistory,
                      activeConversationId: state.activeConversationId,
                    ),
                    builder: (final context, final data) {
                      final List<ChatConversation> conversations = data.history;

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
                          PlatformAdaptive.textButton(
                            context: context,
                            onPressed: () async {
                              await cubit.resetConversation();
                              onClose();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add),
                                SizedBox(
                                  width: context.responsiveHorizontalGapS,
                                ),
                                Text(l10n.chatHistoryStartNew),
                              ],
                            ),
                          ),
                          PlatformAdaptive.textButton(
                            context: context,
                            onPressed: data.hasHistory
                                ? () async {
                                    final bool confirmed =
                                        await showClearHistoryDialog(context);
                                    if (!confirmed) return;
                                    await cubit.clearHistory();
                                    onClose();
                                  }
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_outline),
                                SizedBox(
                                  width: context.responsiveHorizontalGapS,
                                ),
                                Text(l10n.chatHistoryClearAll),
                              ],
                            ),
                          ),
                          SizedBox(height: context.responsiveGapS),
                          Expanded(
                            child: data.hasHistory
                                ? ListView.separated(
                                    itemBuilder: (final context, final index) {
                                      final ChatConversation conversation =
                                          conversations[index];
                                      final bool isActive =
                                          conversation.id ==
                                          data.activeConversationId;
                                      return ChatHistoryConversationTile(
                                        conversation: conversation,
                                        index: index,
                                        isActive: isActive,
                                        onClose: onClose,
                                      );
                                    },
                                    separatorBuilder: (final context, _) =>
                                        SizedBox(
                                          height: context.responsiveGapS,
                                        ),
                                    itemCount: conversations.length,
                                  )
                                : ChatHistoryEmptyState(l10n: l10n),
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
