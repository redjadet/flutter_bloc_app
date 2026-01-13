import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

@immutable
class _SendButtonData extends Equatable {
  const _SendButtonData({
    required this.canSend,
    required this.isLoading,
  });

  final bool canSend;
  final bool isLoading;

  @override
  List<Object?> get props => [canSend, isLoading];
}

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
          child: PlatformAdaptive.textField(
            context: context,
            controller: controller,
            hintText: l10n.chatInputHint,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: l10n.chatInputHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  context.responsiveCardRadius,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.responsiveHorizontalGapS),
        BlocSelector<ChatCubit, ChatState, _SendButtonData>(
          selector: (final state) => _SendButtonData(
            canSend: state.canSend,
            isLoading: state.isLoading,
          ),
          builder: (final context, final data) => IconButton(
            tooltip: l10n.chatSendButton,
            onPressed: data.canSend ? onSend : null,
            icon: data.isLoading
                ? SizedBox.square(
                    dimension: context.responsiveIconSize,
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
