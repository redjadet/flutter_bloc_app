import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_avatar.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile_config.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_contact_tile_details.dart';
import 'package:ilkersevim_relative_time/ilkersevim_relative_time.dart';

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
  Widget build(final BuildContext context) {
    final config = ChatContactTileConfig.fromContext(context);
    final timeText = formatRelativeTimeShort(contact.lastMessageTime);

    return Semantics(
      button: true,
      label: contact.name,
      child: InkWell(
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
      ),
    );
  }
}
