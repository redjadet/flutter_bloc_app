part of 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Layout-specific responsive helpers for paddings, margins, and surfaces.
extension ResponsiveLayoutContext on BuildContext {
  double get pageHorizontalPadding => _scaledWidth(
    this,
    mobile: 16,
    tablet: 24,
    desktop: 32,
  );

  double get pageVerticalPadding => _scaledHeight(
    this,
    mobile: 12,
    tablet: 16,
    desktop: 16,
  );

  double get contentMaxWidth => _scaledWidth(
    this,
    mobile: 560,
    tablet: 720,
    desktop: 840,
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

  int get gridColumns => responsiveValue<int>(
    mobile: 2,
    tablet: 3,
    desktop: 4,
  );

  double get responsiveCardPadding => _scaledWidth(
    this,
    mobile: 16,
    tablet: 20,
    desktop: 20,
  );

  EdgeInsets get responsivePageMargin => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );

  EdgeInsets get pageHorizontalPaddingInsets =>
      EdgeInsets.symmetric(horizontal: pageHorizontalPadding);

  EdgeInsets pageHorizontalPaddingWithVertical(final double vertical) =>
      EdgeInsets.symmetric(
        horizontal: pageHorizontalPadding,
        vertical: vertical,
      );

  EdgeInsets get responsiveCardMargin => EdgeInsets.all(
    _scaledWidth(
      this,
      mobile: 8,
      tablet: 12,
      desktop: 12,
    ),
  );

  EdgeInsets get responsiveListPadding => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: _scaledHeight(
      this,
      mobile: 8,
      tablet: 12,
      desktop: 12,
    ),
  );

  double get responsiveBorderRadius => _scaledRadius(
    this,
    mobile: 8,
    tablet: 12,
    desktop: 12,
  );

  double get responsiveCardRadius => _scaledRadius(
    this,
    mobile: 12,
    tablet: 16,
    desktop: 16,
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
    _scaledWidth(
      this,
      mobile: 24,
      tablet: 32,
      desktop: 32,
    ),
  );

  EdgeInsets get responsiveDialogPadding => EdgeInsets.symmetric(
    horizontal: _scaledWidth(
      this,
      mobile: 24,
      tablet: 32,
      desktop: 32,
    ),
    vertical: _scaledHeight(
      this,
      mobile: 20,
      tablet: 24,
      desktop: 24,
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

  /// Returns EdgeInsets.all with responsiveGapXS
  EdgeInsets get allGapXS => EdgeInsets.all(responsiveGapXS);

  /// Returns EdgeInsets.all with responsiveGapS
  EdgeInsets get allGapS => EdgeInsets.all(responsiveGapS);

  /// Returns EdgeInsets.all with responsiveGapM
  EdgeInsets get allGapM => EdgeInsets.all(responsiveGapM);

  /// Returns EdgeInsets.all with responsiveGapL
  EdgeInsets get allGapL => EdgeInsets.all(responsiveGapL);

  /// Returns EdgeInsets.all with responsiveCardPadding
  EdgeInsets get allCardPadding => EdgeInsets.all(responsiveCardPadding);
}
