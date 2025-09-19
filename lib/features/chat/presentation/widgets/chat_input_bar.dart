import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onSend(),
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: l10n.chatInputHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: UI.horizontalGapS),
        BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return IconButton(
              tooltip: l10n.chatSendButton,
              onPressed: state.canSend ? onSend : null,
              icon: state.isLoading
                  ? SizedBox.square(
                      dimension: UI.iconM,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.send),
            );
          },
        ),
      ],
    );
  }
}
