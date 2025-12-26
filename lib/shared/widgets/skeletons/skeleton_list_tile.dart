import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/skeletons/skeleton_base.dart';

/// A reusable skeleton list tile for list-based UIs.
///
/// Provides consistent loading state for chat history, search results, etc.
/// Includes semantic labels for accessibility.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.height,
    this.hasAvatar = true,
    this.hasSubtitle = true,
  });

  /// Optional fixed height. If not provided, uses responsive sizing.
  final double? height;

  /// Whether to show an avatar skeleton.
  final bool hasAvatar;

  /// Whether to show a subtitle skeleton.
  final bool hasSubtitle;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final effectiveHeight = height ?? context.responsiveButtonHeight * 1.5;

    return SkeletonBase(
      child: Container(
        height: effectiveHeight,
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalGapM,
          vertical: context.responsiveGapS,
        ),
        child: Row(
          children: [
            if (hasAvatar) ...[
              Container(
                width: effectiveHeight * 0.6,
                height: effectiveHeight * 0.6,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.responsiveGapM),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: effectiveHeight * 0.25,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        context.responsiveCardRadius,
                      ),
                    ),
                  ),
                  if (hasSubtitle) ...[
                    SizedBox(height: context.responsiveGapXS),
                    Container(
                      width: double.infinity,
                      height: effectiveHeight * 0.2,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          context.responsiveCardRadius,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
