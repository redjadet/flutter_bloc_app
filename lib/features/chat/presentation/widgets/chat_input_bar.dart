import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_input_decoration_helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_input_bar.freezed.dart';

@freezed
abstract class _SendButtonData with _$SendButtonData {
  const factory _SendButtonData({
    required final bool canSend,
    required final bool isLoading,
  }) = __SendButtonData;
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
            decoration: buildCommonInputDecoration(
              context: context,
              theme: theme,
              hintText: l10n.chatInputHint,
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
