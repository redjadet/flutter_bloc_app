import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Keep responsive_framework optional; fall back to width-based checks in tests
// ignore: unused_import
import 'package:responsive_framework/responsive_framework.dart';

/// Extension providing responsive utilities and breakpoint helpers
extension ResponsiveContext on BuildContext {
  // Private getters for consistent access
  double get _width => MediaQuery.sizeOf(this).width;
  double get _height => MediaQuery.sizeOf(this).height;

  /// Raw screen size helpers
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => _width;
  double get screenHeight => _height;

  // Device type detection
  bool get isMobile => _width < AppConstants.mobileBreakpoint;
  bool get isTabletOrLarger => _width >= AppConstants.mobileBreakpoint;
  bool get isDesktop => _width >= AppConstants.tabletBreakpoint;
  bool get isCompactWidth => _width < AppConstants.compactWidthBreakpoint;
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isLandscape => !isPortrait;

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

  // Responsive padding system
  double get pageHorizontalPadding {
    if (isDesktop) return _safeW(32);
    if (isTabletOrLarger) return _safeW(24);
    return _safeW(16);
  }

  double get pageVerticalPadding {
    if (isDesktop || isTabletOrLarger) return _safeH(16);
    return _safeH(12);
  }

  // Content width constraints
  double get contentMaxWidth {
    if (isDesktop) return _safeW(840);
    if (isTabletOrLarger) return _safeW(720);
    return _safeW(560); // keep content comfortably narrow on large phones
  }

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
  double get responsiveFontSize => isMobile ? _safeSp(14) : _safeSp(16);
  double get responsiveIconSize => isMobile ? _safeSp(20) : _safeSp(24);

  // Grid columns based on screen size
  int get gridColumns {
    if (isDesktop) return 4;
    if (isTabletOrLarger) return 3;
    return 2;
  }

  // Responsive spacing
  double get responsiveGap => isMobile ? _safeH(8) : _safeH(12);
  double get responsiveCardPadding => isMobile ? _safeW(16) : _safeW(20);

  // Additional responsive utilities for specific use cases
  double get responsiveButtonHeight => isMobile ? _safeH(48) : _safeH(56);
  double get responsiveButtonPadding => isMobile ? _safeW(16) : _safeW(24);

  // Responsive text styles
  double get responsiveHeadlineSize => isMobile ? _safeSp(24) : _safeSp(32);
  double get responsiveTitleSize => isMobile ? _safeSp(20) : _safeSp(24);
  double get responsiveBodySize => isMobile ? _safeSp(14) : _safeSp(16);
  double get responsiveCaptionSize => isMobile ? _safeSp(12) : _safeSp(14);

  // Responsive margins and paddings
  EdgeInsets get responsivePageMargin => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );

  EdgeInsets get responsiveCardMargin =>
      EdgeInsets.all(isMobile ? _safeW(8) : _safeW(12));

  EdgeInsets get responsiveListPadding => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: isMobile ? _safeH(8) : _safeH(12),
  );

  // Responsive border radius
  double get responsiveBorderRadius => isMobile ? _safeR(8) : _safeR(12);
  double get responsiveCardRadius => isMobile ? _safeR(12) : _safeR(16);

  // Responsive elevation
  double get responsiveElevation => isMobile ? 2.0 : 4.0;
  double get responsiveCardElevation => isMobile ? 1.0 : 2.0;

  // Common responsive spacing helpers
  /// Responsive gap XS (extra small)
  double get responsiveGapXS => isMobile ? _safeH(6) : _safeH(8);

  /// Responsive gap S (small) - maps to UI.gapS
  double get responsiveGapS => isMobile ? _safeH(8) : _safeH(10);

  /// Responsive gap M (medium) - maps to UI.gapM
  double get responsiveGapM => isMobile ? _safeH(12) : _safeH(16);

  /// Responsive gap L (large) - maps to UI.gapL
  double get responsiveGapL => isMobile ? _safeH(16) : _safeH(24);

  /// Responsive horizontal gap S
  double get responsiveHorizontalGapS => isMobile ? _safeW(8) : _safeW(10);

  /// Responsive horizontal gap M
  double get responsiveHorizontalGapM => isMobile ? _safeW(10) : _safeW(12);

  /// Responsive horizontal gap L
  double get responsiveHorizontalGapL => isMobile ? _safeW(16) : _safeW(24);

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
    isMobile ? _safeW(24) : _safeW(32),
  );

  /// Padding for dialog content
  EdgeInsets get responsiveDialogPadding => EdgeInsets.symmetric(
    horizontal: isMobile ? _safeW(24) : _safeW(32),
    vertical: isMobile ? _safeH(20) : _safeH(24),
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
  double get responsiveErrorIconSize => isMobile ? _safeSp(48) : _safeSp(64);

  /// Responsive icon size for large error states
  double get responsiveErrorIconSizeLarge =>
      isMobile ? _safeSp(64) : _safeSp(80);

  // General responsive helpers
  double widthFraction(final double fraction) => screenWidth * fraction;
  double heightFraction(final double fraction) => screenHeight * fraction;
  double clampWidthTo(final double max) => math.min(screenWidth, max);

  T responsiveValue<T>({
    required final T mobile,
    final T? tablet,
    final T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTabletOrLarger && tablet != null) return tablet;
    return mobile;
  }
}
