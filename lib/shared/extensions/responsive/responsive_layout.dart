part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Layout-specific responsive helpers for paddings, typography, and surfaces.
extension ResponsiveLayoutContext on BuildContext {
  double get pageHorizontalPadding => _scaledDimension(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 32,
    convert: UI.scaleWidth,
  );

  double get pageVerticalPadding => _scaledDimension(
    this,
    mobile: 12,
    tablet: 16,
    desktop: 16,
    convert: UI.scaleHeight,
  );

  double get contentMaxWidth => _scaledDimension(
    this,
    mobile: 560,
    tablet: 720,
    desktop: 840,
    convert: UI.scaleWidth,
  );

  double get barMaxWidth {
    if (isDesktop) return UI.scaleWidth(900);
    if (isTabletOrLarger) return UI.scaleWidth(720);
    return double.infinity;
  }

  EdgeInsets get pagePadding {
    final double extraBottom = isMobile && isPortrait ? UI.scaleHeight(72) : 0;
    return EdgeInsets.fromLTRB(
      pageHorizontalPadding,
      pageVerticalPadding,
      pageHorizontalPadding,
      pageVerticalPadding + bottomInset + extraBottom,
    );
  }

  double get responsiveFontSize => _scaledDimension(
    this,
    mobile: 14,
    tablet: 16,
    desktop: 16,
    convert: UI.scaleFont,
  );

  double get responsiveIconSize => _scaledDimension(
    this,
    mobile: 20,
    tablet: 24,
    desktop: 24,
    convert: UI.scaleFont,
  );

  int get gridColumns => responsiveValue<int>(
    mobile: 2,
    tablet: 3,
    desktop: 4,
  );

  double get responsiveButtonHeight => _scaledDimension(
    this,
    mobile: 48,
    tablet: 56,
    desktop: 56,
    convert: UI.scaleHeight,
  );

  double get responsiveButtonPadding => _scaledDimension(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 24,
    convert: UI.scaleWidth,
  );

  double get responsiveHeadlineSize => _scaledDimension(
    this,
    mobile: 24,
    tablet: 32,
    desktop: 32,
    convert: UI.scaleFont,
  );

  double get responsiveTitleSize => _scaledDimension(
    this,
    mobile: 20,
    tablet: 24,
    desktop: 24,
    convert: UI.scaleFont,
  );

  double get responsiveBodySize => _scaledDimension(
    this,
    mobile: 14,
    tablet: 16,
    desktop: 16,
    convert: UI.scaleFont,
  );

  double get responsiveCaptionSize => _scaledDimension(
    this,
    mobile: 12,
    tablet: 14,
    desktop: 14,
    convert: UI.scaleFont,
  );

  double get responsiveCardPadding => _scaledDimension(
    this,
    mobile: 16,
    tablet: 20,
    desktop: 20,
    convert: UI.scaleWidth,
  );

  EdgeInsets get responsivePageMargin => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );

  EdgeInsets get responsiveCardMargin => EdgeInsets.all(
    _scaledDimension(
      this,
      mobile: 8,
      tablet: 12,
      desktop: 12,
      convert: UI.scaleWidth,
    ),
  );

  EdgeInsets get responsiveListPadding => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: _scaledDimension(
      this,
      mobile: 8,
      tablet: 12,
      desktop: 12,
      convert: UI.scaleHeight,
    ),
  );

  double get responsiveBorderRadius => _scaledDimension(
    this,
    mobile: 8,
    tablet: 12,
    desktop: 12,
    convert: UI.scaleRadius,
  );

  double get responsiveCardRadius => _scaledDimension(
    this,
    mobile: 12,
    tablet: 16,
    desktop: 16,
    convert: UI.scaleRadius,
  );

  double get responsiveElevation => responsiveValue<double>(
    mobile: 2,
    tablet: 4,
    desktop: 4,
  );

  double get responsiveCardElevation => responsiveValue<double>(
    mobile: 1,
    tablet: 2,
    desktop: 2,
  );

  EdgeInsets get responsiveCardPaddingInsets =>
      EdgeInsets.all(responsiveCardPadding);

  EdgeInsets get responsiveListItemPadding => EdgeInsets.symmetric(
    horizontal: responsiveHorizontalGapL,
    vertical: responsiveGapM,
  );

  EdgeInsets get responsiveStatePadding => EdgeInsets.all(
    _scaledDimension(
      this,
      mobile: 24,
      tablet: 32,
      desktop: 32,
      convert: UI.scaleWidth,
    ),
  );

  EdgeInsets get responsiveDialogPadding => EdgeInsets.symmetric(
    horizontal: _scaledDimension(
      this,
      mobile: 24,
      tablet: 32,
      desktop: 32,
      convert: UI.scaleWidth,
    ),
    vertical: _scaledDimension(
      this,
      mobile: 20,
      tablet: 24,
      desktop: 24,
      convert: UI.scaleHeight,
    ),
  );

  EdgeInsets responsiveSheetPadding({final double extraBottom = 0}) =>
      EdgeInsets.fromLTRB(
        responsiveHorizontalGapL,
        responsiveGapM,
        responsiveHorizontalGapL,
        responsiveGapM + keyboardInset + extraBottom,
      );

  EdgeInsets get responsiveBubblePadding => EdgeInsets.symmetric(
    horizontal: responsiveHorizontalGapM,
    vertical: responsiveGapS,
  );

  EdgeInsets get responsiveBubbleMargin => EdgeInsets.symmetric(
    vertical: responsiveGapS / 2,
  );

  double get responsiveErrorIconSize => _scaledDimension(
    this,
    mobile: 48,
    tablet: 64,
    desktop: 64,
    convert: UI.scaleFont,
  );

  double get responsiveErrorIconSizeLarge => _scaledDimension(
    this,
    mobile: 64,
    tablet: 80,
    desktop: 80,
    convert: UI.scaleFont,
  );
}
