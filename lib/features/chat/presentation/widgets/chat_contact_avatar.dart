import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/shared/widgets/cached_network_image_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

class ChatContactAvatar extends StatelessWidget {
  const ChatContactAvatar({
    required this.contact,
    required this.size,
    super.key,
  });

  final ChatContact contact;
  final double size;

  @override
  Widget build(final BuildContext context) {
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
        return ResilientSvgAssetImage(
          assetPath: imagePath,
          fit: BoxFit.cover,
          fallbackBuilder: buildFallback,
        );
      }

      final uri = Uri.tryParse(imagePath);
      final isNetworkImage =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

      if (isNetworkImage) {
        return CachedNetworkImageWidget(
          imageUrl: imagePath,
          fit: BoxFit.cover,
          width: size,
          height: size,
          memCacheWidth: size.toInt(),
          memCacheHeight: size.toInt(),
          placeholder: (final context, final url) => Container(
            color: Colors.grey[300],
            child: Center(
              child: SizedBox(
                width: loadingSize,
                height: loadingSize,
                child: CircularProgressIndicator(
                  strokeWidth: size > 50 ? 3 : 2,
                ),
              ),
            ),
          ),
          errorWidget: (final context, final url, final error) =>
              buildFallback(),
        );
      }

      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (final context, final error, final stackTrace) =>
            buildFallback(),
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
}
