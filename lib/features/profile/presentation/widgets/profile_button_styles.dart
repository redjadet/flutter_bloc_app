import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:mix/mix.dart';

/// Builds [ButtonStyle] for profile outlined buttons using Mix design tokens.
///
/// Values align with [AppStyles.profileOutlinedButton] so styling stays
/// consistent with the design system.
ButtonStyle profileOutlinedButtonStyle(
  final BuildContext context, {
  required final Color backgroundColor,
}) {
  final mixTheme = MixTheme.maybeOf(context);
  final radius = mixTheme?.radii[AppMixTokens.radiusPill];
  final radiusValue = radius?.x ?? UI.radiusPill;
  final colors = Theme.of(context).colorScheme;
  final horizontalPadding = mixTheme?.spaces[AppMixTokens.gapM] ?? UI.gapM;
  final verticalPadding = mixTheme?.spaces[AppMixTokens.gapS] ?? UI.gapS;

  return OutlinedButton.styleFrom(
    backgroundColor: backgroundColor,
    side: BorderSide(width: 2, color: colors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusValue),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    ),
  );
}

/// Builds [TextStyle] for profile button labels using theme + Mix-aligned params.
///
/// Matches [AppStyles.profileOutlinedButton] typography (label large, w900).
TextStyle profileButtonTextStyle(
  final BuildContext context, {
  required final Color color,
  required final double fontSize,
}) {
  final base = Theme.of(context).textTheme.labelLarge;
  return (base ?? const TextStyle()).copyWith(
    fontWeight: FontWeight.w900,
    fontSize: fontSize,
    letterSpacing: 0.52,
    color: color,
    height: 15.234375 / 13,
  );
}
