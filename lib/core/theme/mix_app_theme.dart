import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:mix/mix.dart';

/// Application design tokens for the Mix theme.
///
/// Token names are used as keys in [MixThemeData]. Use these tokens in
/// [Style] definitions so values stay consistent and theme-aware.
class AppMixTokens {
  AppMixTokens._();

  // ─────────────────────────────────────────────────────────────────────────
  // Space tokens (map to [UI] scaled values at theme build time)
  // ─────────────────────────────────────────────────────────────────────────

  static const SpaceToken gapXS = SpaceToken('app.space.gapXS');
  static const SpaceToken gapS = SpaceToken('app.space.gapS');
  static const SpaceToken gapM = SpaceToken('app.space.gapM');
  static const SpaceToken gapL = SpaceToken('app.space.gapL');
  static const SpaceToken cardPadH = SpaceToken('app.space.cardPadH');
  static const SpaceToken cardPadV = SpaceToken('app.space.cardPadV');

  // ─────────────────────────────────────────────────────────────────────────
  // Radius tokens
  // ─────────────────────────────────────────────────────────────────────────

  static const RadiusToken radiusM = RadiusToken('app.radius.radiusM');
  static const RadiusToken radiusPill = RadiusToken('app.radius.radiusPill');
}

/// Material color token names (must match [MaterialTokens] in mix where applicable).
///
/// Use with [ColorToken] in styles so colors resolve from [Theme.of(context)].
/// Custom tokens (e.g. surfaceContainerLow) are filled in [buildAppMixThemeData].
class AppMaterialColorTokens {
  AppMaterialColorTokens._();

  static const ColorToken surface = ColorToken('md.color.surface');
  static const ColorToken primary = ColorToken('md.color.primary');
  static const ColorToken onPrimary = ColorToken('md.color.on.primary');
  static const ColorToken onSurface = ColorToken('md.color.on.surface');

  /// Chip/filled surface tint; matches Material 3 Chip background.
  static const ColorToken surfaceContainerLow = ColorToken(
    'app.color.surfaceContainerLow',
  );
}

/// Builds [MixThemeData] from the current [BuildContext].
///
/// Uses Theme and Material resolvers via [MixThemeData.withMaterial], and
/// [UI] / [AppConstants] for spaces, radii, and breakpoints. Call from
/// inside [MaterialApp] builder so Theme and ScreenUtil are available.
MixThemeData buildAppMixThemeData(final BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return MixThemeData.withMaterial(
    colors: {
      AppMaterialColorTokens.surfaceContainerLow:
          colorScheme.surfaceContainerLow,
    },
    spaces: {
      AppMixTokens.gapXS: UI.gapXS,
      AppMixTokens.gapS: UI.gapS,
      AppMixTokens.gapM: UI.gapM,
      AppMixTokens.gapL: UI.gapL,
      AppMixTokens.cardPadH: UI.cardPadH,
      AppMixTokens.cardPadV: UI.cardPadV,
    },
    radii: {
      AppMixTokens.radiusM: Radius.circular(UI.radiusM),
      AppMixTokens.radiusPill: Radius.circular(UI.radiusPill),
    },
    breakpoints: {
      BreakpointToken.xsmall: const Breakpoint(
        maxWidth: AppConstants.mobileBreakpoint - 1,
      ),
      BreakpointToken.small: const Breakpoint(
        minWidth: AppConstants.mobileBreakpoint,
        maxWidth: AppConstants.tabletBreakpoint - 1,
      ),
      BreakpointToken.medium: const Breakpoint(
        minWidth: AppConstants.tabletBreakpoint,
      ),
      BreakpointToken.large: const Breakpoint(
        minWidth: AppConstants.tabletBreakpoint,
      ),
    },
  );
}
