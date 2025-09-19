import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.hasError) {
          final chatCubit = context.read<ChatCubit>();
          final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar();
          messenger
              .showSnackBar(SnackBar(content: Text(state.error!)))
              .closed
              .whenComplete(() {
                if (!chatCubit.isClosed) {
                  chatCubit.clearError();
                }
              });
        }
        if (state.hasMessages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!controller.hasClients) return;
            controller.animateTo(
              controller.position.maxScrollExtent,
              duration: UI.animFast,
              curve: Curves.easeOut,
            );
          });
        }
      },
      builder: (context, state) {
        if (!state.hasMessages) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(UI.gapL),
              child: Text(
                l10n.chatEmptyState,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          controller: controller,
          padding: EdgeInsets.all(UI.gapM),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final ChatMessage message = state.messages[index];
            final bool isUser = message.author == ChatAuthor.user;
            final Alignment alignment = isUser
                ? Alignment.centerRight
                : Alignment.centerLeft;
            final Color bubbleColor = isUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest;
            final Color textColor = isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface;

            return Align(
              alignment: alignment,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: UI.gapS / 2),
                padding: EdgeInsets.symmetric(
                  horizontal: UI.horizontalGapM,
                  vertical: UI.gapS,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(UI.radiusM),
                ),
                child: Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
