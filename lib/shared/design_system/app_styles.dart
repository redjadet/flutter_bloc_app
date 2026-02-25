import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:mix/mix.dart';

/// Material text theme token for label large (button text).
const TextStyleToken _labelLargeToken = TextStyleToken(
  'md3.text.theme.label.large',
);

/// Shared [Style] definitions using Mix tokens.
///
/// Use these styles for consistent card, button, and text appearance across
/// the app. All values come from [MixThemeData] (colors, spaces, radii) so
/// they stay theme-aware and responsive.
class AppStyles {
  AppStyles._();

  /// Named variant for outlined button style (border, transparent fill).
  static const Variant outlined = Variant('outlined');

  /// Card style: surface background, rounded corners, standard padding,
  /// default elevation 1. Dark mode uses slightly lower elevation.
  ///
  /// Uses [AppMixTokens] for padding and radius, [AppMaterialColorTokens]
  /// for background. Adapts to light/dark via Material theme resolvers and
  /// `$on.dark` context variant.
  static Style get card => Style(
    $box.color.ref(AppMaterialColorTokens.surface),
    $box.borderRadius.all.ref(AppMixTokens.radiusM),
    $box.decoration.elevation(1),
    $box.padding.only(
      top: AppMixTokens.cardPadV(),
      bottom: AppMixTokens.cardPadV(),
      left: AppMixTokens.cardPadH(),
      right: AppMixTokens.cardPadH(),
    ),
    $on.dark($box.decoration.elevation(0)),
  );

  /// Profile-style outlined button: surface fill, thick primary border,
  /// pill radius, bold label text.
  static Style get profileOutlinedButton => Style(
    $box.color.ref(AppMaterialColorTokens.surface),
    $box.decoration(
      border: Border.all(
        color: AppMaterialColorTokens.primary(),
        width: 2,
      ),
    ),
    $box.borderRadius.all.ref(AppMixTokens.radiusPill),
    $box.padding.vertical.ref(AppMixTokens.gapS),
    $box.padding.horizontal.ref(AppMixTokens.gapM),
    $text.style.ref(_labelLargeToken),
    $text.style.color.ref(AppMaterialColorTokens.onSurface),
    $text.style.fontWeight.w900(),
  );

  /// List-tile row style: horizontal and vertical padding from tokens.
  /// On medium/large breakpoints, horizontal padding increases via `$on.medium`.
  static Style get listTile => Style(
    $box.padding.vertical.ref(AppMixTokens.gapS),
    $box.padding.horizontal.ref(AppMixTokens.gapM),
    $on.medium($box.padding.horizontal.ref(AppMixTokens.gapL)),
  );

  /// Input field container style: padding and radius from tokens.
  /// Use with [Box] to wrap custom input content.
  static Style get inputField => Style(
    $box.padding.vertical.ref(AppMixTokens.gapM),
    $box.padding.horizontal.ref(AppMixTokens.gapL),
    $box.borderRadius.all.ref(AppMixTokens.radiusM),
  );

  /// App bar area style: horizontal padding from card tokens, no elevation.
  /// Use with [Box] for custom app bar content.
  static Style get appBar => Style(
    $box.padding.horizontal.ref(AppMixTokens.cardPadH),
    $box.decoration.elevation(0),
  );

  /// Chip-style container: surfaceContainerLow background (matches Material 3
  /// Chip), pill radius, compact padding. Use with [Box] for chip-like labels.
  static Style get chip => Style(
    $box.color.ref(AppMaterialColorTokens.surfaceContainerLow),
    $box.borderRadius.all.ref(AppMixTokens.radiusPill),
    $box.padding.vertical.ref(AppMixTokens.gapS),
    $box.padding.horizontal.ref(AppMixTokens.gapS),
  );

  /// Dialog/sheet content padding from tokens.
  /// Use with [Box] to wrap dialog or bottom sheet body content.
  static Style get dialogContent => Style(
    $box.padding.only(
      top: AppMixTokens.gapL(),
      bottom: AppMixTokens.gapL(),
      left: AppMixTokens.cardPadH(),
      right: AppMixTokens.cardPadH(),
    ),
  );
}
