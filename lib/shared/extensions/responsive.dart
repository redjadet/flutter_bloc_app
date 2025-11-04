import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Extension providing responsive utilities and breakpoint helpers
extension ResponsiveContext on BuildContext {
  // Private getters for consistent access
  double get _width => UI.isScreenUtilReady
      ? ScreenUtil().screenWidth
      : MediaQuery.sizeOf(this).width;
  double get _height => UI.isScreenUtilReady
      ? ScreenUtil().screenHeight
      : MediaQuery.sizeOf(this).height;

  /// Raw screen size helpers
  Size get screenSize => Size(_responsiveWidth, _responsiveHeight);
  double get screenWidth => _responsiveWidth;
  double get screenHeight => _responsiveHeight;

  // Device type detection
  bool get isMobile => _responsiveWidth < AppConstants.mobileBreakpoint;

  bool get isMediumWidth =>
      _responsiveWidth >= AppConstants.mediumWidthBreakpoint;

  bool get isTabletOrLarger =>
      _responsiveWidth >= AppConstants.mobileBreakpoint;

  bool get isDesktop => _responsiveWidth >= AppConstants.tabletBreakpoint;
  bool get isCompactWidth =>
      _responsiveWidth < AppConstants.compactWidthBreakpoint;
  bool get isPortrait => _responsiveOrientation == Orientation.portrait;
  bool get isLandscape => _responsiveOrientation == Orientation.landscape;
  bool get isCompactHeight =>
      _responsiveHeight < AppConstants.compactHeightBreakpoint;

  // Safe area helpers
  double get bottomInset => MediaQuery.viewPaddingOf(this).bottom;
  double get topInset => MediaQuery.viewPaddingOf(this).top;
  EdgeInsets get safeAreaInsets => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  double get keyboardInset => viewInsets.bottom;

  // Safe ScreenUtil adapters with fallbacks
  double _safeW(final double v) => UI.isScreenUtilReady ? v.w : v;
  double _safeH(final double v) => UI.isScreenUtilReady ? v.h : v;
  double _safeSp(final double v) => UI.isScreenUtilReady ? v.sp : v;
  double _safeR(final double v) => UI.isScreenUtilReady ? v.r : v;

  ResponsiveBreakpointsData? get _breakpoints {
    final inheritedElement =
        getElementForInheritedWidgetOfExactType<
          InheritedResponsiveBreakpoints
        >();
    if (inheritedElement == null) {
      return null;
    }
    final inheritedWidget = inheritedElement.widget;
    if (inheritedWidget is! InheritedResponsiveBreakpoints) {
      return null;
    }
    final data = inheritedWidget.data;
    if (data.breakpoints.isEmpty) {
      return null;
    }
    return data;
  }

  double get _responsiveWidth => _breakpoints?.screenWidth ?? _width;
  double get _responsiveHeight => _breakpoints?.screenHeight ?? _height;
  Orientation get _responsiveOrientation =>
      _breakpoints?.orientation ?? MediaQuery.orientationOf(this);

  double _scaledDimension({
    required final double Function(double value) convert,
    required final double mobile,
    final double? tablet,
    final double? desktop,
  }) {
    final double baseValue = responsiveValue<double>(
      mobile: mobile,
      tablet: tablet ?? desktop ?? mobile,
      desktop: desktop,
    );
    return convert(baseValue);
  }

  // Responsive padding system
  double get pageHorizontalPadding => _scaledDimension(
    mobile: 16,
    tablet: 24,
    desktop: 32,
    convert: _safeW,
  );

  double get pageVerticalPadding => _scaledDimension(
    mobile: 12,
    tablet: 16,
    desktop: 16,
    convert: _safeH,
  );

  // Content width constraints
  double get contentMaxWidth => _scaledDimension(
    mobile: 560,
    tablet: 720,
    desktop: 840,
    convert: _safeW,
  ); // keep content comfortably narrow on large phones

  double get barMaxWidth {
    if (isDesktop) return _safeW(900);
    if (isTabletOrLarger) return _safeW(720);
    return double.infinity;
  }

