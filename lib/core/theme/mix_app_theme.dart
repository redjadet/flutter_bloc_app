import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:mix/mix.dart';

/// Application design tokens for the Mix theme.
///
/// Token names are used as keys in [MixScope]. Use these tokens in Mix stylers
/// (e.g. [BoxStyler], [TextStyler]) so values stay consistent and theme-aware.
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

/// Text style token names for Mix theme.
///
/// Registered in buildAppMixThemeData from the Material text theme so
/// AppStyles heading/body/caption styles can reference theme text.
class AppTextStyleTokens {
  AppTextStyleTokens._();

  static const TextStyleToken titleLarge = TextStyleToken(
    'app.text.theme.title.large',
  );
  static const TextStyleToken titleMedium = TextStyleToken(
    'app.text.theme.title.medium',
  );
  static const TextStyleToken bodyLarge = TextStyleToken(
    'app.text.theme.body.large',
  );
  static const TextStyleToken bodyMedium = TextStyleToken(
    'app.text.theme.body.medium',
  );
  static const TextStyleToken labelMedium = TextStyleToken(
    'app.text.theme.label.medium',
  );
  static const TextStyleToken labelSmall = TextStyleToken(
    'app.text.theme.label.small',
  );
}

/// Material color token names (must match [MaterialTokens] in mix where applicable).
///
/// Use with [ColorToken] in styles so colors resolve from [Theme.of(context)].
/// Custom tokens (e.g. surfaceContainerLow) are filled in [buildAppMixScope].
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

  /// Input/field container background.
  static const ColorToken surfaceContainerHighest = ColorToken(
    'app.color.surfaceContainerHighest',
  );

  /// Input/field border (e.g. outlineVariant).
  static const ColorToken outlineVariant = ColorToken(
    'md.color.outline.variant',
  );
}

/// Wraps [child] with a [MixScope] configured for this app.
///
/// Call from inside `MaterialApp.builder` so [Theme] and [UI] are available.
Widget buildAppMixScope(final BuildContext context, {required Widget child}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;
  return MixScope.withMaterial(
    colors: {
      AppMaterialColorTokens.surfaceContainerLow:
          colorScheme.surfaceContainerLow,
      AppMaterialColorTokens.surfaceContainerHighest:
          colorScheme.surfaceContainerHighest,
      AppMaterialColorTokens.outlineVariant: colorScheme.outlineVariant,
    },
    textStyles: {
      AppTextStyleTokens.titleLarge: textTheme.titleLarge ?? const TextStyle(),
      AppTextStyleTokens.titleMedium:
          textTheme.titleMedium ?? const TextStyle(),
      AppTextStyleTokens.bodyLarge: textTheme.bodyLarge ?? const TextStyle(),
      AppTextStyleTokens.bodyMedium: textTheme.bodyMedium ?? const TextStyle(),
      AppTextStyleTokens.labelMedium:
          textTheme.labelMedium ?? const TextStyle(),
      AppTextStyleTokens.labelSmall: textTheme.labelSmall ?? const TextStyle(),
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
      BreakpointToken.mobile: const Breakpoint(
        maxWidth: AppConstants.mobileBreakpoint - 1,
      ),
      BreakpointToken.tablet: const Breakpoint(
        minWidth: AppConstants.mobileBreakpoint,
        maxWidth: AppConstants.tabletBreakpoint - 1,
      ),
      BreakpointToken.desktop: const Breakpoint(
        minWidth: AppConstants.tabletBreakpoint,
      ),
    },
    child: child,
  );
}
