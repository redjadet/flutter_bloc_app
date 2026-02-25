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
  /// default elevation 1.
  ///
  /// Uses [AppMixTokens] for padding and radius, [AppMaterialColorTokens]
  /// for background. Adapts to light/dark via Material theme resolvers.
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
}
