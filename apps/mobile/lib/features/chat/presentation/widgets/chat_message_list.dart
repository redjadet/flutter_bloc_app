import 'package:design_system/design_system.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:flutter_bloc_app/app/widgets/view_status_switcher.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_terminal_sync_failure_text.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

part 'chat_message_list.freezed.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    required this.controller,
    required this.errorNotificationService,
    super.key,
  });

  final ScrollController controller;
  final ErrorNotificationService errorNotificationService;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return TypeSafeBlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) async {
        if (state.error case final err?) {
          final ChatCubit chatCubit = context.cubit<ChatCubit>();
          final trimmedRemoteCode = state.remoteFailureL10nCode?.trim();
          final String snackText =
              trimmedRemoteCode != null && trimmedRemoteCode.isNotEmpty
              ? terminalSyncFailureMessage(l10n, trimmedRemoteCode)
              : err;
          await errorNotificationService
              .showSnackBar(context, snackText)
              .whenComplete(
                () {
                  if (!chatCubit.isClosed) {
                    chatCubit.clearError();
                  }
                },
              );
        }
        if (state.hasMessages) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) {
              ContextUtils.logNotMounted('ChatMessageList.scrollToBottom');
              return;
            }
            if (!controller.hasClients) {
              return;
            }
            await controller.animateTo(
              controller.position.maxScrollExtent,
              duration: UI.animFast,
              curve: Curves.easeOut,
            );
          });
        }
      },
      builder: (context, state) =>
          ViewStatusSwitcher<ChatCubit, ChatState, _ChatListData>(
            selector: (state) => _ChatListData(
              hasMessages: state.hasMessages,
              isLoading: state.isLoading,
              messages: state.messages,
            ),
            isLoading: (data) => data.isLoading && !data.hasMessages,
            isError: (_) => false,
            loadingBuilder: (_) => const CommonLoadingWidget(),
            builder: (context, data) {
              if (!data.hasMessages) {
                return CommonStatusView(
                  message: l10n.chatEmptyState,
                  messageStyle: theme.textTheme.bodyLarge,
                );
              }
              return RepaintBoundary(
                child: ListView.builder(
                  scrollCacheExtent: const ScrollCacheExtent.pixels(500),
                  controller: controller,
                  padding: context.allGapM,
                  itemCount: data.messages.length,
                  itemBuilder: (context, index) {
                    final ChatMessage message = data.messages[index];
                    final bool isUser = message.author == ChatAuthor.user;
                    final trimmedTerminalCode = message.terminalSyncFailureCode
                        ?.trim();

                    return RepaintBoundary(
                      key: _chatMessageKey(message, index),
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: <Widget>[
                          MessageBubble(
                            message: message.text,
                            isOutgoing: isUser,
                            outgoingColor: theme.colorScheme.primary,
                            incomingColor:
                                theme.colorScheme.surfaceContainerHighest,
                            outgoingTextColor: theme.colorScheme.onPrimary,
                            incomingTextColor: theme.colorScheme.onSurface,
                          ),
                          if (isUser &&
                              trimmedTerminalCode != null &&
                              trimmedTerminalCode.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                top: context.responsiveGapXS,
                                left: isUser ? context.responsiveGapL : 0,
                                right: isUser ? 0 : context.responsiveGapL,
                              ),
                              child: Text(
                                terminalSyncFailureMessage(
                                  l10n,
                                  trimmedTerminalCode,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: isUser
                                    ? TextAlign.end
                                    : TextAlign.start,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
    );
  }
}

Key _chatMessageKey(ChatMessage message, int index) {
  if (message.clientMessageId case final messageId?) {
    return ValueKey<String>('chat-message-$messageId');
  }
  if (message.createdAt case final createdAt?) {
    return ValueKey<String>(
      'chat-message-${message.author.name}-${createdAt.microsecondsSinceEpoch}',
    );
  }
  return ValueKey<String>(
    'chat-message-fallback-$index-${message.author.name}',
  );
}

@freezed
abstract class _ChatListData with _$ChatListData {
  const factory _ChatListData({
    required bool hasMessages,
    required bool isLoading,
    required List<ChatMessage> messages,
  }) = __ChatListData;
}
