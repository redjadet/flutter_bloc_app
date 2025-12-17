import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A reusable skeleton card for card-based layouts.
///
/// Provides consistent loading state for profile cards, country cards, etc.
/// Includes semantic labels for accessibility.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height,
    this.width,
    this.hasImage = true,
    this.hasTitle = true,
    this.hasSubtitle = true,
  });

  /// Optional fixed height. If not provided, uses responsive sizing.
  final double? height;

  /// Optional fixed width. If not provided, uses full width.
  final double? width;

  /// Whether to show an image skeleton at the top.
  final bool hasImage;

  /// Whether to show a title skeleton.
  final bool hasTitle;

  /// Whether to show a subtitle skeleton.
  final bool hasSubtitle;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final effectiveHeight = height ?? context.heightFraction(0.2);
    final effectiveWidth = width ?? double.infinity;

    return RepaintBoundary(
      child: Semantics(
        label: 'Loading content',
        child: Skeletonizer(
          effect: ShimmerEffect(
            baseColor: colors.surfaceContainerHigh,
            highlightColor: colors.surface,
          ),
          child: Container(
            width: effectiveWidth,
            height: effectiveHeight,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(context.responsiveCardRadius),
            ),
            padding: EdgeInsets.all(context.responsiveCardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage) ...[
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(
                          context.responsiveCardRadius,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.responsiveGapM),
                ],
                if (hasTitle) ...[
                  Container(
                    width: effectiveWidth * 0.6,
                    height: effectiveHeight * 0.1,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(
                        context.responsiveCardRadius,
                      ),
                    ),
                  ),
                  if (hasSubtitle) SizedBox(height: context.responsiveGapS),
                ],
                if (hasSubtitle) ...[
                  Container(
                    width: double.infinity,
                    height: effectiveHeight * 0.08,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(
                        context.responsiveCardRadius,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
