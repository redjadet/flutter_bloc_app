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
    final gridLayout = context.calculateGridLayout(
      mobileColumns: 2,
      tabletColumns: 2,
      desktopColumns: 3,
      maxContentWidth: context.contentMaxWidth,
    );

    // Distribute images across columns
    final columns = List.generate(gridLayout.columns, (_) => <ProfileImage>[]);
    for (int i = 0; i < images.length; i++) {
      columns[i % gridLayout.columns].add(images[i]);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gridLayout.horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < gridLayout.columns; i++) ...[
            if (i > 0) SizedBox(width: gridLayout.spacing),
            Expanded(
              child: _GalleryColumn(
                images: columns[i],
                theme: theme,
                columnWidth: gridLayout.itemWidth,
                spacing: gridLayout.spacing,
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
              errorWidget: ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        if (i < images.length - 1) SizedBox(height: spacing),
      ],
    ],
  );
}
