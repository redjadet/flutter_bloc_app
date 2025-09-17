import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Central place for UI spacings, radii and durations.
/// Use these helpers to keep sizes consistent and responsive.
class UI {
  // Animations
  static const Duration animFast = Duration(milliseconds: 180);
  static const Duration animMedium = Duration(milliseconds: 220);

  // Gaps (vertical by default)
  static double get gapXS => _h(6);
  static double get gapS => _h(8);
  static double get gapM => _h(12);
  static double get gapL => _h(16);

  // Horizontal gaps
  static double get horizontalGapXS => _w(6);
  static double get horizontalGapS => _w(8);
  static double get horizontalGapM => _w(10);
  static double get horizontalGapL => _w(16);

  // Card paddings
  static double get cardPadH => _w(20);
  static double get cardPadV => _h(16);

  // Radii
  static double get radiusM => _r(16);
  static double get radiusPill => _r(999);

  // Icon sizes
  static double get iconS => _spMax(16);
  static double get iconM => _spMax(20);
  static double get iconL => _spMax(24);

  // Misc
  static double get progressHeight => _h(6);
  static double get dividerThin => _h(1);

  // Safe adapters (fallback to raw when ScreenUtil not initialized)
  static double _w(double v) {
    try {
      return v.w;
    } catch (_) {
      return v;
    }
  }

  static double _h(double v) {
    try {
      return v.h;
    } catch (_) {
      return v;
    }
  }

  static double _r(double v) {
    try {
      return v.r;
    } catch (_) {
      return v;
    }
  }

  static double _spMax(double v) {
    try {
      return v.spMax;
    } catch (_) {
      return v;
    }
  }
}
