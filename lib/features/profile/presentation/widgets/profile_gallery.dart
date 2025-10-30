import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ProfileGallery extends StatelessWidget {
  const ProfileGallery({required this.images, super.key});

  final List<ProfileImage> images;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = context.pageHorizontalPadding;
    // Match Figma spacing: 8px between items
    const spacing = 8.0;
    final columnWidth = (screenWidth - (horizontalPadding * 2) - spacing) / 2;

    final leftColumn = <ProfileImage>[];
    final rightColumn = <ProfileImage>[];

    for (int i = 0; i < images.length; i++) {
      if (i.isEven) {
        leftColumn.add(images[i]);
      } else {
        rightColumn.add(images[i]);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _GalleryColumn(
              images: leftColumn,
              theme: theme,
              columnWidth: columnWidth,
              spacing: spacing,
            ),
          ),
          const SizedBox(width: spacing),
          Expanded(
            child: _GalleryColumn(
              images: rightColumn,
              theme: theme,
              columnWidth: columnWidth,
              spacing: spacing,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryColumn extends StatelessWidget {
  const _GalleryColumn({
    required this.images,
    required this.theme,
    required this.columnWidth,
    required this.spacing,
  });

  final List<ProfileImage> images;
  final ThemeData theme;
  final double columnWidth;
  final double spacing;

  @override
  Widget build(final BuildContext context) => Column(
    children: [
      for (int i = 0; i < images.length; i++) ...[
        ClipRect(
          child: SizedBox(
            width: columnWidth,
            height: columnWidth / images[i].aspectRatio,
            child: FancyShimmerImage(
              imageUrl: images[i].url,
              boxFit: BoxFit.cover,
              shimmerBaseColor: theme.colorScheme.surfaceContainerHighest,
              shimmerHighlightColor: theme.colorScheme.surface,
              errorWidget: Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.black54),
              ),
            ),
          ),
        ),
        if (i < images.length - 1) SizedBox(height: spacing),
      ],
    ],
  );
}
