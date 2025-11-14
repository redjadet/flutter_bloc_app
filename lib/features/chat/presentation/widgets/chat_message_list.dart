import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/widgets/message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({required this.controller, super.key});

  final ScrollController controller;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ErrorNotificationService errorNotificationService =
        getIt<ErrorNotificationService>();

    return BlocConsumer<ChatCubit, ChatState>(
      listener: (final context, final state) async {
        if (state.hasError) {
          final ChatCubit chatCubit = context.read<ChatCubit>();
          await errorNotificationService
              .showSnackBar(context, state.error!)
              .whenComplete(() {
                if (!chatCubit.isClosed) {
                  chatCubit.clearError();
                }
              });
        }
        if (state.hasMessages) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!controller.hasClients) return;
            await controller.animateTo(
              controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
            );
          });
        }
      },
      builder: (final context, final state) {
        if (!state.hasMessages) {
          return Center(
            child: Padding(
              padding: context.responsiveStatePadding,
              child: Text(
                l10n.chatEmptyState,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return RepaintBoundary(
          child: ListView.builder(
            controller: controller,
            padding: EdgeInsets.all(context.responsiveGapM),
            itemCount: state.messages.length,
            itemBuilder: (final context, final index) {
              final ChatMessage message = state.messages[index];
              final bool isUser = message.author == ChatAuthor.user;

              return MessageBubble(
                key: ValueKey('chat-message-$index-${message.text.hashCode}'),
                message: message.text,
                isOutgoing: isUser,
                outgoingColor: theme.colorScheme.primary,
                incomingColor: theme.colorScheme.surfaceContainerHighest,
                outgoingTextColor: theme.colorScheme.onPrimary,
                incomingTextColor: theme.colorScheme.onSurface,
              );
            },
          ),
        );
      },
    );
  }
}
