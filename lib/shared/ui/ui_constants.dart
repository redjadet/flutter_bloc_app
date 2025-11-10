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
  static double scaleWidth(final double value) =>
      _scale(value, (final v) => v.w);
  static double scaleHeight(final double value) =>
      _scale(value, (final v) => v.h);
  static double scaleRadius(final double value) =>
      _scale(value, (final v) => v.r);
  static double scaleFont(final double value) =>
      _scale(value, (final v) => v.sp);
  static double scaleFontMax(final double value) =>
      _scale(value, (final v) => v.spMax);

  // Animations
  static const Duration animFast = Duration(milliseconds: 180);
  static const Duration animMedium = Duration(milliseconds: 220);

  // Gaps (vertical by default)
  static double get gapXS => scaleHeight(6);
  static double get gapS => scaleHeight(8);
  static double get gapM => scaleHeight(12);
  static double get gapL => scaleHeight(16);

  // Horizontal gaps
  static double get horizontalGapXS => scaleWidth(6);
  static double get horizontalGapS => scaleWidth(8);
  static double get horizontalGapM => scaleWidth(10);
  static double get horizontalGapL => scaleWidth(16);

  // Card paddings
  static double get cardPadH => scaleWidth(20);
  static double get cardPadV => scaleHeight(16);

  // Radii
  static double get radiusM => scaleRadius(16);
  static double get radiusPill => scaleRadius(999);

  // Icon sizes
  static double get iconS => scaleFontMax(16);
  static double get iconM => scaleFontMax(20);
  static double get iconL => scaleFontMax(24);

  // Misc
  static double get progressHeight => scaleHeight(6);
  static double get dividerThin => scaleHeight(1);

  // Safe adapters (fallback to raw when ScreenUtil not initialized)
  static double _scale(
    final double value,
    final double Function(double value) transformer,
  ) => _screenUtilReady ? transformer(value) : value;
}
