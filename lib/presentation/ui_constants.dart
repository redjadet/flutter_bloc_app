import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Central place for UI spacings, radii and durations.
/// Use these helpers to keep sizes consistent and responsive.
class UI {
  // Animations
  static const Duration animFast = Duration(milliseconds: 180);
  static const Duration animMedium = Duration(milliseconds: 220);

  // Gaps (vertical by default)
  static double get gapXS => 6.h;
  static double get gapS => 8.h;
  static double get gapM => 12.h;
  static double get gapL => 16.h;

  // Horizontal gaps
  static double get hgapXS => 6.w;
  static double get hgapS => 8.w;
  static double get hgapM => 10.w;
  static double get hgapL => 16.w;

  // Card paddings
  static double get cardPadH => 20.w;
  static double get cardPadV => 16.h;

  // Radii
  static double get radiusM => 16.r;
  static double get radiusPill => 999.r;

  // Icon sizes
  static double get iconS => 16.spMax;
  static double get iconM => 20.spMax;
  static double get iconL => 24.spMax;

  // Misc
  static double get progressHeight => 6.h;
  static double get dividerThin => 1.h;
}
