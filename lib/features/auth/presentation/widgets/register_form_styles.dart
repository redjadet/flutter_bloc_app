import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle registerTitleStyle(final BuildContext context) =>
    GoogleFonts.comfortaa(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 40.14 / 36,
      letterSpacing: -0.54,
      color: Theme.of(context).colorScheme.onSurface,
    );

TextStyle registerLabelStyle(final BuildContext context) => GoogleFonts.roboto(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  height: 17.58 / 15,
  color: Theme.of(context).colorScheme.onSurface,
);

TextStyle registerFieldTextStyle(final BuildContext context) =>
    GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 19.0 / 16,
      color: Theme.of(context).colorScheme.onSurface,
    );

InputDecoration registerInputDecoration(
  final BuildContext context, {
  required final String hint,
  final String? errorText,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final borderRadius = BorderRadius.circular(10);
  final double overlayAlpha = theme.brightness == Brightness.dark ? 0.16 : 0.04;
  final Color fillColor = Color.alphaBlend(
    colorScheme.onSurface.withValues(alpha: overlayAlpha),
    colorScheme.surface,
  );

  return InputDecoration(
    hintText: hint,
    hintStyle:
        theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ) ??
        GoogleFonts.roboto(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 18.0 / 15,
          color: colorScheme.onSurfaceVariant,
        ),
    errorText: errorText,
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
