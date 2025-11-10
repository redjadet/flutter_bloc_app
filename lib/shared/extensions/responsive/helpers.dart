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

double _scaledWidth(
  final BuildContext context, {
  required final double mobile,
  final double? tablet,
  final double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleWidth,
);

double _scaledHeight(
  final BuildContext context, {
  required final double mobile,
  final double? tablet,
  final double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleHeight,
);

double _scaledFont(
  final BuildContext context, {
  required final double mobile,
  final double? tablet,
  final double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleFont,
);

double _scaledRadius(
  final BuildContext context, {
  required final double mobile,
  final double? tablet,
  final double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleRadius,
);

T _responsiveValue<T>(
  final BuildContext context, {
  required final T mobile,
  final T? tablet,
  final T? desktop,
}) {
  if (tablet == null && desktop == null) {
    return mobile;
  }

  final breakpointsData = ResponsiveConfig.maybeDataOf(context);
  if (breakpointsData != null) {
    final conditions = <Condition<T>>[
      if (tablet != null)
        Condition.largerThan(
          name: MOBILE,
          value: tablet,
        ),
      if (desktop != null)
        Condition.largerThan(
          name: tablet != null ? TABLET : MOBILE,
          value: desktop,
        ),
    ];
    if (conditions.isNotEmpty) {
      return ResponsiveValue<T>(
        context,
        defaultValue: mobile,
        conditionalValues: conditions,
      ).value;
    }
  }

  final double width =
      breakpointsData?.screenWidth ?? _responsiveWidth(context);
  if (desktop != null && width >= AppConstants.tabletBreakpoint) {
    return desktop;
  }
  final bool hasTabletValue = tablet != null;
  final T? tabletOrDesktop = hasTabletValue ? tablet : desktop;
  if (tabletOrDesktop != null && width >= AppConstants.mobileBreakpoint) {
    return tabletOrDesktop;
  }
  return mobile;
}
