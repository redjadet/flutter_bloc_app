part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

double _rawWidth(final BuildContext context) => UI.isScreenUtilReady
    ? ScreenUtil().screenWidth
    : MediaQuery.sizeOf(context).width;

double _rawHeight(final BuildContext context) => UI.isScreenUtilReady
    ? ScreenUtil().screenHeight
    : MediaQuery.sizeOf(context).height;

double _safeW(final double value) => UI.isScreenUtilReady ? value.w : value;
double _safeH(final double value) => UI.isScreenUtilReady ? value.h : value;
double _safeSp(final double value) => UI.isScreenUtilReady ? value.sp : value;
double _safeR(final double value) => UI.isScreenUtilReady ? value.r : value;

ResponsiveBreakpointsData? _breakpoints(final BuildContext context) {
  final inheritedElement = context
      .getElementForInheritedWidgetOfExactType<
        InheritedResponsiveBreakpoints
      >();
  if (inheritedElement == null) {
    return null;
  }
  final inheritedWidget = inheritedElement.widget;
  if (inheritedWidget is! InheritedResponsiveBreakpoints) {
    return null;
  }
  final data = inheritedWidget.data;
  if (data.breakpoints.isEmpty) {
    return null;
  }
  return data;
}

double _responsiveWidth(final BuildContext context) =>
    _breakpoints(context)?.screenWidth ?? _rawWidth(context);

double _responsiveHeight(final BuildContext context) =>
    _breakpoints(context)?.screenHeight ?? _rawHeight(context);

Orientation _responsiveOrientation(final BuildContext context) =>
    _breakpoints(context)?.orientation ?? MediaQuery.orientationOf(context);

double _scaledDimension(
  final BuildContext context, {
  required final double Function(double value) convert,
  required final double mobile,
  final double? tablet,
  final double? desktop,
}) {
  final double baseValue = _responsiveValue<double>(
    context,
    mobile: mobile,
    tablet: tablet ?? desktop ?? mobile,
    desktop: desktop,
  );
  return convert(baseValue);
}

T _responsiveValue<T>(
  final BuildContext context, {
  required final T mobile,
  final T? tablet,
  final T? desktop,
}) {
  final breakpoints = _breakpoints(context);
  final conditions = <Condition<T>>[];
  if (tablet != null) {
    conditions.add(
      Condition<T>.largerThan(
        breakpoint: (AppConstants.mobileBreakpoint - 1).round(),
        value: tablet,
      ),
    );
  }
  if (desktop != null) {
    conditions.add(
      Condition<T>.largerThan(
        breakpoint: (AppConstants.tabletBreakpoint - 1).round(),
        value: desktop,
      ),
    );
  }
  if (breakpoints != null && conditions.isNotEmpty) {
    return ResponsiveValue<T>(
      context,
      defaultValue: mobile,
      conditionalValues: conditions,
    ).value;
  }

  final double width = breakpoints?.screenWidth ?? _responsiveWidth(context);
  if (desktop != null && width >= AppConstants.tabletBreakpoint) {
    return desktop;
  }
  if (tablet != null && width >= AppConstants.mobileBreakpoint) {
    return tablet;
  }
  if (desktop != null &&
      tablet == null &&
      width >= AppConstants.mobileBreakpoint) {
    return desktop;
  }
  return mobile;
}
