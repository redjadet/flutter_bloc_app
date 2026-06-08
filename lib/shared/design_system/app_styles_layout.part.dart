part of 'app_styles.dart';

BoxStyler get _appStylesAppBar => BoxStyler()
    .padding(
      EdgeInsetsGeometryMix.symmetric(
        vertical: AppMixTokens.gapM(),
        horizontal: AppMixTokens.cardPadH(),
      ),
    )
    .shadows(const []);

BoxStyler get _appStylesBanner => BoxStyler()
    .padding(
      EdgeInsetsGeometryMix.symmetric(
        vertical: AppMixTokens.gapM(),
        horizontal: AppMixTokens.cardPadH(),
      ),
    )
    .shadows(const [])
    .onTablet(BoxStyler().paddingX(AppMixTokens.gapL()))
    .onDesktop(BoxStyler().paddingX(AppMixTokens.gapL()));

BoxStyler get _appStylesEmptyState => BoxStyler().padding(
  EdgeInsetsGeometryMix.only(
    top: AppMixTokens.gapL(),
    bottom: AppMixTokens.gapL(),
    left: AppMixTokens.cardPadH(),
    right: AppMixTokens.cardPadH(),
  ),
);

BoxStyler get _appStylesChip => BoxStyler()
    .color(AppMaterialColorTokens.surfaceContainerLow())
    .borderRadiusAll(AppMixTokens.radiusPill())
    .padding(
      EdgeInsetsGeometryMix.symmetric(
        vertical: AppMixTokens.gapS(),
        horizontal: AppMixTokens.gapS(),
      ),
    )
    .onTablet(BoxStyler().paddingX(AppMixTokens.gapM()))
    .onDesktop(BoxStyler().paddingX(AppMixTokens.gapM()));

BoxStyler get _appStylesStatusSuccess => BoxStyler()
    .color(AppMaterialColorTokens.success())
    .borderRadiusAll(AppMixTokens.radiusPill())
    .padding(
      EdgeInsetsGeometryMix.symmetric(
        vertical: AppMixTokens.gapS(),
        horizontal: AppMixTokens.gapM(),
      ),
    );

TextStyler get _appStylesStatusSuccessText => TextStyler()
    .style(AppTextStyleTokens.labelMedium.mix())
    .color(AppMaterialColorTokens.onSurface())
    .fontWeight(.w600);

BoxStyler get _appStylesStatusError => BoxStyler()
    .color(AppMaterialColorTokens.error())
    .borderRadiusAll(AppMixTokens.radiusPill())
    .padding(
      EdgeInsetsGeometryMix.symmetric(
        vertical: AppMixTokens.gapS(),
        horizontal: AppMixTokens.gapM(),
      ),
    );

TextStyler get _appStylesStatusErrorText => TextStyler()
    .style(AppTextStyleTokens.labelMedium.mix())
    .color(AppMaterialColorTokens.onPrimary())
    .fontWeight(.w600);

BoxStyler get _appStylesDialogContent => BoxStyler().padding(
  EdgeInsetsGeometryMix.only(
    top: AppMixTokens.gapL(),
    bottom: AppMixTokens.gapL(),
    left: AppMixTokens.cardPadH(),
    right: AppMixTokens.cardPadH(),
  ),
);

TextStyler get _appStylesHeadingStyle =>
    TextStyler().style(AppTextStyleTokens.titleLarge.mix());

TextStyler get _appStylesSubheadingStyle =>
    TextStyler().style(AppTextStyleTokens.titleMedium.mix());

TextStyler get _appStylesBodyStyle =>
    TextStyler().style(AppTextStyleTokens.bodyMedium.mix());

TextStyler get _appStylesBodyLargeStyle =>
    TextStyler().style(AppTextStyleTokens.bodyLarge.mix());

TextStyler get _appStylesCaptionStyle =>
    TextStyler().style(AppTextStyleTokens.labelMedium.mix());

TextStyler get _appStylesCaptionSmallStyle =>
    TextStyler().style(AppTextStyleTokens.labelSmall.mix());
