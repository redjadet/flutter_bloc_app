part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Fine-grained spacing helpers shared across widgets.
extension ResponsiveSpacingContext on BuildContext {
  double get responsiveGap => _scaledDimension(
    this,
    mobile: 8,
    tablet: 12,
    desktop: 12,
    convert: UI.scaleHeight,
  );

  double get responsiveGapXS => _scaledDimension(
    this,
    mobile: 6,
    tablet: 8,
    desktop: 8,
    convert: UI.scaleHeight,
  );

  double get responsiveGapS => _scaledDimension(
    this,
    mobile: 8,
    tablet: 10,
    desktop: 10,
    convert: UI.scaleHeight,
  );

  double get responsiveGapM => _scaledDimension(
    this,
    mobile: 12,
    tablet: 16,
    desktop: 16,
    convert: UI.scaleHeight,
  );

  double get responsiveGapL => _scaledDimension(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 24,
    convert: UI.scaleHeight,
  );

  double get responsiveHorizontalGapS => _scaledDimension(
    this,
    mobile: 8,
    tablet: 10,
    desktop: 10,
    convert: UI.scaleWidth,
  );

  double get responsiveHorizontalGapM => _scaledDimension(
    this,
    mobile: 10,
    tablet: 12,
    desktop: 12,
    convert: UI.scaleWidth,
  );

  double get responsiveHorizontalGapL => _scaledDimension(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 24,
    convert: UI.scaleWidth,
  );
}
