import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';

class WebsocketMessageList extends StatelessWidget {
  const WebsocketMessageList({
    super.key,
    required this.messages,
    required this.emptyLabel,
  });

  final List<WebsocketMessage> messages;
  final String emptyLabel;

  @override
  Widget build(final BuildContext context) {
    if (messages.isEmpty) {
      return AppMessage(message: emptyLabel);
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: UI.horizontalGapL,
        vertical: UI.gapS,
      ),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (final context, final index) {
        final WebsocketMessage message = messages[messages.length - 1 - index];
        return _WebsocketMessageBubble(message: message);
      },
    );
  }
}

class _WebsocketMessageBubble extends StatelessWidget {
  const _WebsocketMessageBubble({required this.message});

  final WebsocketMessage message;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isOutgoing =
        message.direction == WebsocketMessageDirection.outgoing;
    final Alignment alignment = isOutgoing
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final ColorScheme colors = theme.colorScheme;
    final Color bubbleColor = isOutgoing
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final Color textColor = isOutgoing
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;
    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: UI.gapXS),
        padding: EdgeInsets.symmetric(horizontal: UI.gapS, vertical: UI.gapXS),
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
  }
}
