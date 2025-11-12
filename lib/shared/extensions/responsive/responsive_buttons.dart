part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Button sizing and styling helpers for responsive design.
extension ResponsiveButtonsContext on BuildContext {
  double get responsiveButtonHeight => _scaledHeight(
    this,
    mobile: 48,
    tablet: 56,
    desktop: 56,
  );

  double get responsiveButtonPadding => _scaledWidth(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 24,
  );

  /// Returns responsive button style with consistent padding and sizing
  ButtonStyle get responsiveButtonStyle => ButtonStyle(
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(
        horizontal: responsiveButtonPadding,
        vertical: responsiveGapM,
      ),
    ),
    minimumSize: WidgetStateProperty.all(
      Size(0, responsiveButtonHeight),
    ),
    textStyle: WidgetStateProperty.all(
      TextStyle(fontSize: responsiveBodySize),
    ),
  );

  /// Returns responsive elevated button style
  ButtonStyle get responsiveElevatedButtonStyle => ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: responsiveButtonPadding,
      vertical: responsiveGapM,
    ),
    minimumSize: Size(0, responsiveButtonHeight),
    textStyle: TextStyle(fontSize: responsiveBodySize),
  );

  /// Returns responsive text button style
  ButtonStyle get responsiveTextButtonStyle => TextButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: responsiveButtonPadding,
      vertical: responsiveGapM,
    ),
    minimumSize: Size(0, responsiveButtonHeight),
    textStyle: TextStyle(fontSize: responsiveBodySize),
  );

  /// Returns responsive filled button style
  ButtonStyle get responsiveFilledButtonStyle => FilledButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: responsiveButtonPadding,
      vertical: responsiveGapM,
    ),
    minimumSize: Size(0, responsiveButtonHeight),
    textStyle: TextStyle(fontSize: responsiveBodySize),
  );
}
