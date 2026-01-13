import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Builds a filled input decoration with consistent styling used in registration forms.
///
/// This helper consolidates the filled input decoration pattern used across
/// registration forms, providing consistent background colors, borders, and padding.
InputDecoration buildFilledInputDecoration(
  final BuildContext context, {
  final String? hintText,
  final String? errorText,
  final TextStyle? hintStyle,
  final double? horizontalPadding,
  final double? verticalPadding,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final borderRadius = BorderRadius.circular(context.responsiveCardRadius);
  final double overlayAlpha = theme.brightness == Brightness.dark ? 0.16 : 0.04;
  final Color fillColor = Color.alphaBlend(
    colorScheme.onSurface.withValues(alpha: overlayAlpha),
    colorScheme.surface,
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle:
        hintStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
    errorText: errorText,
    filled: true,
    fillColor: fillColor,
    contentPadding: EdgeInsets.symmetric(
      horizontal: horizontalPadding ?? 16,
      vertical: verticalPadding ?? 12,
    ),
    border: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.4),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.4),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
    ),
  );
}

InputDecoration buildCommonInputDecoration({
  required final BuildContext context,
  required final ThemeData theme,
  final String? labelText,
  final String? hintText,
  final String? helperText,
  final String? errorText,
  final Widget? prefixIcon,
  final Widget? suffixIcon,
  final bool includeErrorBorders = true,
}) {
  final borderRadius = BorderRadius.circular(context.responsiveCardRadius);
  final baseDecoration = InputDecoration(
    labelText: labelText,
    hintText: hintText,
    helperText: helperText,
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: borderRadius),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.5),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: context.responsiveHorizontalGapL,
      vertical: context.responsiveGapM,
    ),
  );

  if (!includeErrorBorders) {
    return baseDecoration;
  }

  return baseDecoration.copyWith(
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: theme.colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
    ),
  );
}
