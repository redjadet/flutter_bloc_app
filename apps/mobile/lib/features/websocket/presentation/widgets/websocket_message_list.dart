import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
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
    return RepaintBoundary(
      child: ListView.builder(
        scrollCacheExtent: const ScrollCacheExtent.pixels(500),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalGapL,
          vertical: context.responsiveGapS,
        ),
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (final context, final index) {
          final int messageIndex = messages.length - 1 - index;
          final WebsocketMessage message = messages[messageIndex];
          return RepaintBoundary(
            key: ValueKey(
              'ws-msg-${message.direction.name}-${message.sequence}',
            ),
            child: MessageBubble(
              message: message.text,
              isOutgoing:
                  message.direction == WebsocketMessageDirection.outgoing,
              margin: EdgeInsets.symmetric(vertical: context.responsiveGapXS),
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveGapS,
                vertical: context.responsiveGapXS,
              ),
            ),
          );
        },
      ),
    );
  }
}
