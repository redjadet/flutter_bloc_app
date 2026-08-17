import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../tokens/layout_breakpoints.dart';
import '../ui/ui_constants.dart';

/// Centralizes responsive configuration so ScreenUtil/ResponsiveFramework share
/// the same breakpoints and context helpers.
class ResponsiveConfig {
  const ResponsiveConfig._();

  static const List<Breakpoint> breakpoints = [
    Breakpoint(
      start: 0,
      end: LayoutBreakpoints.mobileBreakpoint - 1,
      name: MOBILE,
    ),
    Breakpoint(
      start: LayoutBreakpoints.mobileBreakpoint,
      end: LayoutBreakpoints.tabletBreakpoint - 1,
      name: TABLET,
    ),
    Breakpoint(
      start: LayoutBreakpoints.tabletBreakpoint,
      end: double.infinity,
      name: DESKTOP,
    ),
  ];

  static ResponsiveBreakpointsData dataOf(BuildContext context) =>
      maybeDataOf(context) ?? const ResponsiveBreakpointsData();

  static ResponsiveBreakpointsData? maybeDataOf(BuildContext context) {
    final inheritedElement = context
        .getElementForInheritedWidgetOfExactType<
          InheritedResponsiveBreakpoints
        >();
    if (inheritedElement == null) {
      return null;
    }
    final widget = inheritedElement.widget;
    if (widget is! InheritedResponsiveBreakpoints) {
      return null;
    }
    final data = widget.data;
    if (data.breakpoints.isEmpty) {
      return null;
    }
    return data;
  }

  static double screenWidth(BuildContext context) {
    final data = maybeDataOf(context);
    if (data != null && data.screenWidth > 0) {
      return data.screenWidth;
    }
    if (UI.isScreenUtilReady) {
      return ScreenUtil().screenWidth;
    }
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    final data = maybeDataOf(context);
    if (data != null && data.screenHeight > 0) {
      return data.screenHeight;
    }
    if (UI.isScreenUtilReady) {
      return ScreenUtil().screenHeight;
    }
    return MediaQuery.sizeOf(context).height;
  }

  static Orientation orientation(BuildContext context) {
    if (maybeDataOf(context) case final data?) {
      return data.orientation;
    }
    return MediaQuery.orientationOf(context);
  }
}
