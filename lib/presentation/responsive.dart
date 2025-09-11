import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AppBreakpoints {
  static const String mobile = MOBILE; // 0–799
  static const String tablet = TABLET; // 800–1199
  static const String desktop = DESKTOP; // 1200+
}

extension ResponsiveContext on BuildContext {
  ResponsiveBreakpointsData get rb => ResponsiveBreakpoints.of(this);

  bool get isMobile => rb.smallerThan(AppBreakpoints.tablet);
  bool get isTabletOrLarger => rb.largerOrEqualTo(AppBreakpoints.tablet);
  bool get isDesktop => rb.largerOrEqualTo(AppBreakpoints.desktop);
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  double get bottomInset => MediaQuery.viewPaddingOf(this).bottom;

  double get pageHorizontalPadding {
    if (isDesktop) return 32.w;
    if (isTabletOrLarger) return 24.w;
    return 16.w;
  }

  double get pageVerticalPadding {
    if (isDesktop || isTabletOrLarger) return 16.h;
    return 12.h;
  }

  double get contentMaxWidth {
    if (isDesktop) return 840.w;
    if (isTabletOrLarger) return 720.w;
    return 560.w; // keep content comfortably narrow on large phones
  }

  double get barMaxWidth {
    if (isDesktop) return 900.w;
    if (isTabletOrLarger) return 720.w;
    return double.infinity;
  }

  EdgeInsets get pagePadding {
    final double extraBottom = isMobile && isPortrait ? 72.h : 0;
    return EdgeInsets.fromLTRB(
      pageHorizontalPadding,
      pageVerticalPadding,
      pageHorizontalPadding,
      pageVerticalPadding + bottomInset + extraBottom,
    );
  }
}
