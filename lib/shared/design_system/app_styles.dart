import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:mix/mix.dart';

part 'app_styles_layout.part.dart';

/// Material text theme token for label large (button text).
const TextStyleToken _labelLargeToken = TextStyleToken(
  'md3.text.theme.label.large',
);

// App text tokens (see [AppTextStyleTokens]) are registered in
// [buildAppMixScope] from Theme.textTheme.

/// Shared Mix stylers using app tokens.
///
/// Use these styles for consistent card, button, and text appearance across
/// the app. All values come from [MixScope] tokens (colors, spaces, radii) so
/// they stay theme-aware and responsive.
class AppStyles {
  AppStyles._();

  /// Named variant for outlined button style (border, transparent fill).
  static const NamedVariant outlined = NamedVariant('outlined');

  static BoxStyler get card => BoxStyler()
      .color(AppMaterialColorTokens.surface())
      .borderRadiusAll(AppMixTokens.radiusM())
      .elevation(.one)
      .padding(
        EdgeInsetsGeometryMix.only(
          top: AppMixTokens.cardPadV(),
          bottom: AppMixTokens.cardPadV(),
          left: AppMixTokens.cardPadH(),
          right: AppMixTokens.cardPadH(),
        ),
      )
      .onDark(BoxStyler().shadows(const []));

  /// Profile-style outlined button: surface fill, thick primary border,
  /// pill radius, bold label text.
  static BoxStyler get profileOutlinedButton => BoxStyler()
      .color(AppMaterialColorTokens.surface())
      .border(
        .all(
          BorderSideMix(
            color: AppMaterialColorTokens.primary(),
            width: 2,
          ),
        ),
      )
      .borderRadiusAll(AppMixTokens.radiusPill())
      .paddingY(AppMixTokens.gapS())
      .paddingX(AppMixTokens.gapM());

  static TextStyler get profileOutlinedButtonText => TextStyler()
      .style(_labelLargeToken.mix())
      .color(AppMaterialColorTokens.onSurface())
      .fontWeight(.w900);

  static BoxStyler get filledButton => BoxStyler()
      .color(AppMaterialColorTokens.primary())
      .borderRadiusAll(AppMixTokens.radiusPill())
      .paddingY(AppMixTokens.gapS())
      .paddingX(AppMixTokens.gapM());

  static TextStyler get filledButtonText => TextStyler()
      .style(_labelLargeToken.mix())
      .color(AppMaterialColorTokens.onPrimary())
      .fontWeight(.w600);

  static BoxStyler get outlinedButton => BoxStyler()
      .color(AppMaterialColorTokens.surface())
      .border(
        .all(
          BorderSideMix(
            color: AppMaterialColorTokens.primary(),
            width: 1.5,
          ),
        ),
      )
      .borderRadiusAll(AppMixTokens.radiusPill())
      .paddingY(AppMixTokens.gapS())
      .paddingX(AppMixTokens.gapM());

  static TextStyler get outlinedButtonText => TextStyler()
      .style(_labelLargeToken.mix())
      .color(AppMaterialColorTokens.onSurface())
      .fontWeight(.w600);

  /// List-tile row style: horizontal and vertical padding from tokens.
  /// On tablet/desktop breakpoints, horizontal padding increases.
  static BoxStyler get listTile => BoxStyler()
      .padding(
        EdgeInsetsGeometryMix.symmetric(
          vertical: AppMixTokens.gapS(),
          horizontal: AppMixTokens.gapM(),
        ),
      )
      .onTablet(BoxStyler().paddingX(AppMixTokens.gapL()))
      .onDesktop(BoxStyler().paddingX(AppMixTokens.gapL()));

  /// Input field container style: padding, radius, surface-container
  /// background, and light border. Use with [Box] to wrap [TextField] or
  /// custom input content.
  static BoxStyler get inputField => BoxStyler()
      .color(AppMaterialColorTokens.surfaceContainerHighest())
      .border(
        .all(
          BorderSideMix(color: AppMaterialColorTokens.outlineVariant()),
        ),
      )
      .padding(
        EdgeInsetsGeometryMix.symmetric(
          vertical: AppMixTokens.gapM(),
          horizontal: AppMixTokens.gapL(),
        ),
      )
      .borderRadiusAll(AppMixTokens.radiusM());

  /// Input field shell: same as [inputField] but no padding. Use when
  /// [TextField] (or child) supplies its own contentPadding so height
  /// matches single-line fields.
  static BoxStyler get inputFieldShell => BoxStyler()
      .color(AppMaterialColorTokens.surfaceContainerHighest())
      .border(
        .all(
          BorderSideMix(color: AppMaterialColorTokens.outlineVariant()),
        ),
      )
      .borderRadiusAll(AppMixTokens.radiusM());

  /// Shared field outline for custom controls that need to match TextField
  /// borders without adopting [inputField] padding/background.
  static BoxStyler get inputOutline => BoxStyler()
      .border(
        .all(
          BorderSideMix(color: AppMaterialColorTokens.outlineVariant()),
        ),
      )
      .borderRadiusAll(AppMixTokens.radiusS());

  /// App bar area style: token-based horizontal/vertical padding, no elevation.
  /// Use with [Box] for custom app bar content.
  static BoxStyler get appBar => _appStylesAppBar;

  /// Banner/full-width bar style: horizontal and vertical padding, no
  /// elevation. On medium+ breakpoints horizontal padding increases.
  /// Use with [Box] or `CommonCard` for status/info bars.
  static BoxStyler get banner => _appStylesBanner;

  /// Empty state container: generous padding for centered icon/message.
  /// Use with [Box] wrapping empty-state content.
  static BoxStyler get emptyState => _appStylesEmptyState;

  /// Chip-style container: surfaceContainerLow background (matches Material 3
  /// Chip), pill radius, compact padding. On medium+ breakpoints horizontal
  /// padding increases. Use with [Box] for chip-like labels.
  static BoxStyler get chip => _appStylesChip;

  /// Compact positive status badge from DESIGN.md.
  static BoxStyler get statusSuccess => _appStylesStatusSuccess;

  static TextStyler get statusSuccessText => _appStylesStatusSuccessText;

  /// Compact error status badge from DESIGN.md.
  static BoxStyler get statusError => _appStylesStatusError;

  static TextStyler get statusErrorText => _appStylesStatusErrorText;

  /// Dialog/sheet content padding from tokens.
  /// Use with [Box] to wrap dialog or bottom sheet body content.
  static BoxStyler get dialogContent => _appStylesDialogContent;

  static TextStyler get headingStyle => _appStylesHeadingStyle;

  static TextStyler get subheadingStyle => _appStylesSubheadingStyle;

  static TextStyler get bodyStyle => _appStylesBodyStyle;

  static TextStyler get bodyLargeStyle => _appStylesBodyLargeStyle;

  static TextStyler get captionStyle => _appStylesCaptionStyle;

  static TextStyler get captionSmallStyle => _appStylesCaptionSmallStyle;
}
