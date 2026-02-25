import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_conversation_tile.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_empty_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';
import 'package:flutter_bloc_app/shared/widgets/icon_label_row.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_history_sheet.freezed.dart';

@freezed
abstract class _HistorySheetData with _$HistorySheetData {
  const factory _HistorySheetData({
    required final List<ChatConversation> history,
    required final bool hasHistory,
    required final String? activeConversationId,
    required final bool hasActiveMessages,
  }) = __HistorySheetData;
}

class ChatHistorySheet extends StatelessWidget {
  const ChatHistorySheet({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ChatCubit cubit = context.cubit<ChatCubit>();

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
            child: CommonMaxWidth(
              maxWidth: context.barMaxWidth,
              padding: context.responsiveSheetPadding(),
              child:
                  TypeSafeBlocSelector<ChatCubit, ChatState, _HistorySheetData>(
                    key: const ValueKey('chat-history-sheet-content'),
                    selector: (final state) => _HistorySheetData(
                      history: state.history,
                      hasHistory: state.hasHistory,
                      activeConversationId: state.activeConversationId,
                      hasActiveMessages: state.messages.isNotEmpty,
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
                            child: IconLabelRow(
                              icon: Icons.add,
                              label: l10n.chatHistoryStartNew,
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
                            child: IconLabelRow(
                              icon: Icons.delete_outline,
                              label: l10n.chatHistoryClearAll,
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
                                          data.hasActiveMessages &&
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
    );
  }
}
