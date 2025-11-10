part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Fine-grained spacing helpers shared across widgets.
extension ResponsiveSpacingContext on BuildContext {
  double get responsiveGap => _scaledHeight(
    this,
    mobile: 8,
    tablet: 12,
    desktop: 12,
  );

  double get responsiveGapXS => _scaledHeight(
    this,
    mobile: 6,
    tablet: 8,
    desktop: 8,
  );

  double get responsiveGapS => _scaledHeight(
    this,
    mobile: 8,
    tablet: 10,
    desktop: 10,
  );

  double get responsiveGapM => _scaledHeight(
    this,
    mobile: 12,
    tablet: 16,
    desktop: 16,
  );

  double get responsiveGapL => _scaledHeight(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 24,
  );

  double get responsiveHorizontalGapS => _scaledWidth(
    this,
    mobile: 8,
    tablet: 10,
    desktop: 10,
  );

  double get responsiveHorizontalGapM => _scaledWidth(
    this,
    mobile: 10,
    tablet: 12,
    desktop: 12,
  );

  double get responsiveHorizontalGapL => _scaledWidth(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 24,
  );
}
