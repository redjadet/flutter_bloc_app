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

  // Device type detection
  bool get isMobile => _width < AppConstants.mobileBreakpoint;
  bool get isTabletOrLarger => _width >= AppConstants.mobileBreakpoint;
  bool get isDesktop => _width >= AppConstants.tabletBreakpoint;
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isLandscape => !isPortrait;

  // Safe area helpers
  double get bottomInset => MediaQuery.viewPaddingOf(this).bottom;
  double get topInset => MediaQuery.viewPaddingOf(this).top;
  EdgeInsets get safeAreaInsets => MediaQuery.viewPaddingOf(this);

  // Safe ScreenUtil adapters with fallbacks
  double _safeW(double v) => UI.isScreenUtilReady ? v.w : v;
  double _safeH(double v) => UI.isScreenUtilReady ? v.h : v;
  double _safeSp(double v) => UI.isScreenUtilReady ? v.sp : v;
  double _safeR(double v) => UI.isScreenUtilReady ? v.r : v;

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
  EdgeInsets get responsivePageMargin =>
      EdgeInsets.symmetric(horizontal: pageHorizontalPadding, vertical: pageVerticalPadding);

  EdgeInsets get responsiveCardMargin => EdgeInsets.all(isMobile ? _safeW(8) : _safeW(12));

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
}