  // Complete page padding with safe area considerations
  EdgeInsets get pagePadding {
    final double extraBottom = isMobile && isPortrait ? _safeH(72) : 0;
    return EdgeInsets.fromLTRB(
      pageHorizontalPadding,
      pageVerticalPadding,
      pageHorizontalPadding,
      pageVerticalPadding + bottomInset + extraBottom,
    );
  }

  // Additional responsive utilities
  double get responsiveFontSize => _scaledDimension(
    mobile: 14,
    tablet: 16,
    desktop: 16,
    convert: _safeSp,
  );
  double get responsiveIconSize => _scaledDimension(
    mobile: 20,
    tablet: 24,
    desktop: 24,
    convert: _safeSp,
  );

  // Grid columns based on screen size
  int get gridColumns => responsiveValue<int>(
    mobile: 2,
    tablet: 3,
    desktop: 4,
  );

  // Responsive spacing
  double get responsiveGap => _scaledDimension(
    mobile: 8,
    tablet: 12,
    desktop: 12,
    convert: _safeH,
  );
  double get responsiveCardPadding => _scaledDimension(
    mobile: 16,
    tablet: 20,
    desktop: 20,
    convert: _safeW,
  );

  // Additional responsive utilities for specific use cases
  double get responsiveButtonHeight => _scaledDimension(
    mobile: 48,
    tablet: 56,
    desktop: 56,
    convert: _safeH,
  );
  double get responsiveButtonPadding => _scaledDimension(
    mobile: 16,
    tablet: 24,
    desktop: 24,
    convert: _safeW,
  );

  // Responsive text styles
  double get responsiveHeadlineSize => _scaledDimension(
    mobile: 24,
    tablet: 32,
    desktop: 32,
    convert: _safeSp,
  );
  double get responsiveTitleSize => _scaledDimension(
    mobile: 20,
    tablet: 24,
    desktop: 24,
    convert: _safeSp,
  );
  double get responsiveBodySize => _scaledDimension(
    mobile: 14,
    tablet: 16,
    desktop: 16,
    convert: _safeSp,
  );
  double get responsiveCaptionSize => _scaledDimension(
    mobile: 12,
    tablet: 14,
    desktop: 14,
    convert: _safeSp,
  );

