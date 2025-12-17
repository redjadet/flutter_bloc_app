import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A reusable skeleton grid item for grid layouts.
///
/// Provides consistent loading state for search results grid, gallery, etc.
/// Includes semantic labels for accessibility.
class SkeletonGridItem extends StatelessWidget {
  const SkeletonGridItem({
    super.key,
    this.aspectRatio = 1.0,
    this.hasOverlay = false,
  });

  /// Aspect ratio for the grid item (width / height).
  final double aspectRatio;

  /// Whether to show an overlay skeleton (e.g., for image with text overlay).
  final bool hasOverlay;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RepaintBoundary(
      child: Semantics(
        label: 'Loading content',
        child: Skeletonizer(
          effect: ShimmerEffect(
            baseColor: colors.surfaceContainerHigh,
            highlightColor: colors.surface,
          ),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  context.responsiveCardRadius,
                ),
              ),
              child: hasOverlay
                  ? Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(
                              context.responsiveCardRadius,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  context.responsiveCardRadius,
                                ),
                                bottomRight: Radius.circular(
                                  context.responsiveCardRadius,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
