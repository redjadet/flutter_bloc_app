import 'dart:math' as math;

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scape_favorite_icon.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scape_grid_item_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

class ScapeGridItem extends StatelessWidget {
  const ScapeGridItem({
    required this.scape,
    required this.onFavoritePressed,
    required this.onMorePressed,
    super.key,
  });

  final Scape scape;
  final VoidCallback onFavoritePressed;
  final VoidCallback onMorePressed;

  @override
  Widget build(final BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final double imageOuterRadius = UI.scaleRadius(6);
    final double imageInnerRadius = UI.scaleRadius(2);
    final double imagePadding = UI.scaleWidth(4);
    final double imageTextGapBase = UI.scaleHeight(12);
    final double textRowGapBase = EpochSpacing.gapTight;
    final double iconSize = UI.scaleFontMax(16);

    return LayoutBuilder(
      builder: (final context, final constraints) {
        final TextStyle baseTitleStyle = EpochTextStyles.assetName(context);
        final TextStyle metadataStyle = EpochTextStyles.metadata(context);
        final TextScaler textScaler = MediaQuery.textScalerOf(context);
        final TextDirection textDirection = Directionality.of(context);
        final double maxTextWidth = math.max(
          0,
          constraints.maxWidth - (iconSize * 2),
        );
        final TextStyle titleStyle = fitTitleStyle(
          baseStyle: baseTitleStyle,
          text: scape.name,
          maxWidth: maxTextWidth,
          textScaler: textScaler,
          textDirection: textDirection,
        );
        final TextPainter titlePainter = TextPainter(
          text: TextSpan(text: scape.name, style: titleStyle),
          maxLines: 1,
          textScaler: textScaler,
          textDirection: textDirection,
        )..layout(maxWidth: maxTextWidth);
        final String metadataText = context.l10n.scapeMetadataFormat(
          scape.formattedDuration,
          scape.assetCount,
        );
        final TextPainter metadataPainter = TextPainter(
          text: TextSpan(text: metadataText, style: metadataStyle),
          maxLines: 1,
          textScaler: textScaler,
          textDirection: textDirection,
        )..layout();
        final double textRowGap = textRowGapBase;
        final double rowHeight = math.max(titlePainter.height, iconSize);
        final double textBlockHeight =
            rowHeight + textRowGap + metadataPainter.height;
        final double imageTextGap = imageTextGapBase;
        final double availableImageHeight = math.max(
          0,
          constraints.maxHeight - textBlockHeight - imageTextGap,
        );
        final double desiredImageHeight = constraints.maxWidth;
        final double imageHeight = math.min(
          desiredImageHeight,
          availableImageHeight,
        );
        final double innerImageHeight = math.max(
          0,
          imageHeight - (imagePadding * 2),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageHeight > 0)
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  color: EpochColors.pink,
                  borderRadius: BorderRadius.circular(imageOuterRadius),
                ),
                padding: EdgeInsets.all(imagePadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageInnerRadius),
                  child: SizedBox(
                    height: innerImageHeight,
                    width: double.infinity,
                    child: FancyShimmerImage(
                      imageUrl: scape.imageUrl,
                      boxFit: BoxFit.cover,
                      shimmerBaseColor: colors.surfaceContainerHighest,
                      shimmerHighlightColor: colors.surface,
                      errorWidget: ColoredBox(
                        color: colors.surfaceContainerHighest,
                        child: Icon(
                          Icons.error_outline,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (imageHeight > 0) SizedBox(height: imageTextGap),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          scape.name,
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScapeIconButton(
                          size: iconSize,
                          tooltip: scape.isFavorite
                              ? context.l10n.scapeFavoriteRemoveTooltip
                              : context.l10n.scapeFavoriteAddTooltip,
                          onPressed: onFavoritePressed,
                          icon: ScapeFavoriteIcon(
                            isFavorite: scape.isFavorite,
                            color: scape.isFavorite
                                ? EpochColors.warmGreyLightest
                                : EpochColors.ash,
                            size: iconSize,
                          ),
                        ),
                        _ScapeIconButton(
                          size: iconSize,
                          tooltip: context.l10n.scapeMoreOptionsTooltip,
                          onPressed: onMorePressed,
                          icon: SizedBox(
                            width: UI.scaleWidth(4),
                            height: iconSize,
                            child: ResilientSvgAssetImage(
                              assetPath:
                                  'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_three_dot_icon.svg',
                              fit: BoxFit.contain,
                              fallbackBuilder: () => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: textRowGap),
                Text(
                  metadataText,
                  style: metadataStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ScapeIconButton extends StatelessWidget {
  const _ScapeIconButton({
    required this.size,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final double size;
  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(final BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: onPressed,
        radius: size * 0.5,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: icon),
        ),
      ),
    ),
  );
}
