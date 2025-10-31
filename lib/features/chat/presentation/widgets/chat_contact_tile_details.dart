import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';

import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile_config.dart';

class ChatContactTileDetails extends StatelessWidget {
  const ChatContactTileDetails({
    required this.contact,
    required this.config,
    required this.timeText,
    super.key,
  });

  final ChatContact contact;
  final ChatContactTileConfig config;
  final String timeText;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final timePainter = TextPainter(
        text: TextSpan(text: timeText, style: config.timeTextStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);

      final availableMessageWidth =
          (constraints.maxWidth - timePainter.width - config.messageTimeSpacing)
              .clamp(0.0, constraints.maxWidth);

      final messagePainter = TextPainter(
        text: TextSpan(
          text: contact.lastMessage,
          style: config.messageTextStyle,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: availableMessageWidth);

      final hasSecondLine =
          messagePainter.didExceedMaxLines ||
          messagePainter.height > config.messageLineHeight + 0.5;

      final columnAlignment = hasSecondLine
          ? MainAxisAlignment.start
          : MainAxisAlignment.center;
      final rowCrossAxis = hasSecondLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center;
      final spacing = hasSecondLine
          ? config.responsiveGap
          : config.responsiveGap / 2;
      final timeTopPadding = hasSecondLine ? 0.0 : config.responsiveGap / 4;
      final messageMaxLines = hasSecondLine ? 2 : 1;

      return Column(
        mainAxisAlignment: columnAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  contact.name,
                  style: config.nameTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (contact.unreadCount > 0)
                _ChatUnreadBadge(
                  count: contact.unreadCount,
                  config: config,
                ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            crossAxisAlignment: rowCrossAxis,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  contact.lastMessage,
                  style: config.messageTextStyle,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: messageMaxLines,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: config.messageTimeSpacing,
                  top: timeTopPadding,
                ),
                child: Text(
                  timeText,
                  style: config.timeTextStyle,
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _ChatUnreadBadge extends StatelessWidget {
  const _ChatUnreadBadge({
    required this.count,
    required this.config,
  });

  final int count;
  final ChatContactTileConfig config;

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    constraints: BoxConstraints(
      minWidth: config.unreadMinSize,
      minHeight: config.unreadMinSize,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: config.isTabletOrLarger ? 10 : 8,
      vertical: config.isTabletOrLarger ? 6 : 4,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF007AFF),
      borderRadius: BorderRadius.circular(
        config.isTabletOrLarger ? 14 : 12,
      ),
    ),
    child: Text(
      count.toString(),
      style: config.unreadTextStyle,
    ),
  );
}
