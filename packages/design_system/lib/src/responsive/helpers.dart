part of 'responsive.dart';

double _responsiveWidth(BuildContext context) =>
    ResponsiveConfig.screenWidth(context);

double _responsiveHeight(BuildContext context) =>
    ResponsiveConfig.screenHeight(context);

Orientation _responsiveOrientation(BuildContext context) =>
    ResponsiveConfig.orientation(context);

double _scaledDimension(
  BuildContext context, {
  required double Function(double value) convert,
  required double mobile,
  double? tablet,
  double? desktop,
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
  BuildContext context, {
  required double mobile,
  double? tablet,
  double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleWidth,
);

double _scaledHeight(
  BuildContext context, {
  required double mobile,
  double? tablet,
  double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleHeight,
);

double _scaledFont(
  BuildContext context, {
  required double mobile,
  double? tablet,
  double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleFont,
);

double _scaledRadius(
  BuildContext context, {
  required double mobile,
  double? tablet,
  double? desktop,
}) => _scaledDimension(
  context,
  mobile: mobile,
  tablet: tablet,
  desktop: desktop,
  convert: UI.scaleRadius,
);

T _responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
}) {
  if (tablet == null && desktop == null) {
    return mobile;
  }

  final breakpointsData = ResponsiveConfig.maybeDataOf(context);
  if (breakpointsData != null) {
    final conditions = <Condition<T>>[
      if (tablet != null) Condition.largerThan(name: MOBILE, value: tablet),
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
  if (desktop != null && width >= LayoutBreakpoints.tabletBreakpoint) {
    return desktop;
  }
  final bool hasTabletValue = tablet != null;
  final T? tabletOrDesktop = hasTabletValue ? tablet : desktop;
  if (tabletOrDesktop != null && width >= LayoutBreakpoints.mobileBreakpoint) {
    return tabletOrDesktop;
  }
  return mobile;
}
