import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_avatar.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile_config.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile_details.dart';

class ChatContactTile extends StatelessWidget {
  const ChatContactTile({
    required this.contact,
    required this.onTap,
    required this.onLongPress,
    this.isTabletLayout = false,
    super.key,
  });

  final ChatContact contact;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isTabletLayout;

  @override
  Widget build(BuildContext context) {
    final config = ChatContactTileConfig.fromContext(context);
    final timeText = _formatTime(contact.lastMessageTime);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding,
          vertical: config.verticalPadding,
        ),
        child: Row(
          children: [
            ChatContactAvatar(
              contact: contact,
              size: config.profileImageSize,
            ),
            SizedBox(
              width: config.horizontalGap,
            ),
            Expanded(
              child: ChatContactTileDetails(
                contact: contact,
                config: config,
                timeText: timeText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
