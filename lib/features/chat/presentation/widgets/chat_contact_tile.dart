import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

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
    final profileImageSize = context.isDesktop
        ? 60.0
        : context.isTabletOrLarger
        ? 55.0
        : 50.0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.isDesktop
              ? 24.0
              : context.isTabletOrLarger
              ? 20.0
              : 16.0,
          vertical: context.isDesktop
              ? 16.0
              : context.isTabletOrLarger
              ? 14.0
              : 12.0,
        ),
        child: Row(
          children: [
            _buildProfileImage(size: profileImageSize),
            SizedBox(
              width: context.isDesktop
                  ? 16.0
                  : context.isTabletOrLarger
                  ? 14.0
                  : 12.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          style: TextStyle(
                            fontSize: context.isDesktop
                                ? 18.0
                                : context.isTabletOrLarger
                                ? 17.0
                                : 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (contact.unreadCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.isTabletOrLarger ? 10 : 8,
                            vertical: context.isTabletOrLarger ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF),
                            borderRadius: BorderRadius.circular(
                              context.isTabletOrLarger ? 14 : 12,
                            ),
                          ),
                          child: Text(
                            contact.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.isTabletOrLarger ? 13 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.isTabletOrLarger ? 6 : 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contact.lastMessage,
                          style: TextStyle(
                            fontSize: context.isDesktop
                                ? 15.0
                                : context.isTabletOrLarger
                                ? 14.5
                                : 14.0,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        _formatTime(contact.lastMessageTime),
                        style: TextStyle(
                          fontSize: context.isDesktop
                              ? 13.0
                              : context.isTabletOrLarger
                              ? 12.5
                              : 12.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage({double size = 50}) {
    final onlineIndicatorSize = size * 0.28;
    final borderWidth = size > 50 ? 3.0 : 2.0;
    final iconSize = size * 0.6;
    final loadingSize = size * 0.4;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: ClipOval(
            child: Image.network(
              contact.profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  color: Colors.grey[600],
                  size: iconSize,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: SizedBox(
                      width: loadingSize,
                      height: loadingSize,
                      child: CircularProgressIndicator(
                        strokeWidth: size > 50 ? 3 : 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (contact.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: onlineIndicatorSize,
              height: onlineIndicatorSize,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: borderWidth,
                ),
              ),
            ),
          ),
      ],
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
