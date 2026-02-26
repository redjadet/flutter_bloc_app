import 'package:flutter/material.dart';

/// Typography helpers that use the theme as the single source of truth.
///
/// These helpers ensure consistent typography across the app by deriving
/// text styles from the theme rather than hardcoding font families, sizes,
/// or weights.
///
/// For new code, prefer Mix text tokens and
/// [AppStyles](package:flutter_bloc_app/shared/design_system/app_styles.dart)
/// text styles (headingStyle, bodyStyle, captionStyle, etc.) where applicable;
/// they use the same theme text and integrate with Mix layout and variants.
/// This API remains supported for existing call sites.
///
/// **Usage:**
/// ```dart
/// Text(
///   'Hello',
///   style: AppTypography.buttonText(context),
/// )
/// ```
class AppTypography {
  AppTypography._();

  /// Gets button text style from theme with optional customization.
  ///
  /// Uses `labelLarge` from theme as base, which is the standard for buttons.
  /// Customizations (fontWeight, fontSize, etc.) are applied on top of theme.
  static TextStyle buttonText(
    final BuildContext context, {
    final FontWeight? fontWeight,
    final double? fontSize,
    final Color? color,
    final double? letterSpacing,
    final double? height,
  }) {
    final baseStyle = Theme.of(context).textTheme.labelLarge;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: fontWeight ?? baseStyle?.fontWeight,
      fontSize: fontSize ?? baseStyle?.fontSize,
      color: color ?? baseStyle?.color,
      letterSpacing: letterSpacing ?? baseStyle?.letterSpacing,
      height: height ?? baseStyle?.height,
    );
  }

  /// Gets body text style from theme with optional customization.
  ///
  /// Uses `bodyMedium` from theme as base.
  static TextStyle bodyText(
    final BuildContext context, {
    final FontWeight? fontWeight,
    final double? fontSize,
    final Color? color,
    final double? letterSpacing,
    final double? height,
  }) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: fontWeight ?? baseStyle?.fontWeight,
      fontSize: fontSize ?? baseStyle?.fontSize,
      color: color ?? baseStyle?.color,
      letterSpacing: letterSpacing ?? baseStyle?.letterSpacing,
      height: height ?? baseStyle?.height,
    );
  }

  /// Gets title text style from theme with optional customization.
  ///
  /// Uses `titleLarge` from theme as base.
  static TextStyle titleText(
    final BuildContext context, {
    final FontWeight? fontWeight,
    final double? fontSize,
    final Color? color,
    final double? letterSpacing,
    final double? height,
  }) {
    final baseStyle = Theme.of(context).textTheme.titleLarge;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: fontWeight ?? baseStyle?.fontWeight,
      fontSize: fontSize ?? baseStyle?.fontSize,
      color: color ?? baseStyle?.color,
      letterSpacing: letterSpacing ?? baseStyle?.letterSpacing,
      height: height ?? baseStyle?.height,
    );
  }

  /// Gets headline text style from theme with optional customization.
  ///
  /// Uses `headlineMedium` from theme as base.
  static TextStyle headlineText(
    final BuildContext context, {
    final FontWeight? fontWeight,
    final double? fontSize,
    final Color? color,
    final double? letterSpacing,
    final double? height,
  }) {
    final baseStyle = Theme.of(context).textTheme.headlineMedium;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: fontWeight ?? baseStyle?.fontWeight,
      fontSize: fontSize ?? baseStyle?.fontSize,
      color: color ?? baseStyle?.color,
      letterSpacing: letterSpacing ?? baseStyle?.letterSpacing,
      height: height ?? baseStyle?.height,
    );
  }

  /// Gets display text style from theme with optional customization.
  ///
  /// Uses `displayMedium` from theme as base (uses Comfortaa font per app_config).
  static TextStyle displayText(
    final BuildContext context, {
    final FontWeight? fontWeight,
    final double? fontSize,
    final Color? color,
    final double? letterSpacing,
    final double? height,
  }) {
    final baseStyle = Theme.of(context).textTheme.displayMedium;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: fontWeight ?? baseStyle?.fontWeight,
      fontSize: fontSize ?? baseStyle?.fontSize,
      color: color ?? baseStyle?.color,
      letterSpacing: letterSpacing ?? baseStyle?.letterSpacing,
      height: height ?? baseStyle?.height,
    );
  }

  /// Gets label text style from theme with optional customization.
  ///
  /// Uses `labelMedium` from theme as base.
  static TextStyle labelText(
    final BuildContext context, {
    final FontWeight? fontWeight,
    final double? fontSize,
    final Color? color,
    final double? letterSpacing,
    final double? height,
  }) {
    final baseStyle = Theme.of(context).textTheme.labelMedium;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: fontWeight ?? baseStyle?.fontWeight,
      fontSize: fontSize ?? baseStyle?.fontSize,
      color: color ?? baseStyle?.color,
      letterSpacing: letterSpacing ?? baseStyle?.letterSpacing,
      height: height ?? baseStyle?.height,
    );
  }
}
