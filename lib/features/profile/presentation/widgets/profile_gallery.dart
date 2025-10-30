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

    // Use existing responsive gap with multipliers
    final spacing = context.responsiveGap;

    // Responsive columns: use gridColumns but cap at 3 for masonry layout
    final columnCount = context.isDesktop ? 3 : 2;
    final totalSpacing = spacing * (columnCount - 1);

    // Use contentMaxWidth if constrained, otherwise full screen width
    final maxContentWidth = context.contentMaxWidth;
    final availableScreenWidth = maxContentWidth < screenWidth
        ? maxContentWidth
        : screenWidth;
    final availableWidth =
        availableScreenWidth - (horizontalPadding * 2) - totalSpacing;
    final columnWidth = availableWidth / columnCount;

    // Distribute images across columns
    final columns = List.generate(columnCount, (_) => <ProfileImage>[]);
    for (int i = 0; i < images.length; i++) {
      columns[i % columnCount].add(images[i]);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < columnCount; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(
              child: _GalleryColumn(
                images: columns[i],
                theme: theme,
                columnWidth: columnWidth,
                spacing: spacing,
              ),
            ),
          ],
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
