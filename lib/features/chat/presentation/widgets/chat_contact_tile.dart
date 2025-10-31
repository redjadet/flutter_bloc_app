import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final isDesktopLayout = context.isDesktop;
    final isTabletOrLarger = context.isTabletOrLarger;
    final usesTabletTypography = isTabletOrLarger && !context.isDesktop;

    final profileImageSize = isDesktopLayout
        ? 60.0
        : usesTabletTypography
        ? 55.0
        : 64.0;
    final nameFontSize = isDesktopLayout
        ? 18.0
        : usesTabletTypography
        ? 17.0
        : 13.0;
    final messageFontSize = isDesktopLayout
        ? 15.0
        : usesTabletTypography
        ? 14.5
        : 13.0;
    final messageLineHeight = isDesktopLayout
        ? 20.0
        : usesTabletTypography
        ? 19.0
        : 18.0;
    final timeFontSize = isDesktopLayout
        ? 13.0
        : usesTabletTypography
        ? 12.5
        : 13.0;

    final horizontalPadding =
        context.pageHorizontalPadding -
        (isDesktopLayout
            ? 8.0
            : usesTabletTypography
            ? 4.0
            : 0.0);
    final verticalPadding =
        context.pageVerticalPadding +
        (context.isMobile
            ? 4.0
            : usesTabletTypography
            ? -2.0
            : 0.0);
    final horizontalGap =
        context.responsiveGap +
        (isDesktopLayout
            ? 4.0
            : usesTabletTypography
            ? 2.0
            : 4.0);

    const messageTimeSpacing = 8.0;

    final nameStyle = TextStyle(
      fontSize: nameFontSize,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Roboto',
    );
    final unreadStyle = TextStyle(
      color: Colors.white,
      fontSize: isTabletOrLarger ? 13 : 12,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    );
    final messageStyle = TextStyle(
      fontSize: messageFontSize,
      height: messageLineHeight / messageFontSize,
      color: Colors.black,
      fontFamily: 'Roboto',
    );
    final timeStyle = TextStyle(
      fontSize: timeFontSize,
      color: Colors.black,
      fontFamily: 'Roboto',
    );
    final timeText = _formatTime(contact.lastMessageTime);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            _buildProfileImage(size: profileImageSize),
            SizedBox(
              width: horizontalGap,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final timePainter = TextPainter(
                    text: TextSpan(text: timeText, style: timeStyle),
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth);

                  final availableMessageWidth =
                      (constraints.maxWidth -
                              timePainter.width -
                              messageTimeSpacing)
                          .clamp(
                            0.0,
                            constraints.maxWidth,
                          );

                  final messagePainter = TextPainter(
                    text: TextSpan(
                      text: contact.lastMessage,
                      style: messageStyle,
                    ),
                    textDirection: TextDirection.ltr,
                    maxLines: 2,
                  )..layout(maxWidth: availableMessageWidth);

                  final hasSecondLine =
                      messagePainter.didExceedMaxLines ||
                      messagePainter.height > messageLineHeight + 0.5;

                  final columnAlignment = hasSecondLine
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center;
                  final rowCrossAxis = hasSecondLine
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center;
                  final spacing = hasSecondLine
                      ? context.responsiveGap
                      : context.responsiveGap / 2;
                  final timeTopPadding = hasSecondLine
                      ? 0.0
                      : context.responsiveGap / 4;
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
                              style: nameStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.unreadCount > 0)
                            Container(
                              alignment: Alignment.center,
                              constraints: BoxConstraints(
                                minWidth: isTabletOrLarger ? 28 : 24,
                                minHeight: isTabletOrLarger ? 28 : 24,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isTabletOrLarger ? 10 : 8,
                                vertical: isTabletOrLarger ? 6 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF),
                                borderRadius: BorderRadius.circular(
                                  isTabletOrLarger ? 14 : 12,
                                ),
                              ),
                              child: Text(
                                contact.unreadCount.toString(),
                                style: unreadStyle,
                              ),
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
                              style: messageStyle,
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
                              left: messageTimeSpacing,
                              top: timeTopPadding,
                            ),
                            child: Text(
                              timeText,
                              style: timeStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
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
    final imagePath = contact.profileImageUrl;

    Widget buildFallback() => Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        color: Colors.grey[600],
        size: iconSize,
      ),
    );

    Widget? buildImage() {
      if (imagePath.isEmpty) {
        return null;
      }

      if (imagePath.toLowerCase().endsWith('.svg')) {
        return _SvgAssetImage(
          assetPath: imagePath,
          fit: BoxFit.cover,
          fallbackBuilder: buildFallback,
        );
      }

      final uri = Uri.tryParse(imagePath);
      final isNetworkImage =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

      if (isNetworkImage) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => buildFallback(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
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
        );
      }

      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => buildFallback(),
      );
    }

    final imageWidget = buildImage();

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
            child: imageWidget ?? buildFallback(),
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

class _SvgAssetImage extends StatelessWidget {
  const _SvgAssetImage({
    required this.assetPath,
    required this.fit,
    required this.fallbackBuilder,
  });

  final String assetPath;
  final BoxFit fit;
  final Widget Function() fallbackBuilder;

  static final Map<String, Uint8List?> _cache = {};
  static final RegExp _base64Pattern = RegExp(
    r'data:image/[^;]+;base64,([^"\\)]+)',
  );

  Future<Uint8List?> _loadBytes() async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath];
    }

    try {
      final svgString = await rootBundle.loadString(assetPath);
      final match = _base64Pattern.firstMatch(svgString);
      if (match != null) {
        final bytes = base64Decode(match.group(1)!);
        _cache[assetPath] = bytes;
        return bytes;
      }
    } on Exception catch (_) {
      // Ignore asset loading/parsing errors; fallback handles rendering.
    }

    _cache[assetPath] = null;
    return null;
  }

  Widget _buildSvgPicture() {
    try {
      return SvgPicture.asset(
        assetPath,
        fit: fit,
        placeholderBuilder: (_) => fallbackBuilder(),
      );
    } on Exception catch (_) {
      return fallbackBuilder();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cache.containsKey(assetPath)) {
      final bytes = _cache[assetPath];
      if (bytes != null) {
        return Image.memory(bytes, fit: fit);
      }
      return _buildSvgPicture();
    }

    return FutureBuilder<Uint8List?>(
      future: _loadBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null) {
          return Image.memory(bytes, fit: fit);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return fallbackBuilder();
        }

        return _buildSvgPicture();
      },
    );
  }
}
