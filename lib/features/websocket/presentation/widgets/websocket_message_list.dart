import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';
import 'package:flutter_bloc_app/shared/widgets/message_bubble.dart';

class WebsocketMessageList extends StatelessWidget {
  const WebsocketMessageList({
    required this.messages,
    required this.emptyLabel,
    super.key,
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
        return MessageBubble(
          message: message.text,
          isOutgoing: message.direction == WebsocketMessageDirection.outgoing,
          margin: EdgeInsets.symmetric(vertical: UI.gapXS),
          padding: EdgeInsets.symmetric(
            horizontal: UI.gapS,
            vertical: UI.gapXS,
          ),
        );
      },
    );
  }
}
