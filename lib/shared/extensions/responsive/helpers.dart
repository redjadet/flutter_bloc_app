part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

double _responsiveWidth(final BuildContext context) =>
    ResponsiveConfig.screenWidth(context);

double _responsiveHeight(final BuildContext context) =>
    ResponsiveConfig.screenHeight(context);

Orientation _responsiveOrientation(final BuildContext context) =>
    ResponsiveConfig.orientation(context);

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
  final breakpoints = ResponsiveConfig.maybeDataOf(context);
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
