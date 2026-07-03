import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Base skeleton widget that provides common skeleton behavior and styling.
///
/// This widget encapsulates the common pattern used across all skeleton widgets:
/// - RepaintBoundary for performance
/// - Semantics label for accessibility
/// - Consistent ShimmerEffect configuration
/// - Theme-based color scheme
class SkeletonBase extends StatelessWidget {
  const SkeletonBase({
    required this.child,
    super.key,
    this.semanticLabel = 'Loading content',
  });

  /// The skeleton content to display.
  final Widget child;

  /// Semantic label for accessibility (defaults to 'Loading content').
  final String semanticLabel;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return RepaintBoundary(
      child: Semantics(
        label: semanticLabel,
        child: Skeletonizer(
          effect: ShimmerEffect(
            baseColor: colors.surfaceContainerHigh,
            highlightColor: colors.surface,
          ),
          child: child,
        ),
      ),
    );
  }
}
