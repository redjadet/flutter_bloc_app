import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

/// EPOCH Library Design System Colors
class EpochColors {
  const EpochColors._();

  /// Warm Grey Lightest (#E8E7DE) - Primary text and UI on dark backgrounds
  static const Color warmGreyLightest = Color(0xFFE8E7DE);

  /// Warm Grey (#9D9C93) - Placeholder text
  static const Color warmGrey = Color(0xFF9D9C93);

  /// Ash (#877A7A) - Secondary text and metadata
  static const Color ash = Color(0xFF877A7A);

  /// Ash Darker (#736868) - Waveform and decorative elements
  static const Color ashDarker = Color(0xFF736868);

  /// Dark Grey (#231F20) - Main panel background
  static const Color darkGrey = Color(0xFF231F20);

  /// Pink (#FFC9C1) - Audio asset background (alternative)
  static const Color pink = Color(0xFFFFC9C1);

  /// Purple (#C4BAFF) - Audio asset background (primary)
  static const Color purple = Color(0xFFC4BAFF);
}

/// EPOCH Library Design System Typography
class EpochTextStyles {
  const EpochTextStyles._();

  static double _scaledWordmarkSize(final BuildContext context) =>
      context.responsiveHeadlineSize * 2.5;

  static double _scaledTitleSize(final BuildContext context) =>
      context.responsiveTitleSize * 0.9;

  /// Wordmark style (60px, Libre Caslon Text, -1.8px letter spacing)
  static TextStyle wordmark(final BuildContext context) => TextStyle(
    fontFamily: 'LibreCaslonText',
    fontSize: _scaledWordmarkSize(context),
    fontWeight: FontWeight.w400,
    letterSpacing: -1.8,
    height: 1,
    color: EpochColors.darkGrey,
  );

  /// Heading style (24px, Libre Caslon Text, -0.72px letter spacing)
  static TextStyle heading(final BuildContext context) => TextStyle(
    fontFamily: 'LibreCaslonText',
    fontSize: context.responsiveHeadlineSize,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.72,
    height: 1.14,
    color: EpochColors.warmGreyLightest,
  );

  /// Asset name style (18px, Libre Caslon Text, -0.36px letter spacing)
  static TextStyle assetName(final BuildContext context) => TextStyle(
    fontFamily: 'LibreCaslonText',
    fontSize: _scaledTitleSize(context),
    fontWeight: FontWeight.w400,
    letterSpacing: -0.36,
    height: 1.1,
    color: EpochColors.warmGreyLightest,
  );

  /// Label style (18px, IBM Plex Mono SemiBold, -0.9px letter spacing, uppercase)
  static TextStyle label(final BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: _scaledTitleSize(context),
    fontWeight: FontWeight.w600,
    letterSpacing: -0.9,
    height: 1,
    color: EpochColors.warmGreyLightest,
  );

  /// Metadata style (14px, IBM Plex Mono SemiBold, -0.28px letter spacing, uppercase)
  static TextStyle metadata(final BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: context.responsiveBodySize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.28,
    height: 1.1,
    color: EpochColors.ash,
  );

  /// Search placeholder style (18px, IBM Plex Mono Light, -0.9px letter spacing, uppercase)
  static TextStyle searchPlaceholder(final BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: _scaledTitleSize(context),
    fontWeight: FontWeight.w300,
    letterSpacing: -0.9,
    height: 1,
    color: EpochColors.warmGrey,
  );

  /// Asset type style (14px, IBM Plex Mono SemiBold, -0.28px letter spacing, uppercase)
  static TextStyle assetType(final BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: context.responsiveBodySize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.28,
    height: 1.1,
    color: EpochColors.ash,
  );
}

/// EPOCH Library Design System Spacing
class EpochSpacing {
  const EpochSpacing._();

  static double get topPadding => UI.scaleHeight(32);
  static double get panelPadding => UI.scaleWidth(16);
  static double get panelPaddingTop => UI.scaleHeight(20);
  static double get panelPaddingBottom => UI.scaleHeight(32);
  static double get searchFieldVerticalPadding => UI.scaleHeight(10);
  static double get gapTight => UI.scaleHeight(4);
  static double get gapMedium => UI.scaleHeight(16);
  static double get gapLarge => UI.scaleHeight(20);
  static double get gapAssetGroup => UI.scaleWidth(30);
  static double get gapSection => UI.scaleHeight(24);
  static double get gapSections => UI.scaleHeight(32);
  static double get buttonSize => UI.scaleWidth(48);
  static double get menuButtonSize => UI.scaleWidth(32);
  static double get assetThumbnailSize => UI.scaleWidth(56);
  static double get borderRadiusLarge => UI.scaleRadius(10);
  static double get borderRadiusSmall => UI.scaleRadius(4);
  static double get wordmarkHeight => UI.scaleHeight(85);
}
