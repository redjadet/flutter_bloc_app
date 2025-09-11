import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Keep responsive_framework optional; fall back to width-based checks in tests
// ignore: unused_import
import 'package:responsive_framework/responsive_framework.dart';

extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;
  bool get isMobile => _width < 800;
  bool get isTabletOrLarger => _width >= 800;
  bool get isDesktop => _width >= 1200;
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  double get bottomInset => MediaQuery.viewPaddingOf(this).bottom;

  double _safeW(double v) {
    try {
      return v.w;
    } catch (_) {
      return v;
    }
  }

  double _safeH(double v) {
    try {
      return v.h;
    } catch (_) {
      return v;
    }
  }

  double get pageHorizontalPadding {
    if (isDesktop) return _safeW(32);
    if (isTabletOrLarger) return _safeW(24);
    return _safeW(16);
  }

  double get pageVerticalPadding {
    if (isDesktop || isTabletOrLarger) return _safeH(16);
    return _safeH(12);
  }

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

  EdgeInsets get pagePadding {
    final double extraBottom = isMobile && isPortrait ? _safeH(72) : 0;
    return EdgeInsets.fromLTRB(
      pageHorizontalPadding,
      pageVerticalPadding,
      pageHorizontalPadding,
      pageVerticalPadding + bottomInset + extraBottom,
    );
  }
}