  // Responsive margins and paddings
  EdgeInsets get responsivePageMargin => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );

  EdgeInsets get responsiveCardMargin => EdgeInsets.all(
    _scaledDimension(
      mobile: 8,
      tablet: 12,
      desktop: 12,
      convert: _safeW,
    ),
  );

  EdgeInsets get responsiveListPadding => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: _scaledDimension(
      mobile: 8,
      tablet: 12,
      desktop: 12,
      convert: _safeH,
    ),
  );

  // Responsive border radius
  double get responsiveBorderRadius => _scaledDimension(
    mobile: 8,
    tablet: 12,
    desktop: 12,
    convert: _safeR,
  );
  double get responsiveCardRadius => _scaledDimension(
    mobile: 12,
    tablet: 16,
    desktop: 16,
    convert: _safeR,
  );

  // Responsive elevation
  double get responsiveElevation => responsiveValue(
    mobile: 2,
    tablet: 4,
    desktop: 4,
  );
  double get responsiveCardElevation => responsiveValue(
    mobile: 1,
    tablet: 2,
    desktop: 2,
  );

  // Common responsive spacing helpers
  /// Responsive gap XS (extra small)
  double get responsiveGapXS => _scaledDimension(
    mobile: 6,
    tablet: 8,
    desktop: 8,
    convert: _safeH,
  );

  /// Responsive gap S (small) - maps to UI.gapS
  double get responsiveGapS => _scaledDimension(
    mobile: 8,
    tablet: 10,
    desktop: 10,
    convert: _safeH,
  );

  /// Responsive gap M (medium) - maps to UI.gapM
  double get responsiveGapM => _scaledDimension(
    mobile: 12,
    tablet: 16,
    desktop: 16,
    convert: _safeH,
  );

  /// Responsive gap L (large) - maps to UI.gapL
  double get responsiveGapL => _scaledDimension(
    mobile: 16,
    tablet: 24,
    desktop: 24,
    convert: _safeH,
  );

  /// Responsive horizontal gap S
  double get responsiveHorizontalGapS => _scaledDimension(
    mobile: 8,
    tablet: 10,
    desktop: 10,
    convert: _safeW,
  );

  /// Responsive horizontal gap M
  double get responsiveHorizontalGapM => _scaledDimension(
    mobile: 10,
    tablet: 12,
    desktop: 12,
    convert: _safeW,
  );

  /// Responsive horizontal gap L
  double get responsiveHorizontalGapL => _scaledDimension(
    mobile: 16,
    tablet: 24,
    desktop: 24,
    convert: _safeW,
  );

  // Common responsive EdgeInsets patterns
  /// Padding for cards with responsive values (EdgeInsets)
  EdgeInsets get responsiveCardPaddingInsets =>
      EdgeInsets.all(responsiveCardPadding);

  /// Padding for list items
  EdgeInsets get responsiveListItemPadding => EdgeInsets.symmetric(
    horizontal: responsiveHorizontalGapL,
    vertical: responsiveGapM,
  );

  /// Padding for error/empty states
  EdgeInsets get responsiveStatePadding => EdgeInsets.all(
    _scaledDimension(
      mobile: 24,
      tablet: 32,
      desktop: 32,
      convert: _safeW,
    ),
  );

  /// Padding for dialog content
  EdgeInsets get responsiveDialogPadding => EdgeInsets.symmetric(
    horizontal: _scaledDimension(
      mobile: 24,
      tablet: 32,
      desktop: 32,
      convert: _safeW,
    ),
    vertical: _scaledDimension(
      mobile: 20,
      tablet: 24,
      desktop: 24,
      convert: _safeH,
    ),
  );

  /// Padding for sheet content (with bottom inset consideration)
  EdgeInsets responsiveSheetPadding({final double extraBottom = 0}) =>
      EdgeInsets.fromLTRB(
        responsiveHorizontalGapL,
        responsiveGapM,
        responsiveHorizontalGapL,
        responsiveGapM + keyboardInset + extraBottom,
      );

  /// Padding for message bubbles
  EdgeInsets get responsiveBubblePadding => EdgeInsets.symmetric(
    horizontal: responsiveHorizontalGapM,
    vertical: responsiveGapS,
  );

  /// Margin for message bubbles
  EdgeInsets get responsiveBubbleMargin => EdgeInsets.symmetric(
    vertical: responsiveGapS / 2,
  );

  // Responsive icon sizes for common states
  /// Responsive icon size for error states
  double get responsiveErrorIconSize => _scaledDimension(
    mobile: 48,
    tablet: 64,
    desktop: 64,
    convert: _safeSp,
  );

  /// Responsive icon size for large error states
  double get responsiveErrorIconSizeLarge => _scaledDimension(
    mobile: 64,
    tablet: 80,
    desktop: 80,
    convert: _safeSp,
  );

  // General responsive helpers
  double widthFraction(final double fraction) => screenWidth * fraction;
  double heightFraction(final double fraction) => screenHeight * fraction;
  double clampWidthTo(final double max) => math.min(screenWidth, max);

  T responsiveValue<T>({
    required final T mobile,
    final T? tablet,
    final T? desktop,
  }) {
    final breakpoints = _breakpoints;
    final conditions = <Condition<T>>[];
    if (tablet != null) {
      conditions.add(
        Condition<T>.largerThan(
          breakpoint: (AppConstants.mobileBreakpoint - 1).round(),
          value: tablet,
        ),
      );
    }
    if (desktop != null) {
      conditions.add(
        Condition<T>.largerThan(
          breakpoint: (AppConstants.tabletBreakpoint - 1).round(),
          value: desktop,
        ),
      );
    }
    if (breakpoints != null && conditions.isNotEmpty) {
      return ResponsiveValue<T>(
        this,
        defaultValue: mobile,
        conditionalValues: conditions,
      ).value;
    }

    final double width = breakpoints?.screenWidth ?? _responsiveWidth;
    if (desktop != null && width >= AppConstants.tabletBreakpoint) {
      return desktop;
    }
    if (tablet != null && width >= AppConstants.mobileBreakpoint) {
      return tablet;
    }
    if (desktop != null &&
        tablet == null &&
        width >= AppConstants.mobileBreakpoint) {
      return desktop;
    }
    return mobile;
  }
}
