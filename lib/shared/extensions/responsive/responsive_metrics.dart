part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Core responsive metrics and breakpoint-aware helpers.
extension ResponsiveContextMetrics on BuildContext {
  Size get screenSize => Size(_responsiveWidth(this), _responsiveHeight(this));
  double get screenWidth => _responsiveWidth(this);
  double get screenHeight => _responsiveHeight(this);

  bool get isMobile => screenWidth < AppConstants.mobileBreakpoint;
  bool get isMediumWidth => screenWidth >= AppConstants.mediumWidthBreakpoint;
  bool get isTabletOrLarger => screenWidth >= AppConstants.mobileBreakpoint;
  bool get isDesktop => screenWidth >= AppConstants.tabletBreakpoint;
  bool get isCompactWidth => screenWidth < AppConstants.compactWidthBreakpoint;
  bool get isCompactHeight =>
      screenHeight < AppConstants.compactHeightBreakpoint;
  bool get isPortrait => _responsiveOrientation(this) == Orientation.portrait;
  bool get isLandscape => _responsiveOrientation(this) == Orientation.landscape;

  double get bottomInset => MediaQuery.viewPaddingOf(this).bottom;
  double get topInset => MediaQuery.viewPaddingOf(this).top;
  EdgeInsets get safeAreaInsets => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  double get keyboardInset => viewInsets.bottom;

  double widthFraction(final double fraction) => screenWidth * fraction;
  double heightFraction(final double fraction) => screenHeight * fraction;
  double clampWidthTo(final double max) => math.min(screenWidth, max);

  T responsiveValue<T>({
    required final T mobile,
    final T? tablet,
    final T? desktop,
  }) => _responsiveValue<T>(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}
