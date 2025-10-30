import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    required this.controller,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
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
          builder: (final context, final state) => IconButton(
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
          ),
        ),
      ],
    );
  }
}
