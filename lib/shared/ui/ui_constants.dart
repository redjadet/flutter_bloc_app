import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Central place for UI spacings, radii and durations.
/// Use these helpers to keep sizes consistent and responsive.
class UI {
  UI._();

  static bool _screenUtilReady = false;

  static bool get screenUtilReady => _screenUtilReady;

  static set screenUtilReady(final bool ready) {
    if (_screenUtilReady == ready) {
      return;
    }
    _screenUtilReady = ready;
  }

  static bool get isScreenUtilReady => screenUtilReady;

  // Shared adapters so other modules don't duplicate ScreenUtil checks.
  static double scaleWidth(final double value) => _w(value);
  static double scaleHeight(final double value) => _h(value);
  static double scaleRadius(final double value) => _r(value);
  static double scaleFont(final double value) => _sp(value);
  static double scaleFontMax(final double value) => _spMax(value);

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
  static double _w(final double v) {
    if (!_screenUtilReady) return v;
    return v.w;
  }

  static double _h(final double v) {
    if (!_screenUtilReady) return v;
    return v.h;
  }

  static double _r(final double v) {
    if (!_screenUtilReady) return v;
    return v.r;
  }

  static double _sp(final double v) {
    if (!_screenUtilReady) return v;
    return v.sp;
  }

  static double _spMax(final double v) {
    if (!_screenUtilReady) return v;
    return v.spMax;
  }
}
