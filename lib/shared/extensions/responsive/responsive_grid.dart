part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Responsive grid layout calculations and helpers
extension ResponsiveGridContext on BuildContext {
  /// Calculates grid layout parameters for a responsive grid
  /// Returns a [ResponsiveGridLayout] with column count, item width, and spacing
  ResponsiveGridLayout calculateGridLayout({
    required final int mobileColumns,
    required final int tabletColumns,
    required final int desktopColumns,
    final double? customSpacing,
    final double? maxContentWidth,
  }) {
    final spacing = customSpacing ?? responsiveGap;
    final columns = responsiveValue<int>(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    final effectiveMaxWidth = maxContentWidth ?? contentMaxWidth;
    final screenWidth = this.screenWidth;
    final horizontalPadding = pageHorizontalPadding;

    // Calculate available width
    final availableScreenWidth = effectiveMaxWidth < screenWidth
        ? effectiveMaxWidth
        : screenWidth;
    final availableWidth = availableScreenWidth - (horizontalPadding * 2);
    final totalSpacing = spacing * (columns - 1);
    final constrainedWidth = (availableWidth - totalSpacing)
        .clamp(0, double.maxFinite)
        .toDouble();
    final itemWidth = constrainedWidth / columns;

    return ResponsiveGridLayout(
      columns: columns,
      itemWidth: itemWidth,
      spacing: spacing,
      horizontalPadding: horizontalPadding,
      availableWidth: availableWidth,
    );
  }

  /// Creates a responsive grid delegate with calculated columns and spacing
  SliverGridDelegate createResponsiveGridDelegate({
    required final int mobileColumns,
    required final int tabletColumns,
    required final int desktopColumns,
    final double? customSpacing,
    final double? crossAxisSpacing,
    final double? mainAxisSpacing,
  }) {
    final layout = calculateGridLayout(
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
      customSpacing: customSpacing,
    );

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: layout.columns,
      crossAxisSpacing: crossAxisSpacing ?? layout.spacing,
      mainAxisSpacing: mainAxisSpacing ?? layout.spacing,
    );
  }
}

/// Holds calculated grid layout parameters
class ResponsiveGridLayout {
  const ResponsiveGridLayout({
    required this.columns,
    required this.itemWidth,
    required this.spacing,
    required this.horizontalPadding,
    required this.availableWidth,
  });

  final int columns;
  final double itemWidth;
  final double spacing;
  final double horizontalPadding;
  final double availableWidth;
}
