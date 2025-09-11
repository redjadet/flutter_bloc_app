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

  double get pageHorizontalPadding {
    if (isDesktop) return 32.w;
    if (isTabletOrLarger) return 20.w;
    return 12.w;
  }

  double get pageVerticalPadding => 12.h;

  double get contentMaxWidth {
    if (isDesktop) return 840;
    if (isTabletOrLarger) return 720;
    return double.infinity;
  }

  double get barMaxWidth {
    if (isDesktop) return 900;
    if (isTabletOrLarger) return 720;
    return double.infinity;
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: pageHorizontalPadding,
        vertical: pageVerticalPadding,
      );
}
