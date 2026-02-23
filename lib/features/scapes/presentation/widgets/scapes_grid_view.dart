import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scape_grid_item.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

/// Shared grid metrics (delegate + mainAxisExtent) for [ScapesGridView] and
/// [ScapesGridSliver] so layout is identical.
_ScapesGridMetrics _computeScapesGridMetrics(
  final BuildContext context,
  final double maxWidth,
) {
  final gridLayout = context.calculateGridLayout(
    mobileColumns: 2,
    tabletColumns: 3,
    desktopColumns: 4,
  );
  final double usableWidth = math.max(
    0,
    maxWidth - (gridLayout.horizontalPadding * 2),
  );
  final double totalSpacing = gridLayout.spacing * (gridLayout.columns - 1);
  final double itemWidth = gridLayout.columns > 0
      ? (usableWidth - totalSpacing) / gridLayout.columns
      : usableWidth;
  final TextStyle titleStyle = EpochTextStyles.assetName(context);
  final TextStyle metadataStyle = EpochTextStyles.metadata(context);
  final TextScaler textScaler = MediaQuery.textScalerOf(context);
  final TextDirection textDirection = Directionality.of(context);
  final TextPainter titlePainter = TextPainter(
    text: TextSpan(text: context.l10n.scapeNameLabel, style: titleStyle),
    maxLines: 1,
    textScaler: textScaler,
    textDirection: textDirection,
  )..layout();
  final TextPainter metadataPainter = TextPainter(
    text: TextSpan(
      text: context.l10n.scapeMetadataFormat('00:00', 1),
      style: metadataStyle,
    ),
    maxLines: 1,
    textScaler: textScaler,
    textDirection: textDirection,
  )..layout();
  final double iconSize = UI.scaleFontMax(16);
  const double minTouchSize = 48;
  final double buttonHeight = math.max(iconSize, minTouchSize);
  final double rowHeight = math.max(titlePainter.height, buttonHeight);
  final double textBlockHeight =
      rowHeight + EpochSpacing.gapTight + metadataPainter.height;
  final double imageTextGap = UI.scaleHeight(12);
  final double contentHeight =
      itemWidth + imageTextGap + textBlockHeight + UI.scaleHeight(2);
  final double mainAxisExtent = contentHeight.isFinite && contentHeight > 0
      ? contentHeight
      : itemWidth * 1.25;

  return _ScapesGridMetrics(
    gridLayout: gridLayout,
    delegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: gridLayout.columns,
      crossAxisSpacing: gridLayout.spacing,
      mainAxisSpacing: gridLayout.spacing,
      mainAxisExtent: mainAxisExtent,
    ),
  );
}

class _ScapesGridMetrics {
  const _ScapesGridMetrics({
    required this.gridLayout,
    required this.delegate,
  });

  final ResponsiveGridLayout gridLayout;
  final SliverGridDelegate delegate;
}

class ScapesGridView extends StatelessWidget {
  const ScapesGridView({
    required this.scapes,
    required this.onFavoritePressed,
    required this.onMorePressed,
    this.shrinkWrap = false,
    super.key,
  });

  final List<Scape> scapes;
  final void Function(String scapeId) onFavoritePressed;
  final void Function(String scapeId) onMorePressed;
  final bool shrinkWrap;

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final metrics = _computeScapesGridMetrics(
          context,
          constraints.maxWidth,
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.gridLayout.horizontalPadding,
          ),
          child: GridView.builder(
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            gridDelegate: metrics.delegate,
            itemCount: scapes.length,
            itemBuilder: (final context, final index) {
              final scape = scapes[index];
              return ScapeGridItem(
                scape: scape,
                onFavoritePressed: () => onFavoritePressed(scape.id),
                onMorePressed: () => onMorePressed(scape.id),
              );
            },
          ),
        );
      },
    );
  }
}

/// Sliver version of the scapes grid for use inside [CustomScrollView].
/// Uses the same layout as [ScapesGridView] without shrinkWrap.
class ScapesGridSliver extends StatelessWidget {
  const ScapesGridSliver({
    required this.scapes,
    required this.onFavoritePressed,
    required this.onMorePressed,
    super.key,
  });

  final List<Scape> scapes;
  final void Function(String scapeId) onFavoritePressed;
  final void Function(String scapeId) onMorePressed;

  @override
  Widget build(final BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final metrics = _computeScapesGridMetrics(context, width);

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.gridLayout.horizontalPadding,
      ),
      sliver: SliverGrid(
        gridDelegate: metrics.delegate,
        delegate: SliverChildBuilderDelegate(
          (final context, final index) {
            final scape = scapes[index];
            return ScapeGridItem(
              scape: scape,
              onFavoritePressed: () => onFavoritePressed(scape.id),
              onMorePressed: () => onMorePressed(scape.id),
            );
          },
          childCount: scapes.length,
        ),
      ),
    );
  }
}
