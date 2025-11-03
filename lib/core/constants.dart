import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // Colors
  static const Color primarySeedColor = Color(0xFF6750A4);

  // Window sizing
  static const Size minWindowSize = Size(390, 390);
  static const Size designSize = Size(390, 844);

  // Responsive breakpoints
  static const double mobileBreakpoint = 800;
  static const double tabletBreakpoint = 1200;
  static const double compactWidthBreakpoint = 360;

  // Constraints
  static const double minContentWidth = 390;
  static const double minContentHeight = 390;

  // UI/UX
  static const Duration devSkeletonDelay = Duration(milliseconds: 1000);
}
