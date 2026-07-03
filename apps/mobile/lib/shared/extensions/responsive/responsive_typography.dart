part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Typography and icon sizing helpers for responsive design.
extension ResponsiveTypographyContext on BuildContext {
  double get responsiveFontSize => _scaledFont(
    this,
    mobile: 14,
    tablet: 16,
    desktop: 16,
  );

  double get responsiveIconSize => _scaledFont(
    this,
    mobile: 20,
    tablet: 24,
    desktop: 24,
  );

  double get responsiveHeadlineSize => _scaledFont(
    this,
    mobile: 24,
    tablet: 32,
    desktop: 32,
  );

  double get responsiveTitleSize => _scaledFont(
    this,
    mobile: 20,
    tablet: 24,
    desktop: 24,
  );

  double get responsiveBodySize => _scaledFont(
    this,
    mobile: 14,
    tablet: 16,
    desktop: 16,
  );

  double get responsiveCaptionSize => _scaledFont(
    this,
    mobile: 12,
    tablet: 14,
    desktop: 14,
  );

  double get responsiveErrorIconSize => _scaledFont(
    this,
    mobile: 48,
    tablet: 64,
    desktop: 64,
  );

  double get responsiveErrorIconSizeLarge => _scaledFont(
    this,
    mobile: 64,
    tablet: 80,
    desktop: 80,
  );
}
