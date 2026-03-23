import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_asset_tile.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_models.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_panel.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_top_nav.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_wordmark.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/design_system/epoch_theme_extension.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';

class LibraryDemoBody extends StatelessWidget {
  const LibraryDemoBody({
    required this.isGridView,
    required this.onGridPressed,
    required this.onListPressed,
    required this.gridTrailingSlivers,
    required this.timerService,
    super.key,
  });

  final bool isGridView;
  final VoidCallback onGridPressed;
  final VoidCallback onListPressed;

  /// Trailing slivers for grid mode (e.g. scapes grid). Provided by app/router
  /// composition so this feature does not depend on other features.
  final List<Widget> gridTrailingSlivers;
  final TimerService timerService;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<LibraryAsset> assets = _libraryAssets(l10n);

    return LayoutBuilder(
      builder: (final context, final constraints) {
        final bool isCompactHeight = constraints.maxHeight < 700;
        final bool isCompactWidth = constraints.maxWidth < 360;
        final double navTopPadding = isCompactHeight
            ? EpochSpacing.gapLarge
            : EpochSpacing.topPadding;
        final double wordmarkHeight = isCompactHeight
            ? EpochSpacing.wordmarkHeight * 0.7
            : EpochSpacing.wordmarkHeight;
        final double wordmarkGap = isCompactHeight
            ? EpochSpacing.gapTight
            : EpochSpacing.gapMedium;
        final double panelTopPadding = isCompactHeight
            ? EpochSpacing.gapMedium
            : EpochSpacing.panelPaddingTop;
        final double panelBottomPadding = isCompactHeight
            ? EpochSpacing.gapLarge
            : EpochSpacing.panelPaddingBottom;
        final double sectionGap = isCompactHeight
            ? EpochSpacing.gapMedium
            : EpochSpacing.gapSection;
        final double categoryGap = isCompactHeight
            ? EpochSpacing.gapMedium
            : EpochSpacing.gapLarge;
        final double horizontalPadding = isCompactWidth
            ? EpochSpacing.panelPadding
            : context.pageHorizontalPadding;

        if (isGridView) {
          return ColoredBox(
            color: EpochColors.darkGrey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ColoredBox(
                        color: EpochColors.warmGrey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LibraryTopNav(
                              l10n: l10n,
                              onBack: () =>
                                  NavigationUtils.popOrGoHome(context),
                              padding: EdgeInsets.only(
                                top: navTopPadding,
                                left: horizontalPadding,
                              ),
                            ),
                            SizedBox(height: wordmarkGap),
                            LibraryWordmark(
                              title: l10n.libraryDemoBrandName,
                              height: wordmarkHeight,
                            ),
                            SizedBox(height: wordmarkGap),
                          ],
                        ),
                      ),
                      LibraryDemoPanel(
                        l10n: l10n,
                        panelTopPadding: panelTopPadding,
                        panelBottomPadding: panelBottomPadding,
                        sectionGap: sectionGap,
                        categoryGap: categoryGap,
                        isGridView: isGridView,
                        onGridPressed: onGridPressed,
                        onListPressed: onListPressed,
                        trailing: [SizedBox(height: sectionGap)],
                      ),
                    ],
                  ),
                ),
                ...gridTrailingSlivers,
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryTopNav(
                l10n: l10n,
                onBack: () => NavigationUtils.popOrGoHome(context),
                padding: EdgeInsets.only(
                  top: navTopPadding,
                  left: horizontalPadding,
                ),
              ),
              SizedBox(height: wordmarkGap),
              LibraryWordmark(
                title: l10n.libraryDemoBrandName,
                height: wordmarkHeight,
              ),
              SizedBox(height: wordmarkGap),
              LibraryDemoPanel(
                l10n: l10n,
                panelTopPadding: panelTopPadding,
                panelBottomPadding: panelBottomPadding,
                sectionGap: sectionGap,
                categoryGap: categoryGap,
                isGridView: isGridView,
                onGridPressed: onGridPressed,
                onListPressed: onListPressed,
                trailing: [
                  SizedBox(height: sectionGap),
                  ...assets.map(
                    (final asset) => LibraryAssetTile(asset: asset),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<LibraryAsset> _libraryAssets(final AppLocalizations l10n) => [
    LibraryAsset(
      name: l10n.libraryDemoAssetName,
      type: l10n.libraryDemoAssetTypeObject,
      durationLabel: l10n.libraryDemoAssetDuration,
      formatLabel: l10n.libraryDemoFormatObj,
      thumbnailAssetPath: _libraryThumbnailAssets[0],
    ),
    LibraryAsset(
      name: l10n.libraryDemoAssetName,
      type: l10n.libraryDemoAssetTypeImage,
      durationLabel: l10n.libraryDemoAssetDuration,
      formatLabel: l10n.libraryDemoFormatJpg,
      thumbnailAssetPath: _libraryThumbnailAssets[1],
    ),
    LibraryAsset(
      name: l10n.libraryDemoAssetName,
      type: l10n.libraryDemoAssetTypeSound,
      durationLabel: l10n.libraryDemoAssetDuration,
      formatLabel: l10n.libraryDemoFormatMp4,
      backgroundColor: EpochColors.pink,
    ),
    LibraryAsset(
      name: l10n.libraryDemoAssetName,
      type: l10n.libraryDemoAssetTypeFootage,
      durationLabel: l10n.libraryDemoAssetDuration,
      formatLabel: l10n.libraryDemoFormatMp4,
      thumbnailAssetPath: _libraryThumbnailAssets[2],
    ),
    LibraryAsset(
      name: l10n.libraryDemoAssetName,
      type: l10n.libraryDemoAssetTypeObject,
      durationLabel: l10n.libraryDemoAssetDuration,
      formatLabel: l10n.libraryDemoFormatObj,
      thumbnailAssetPath: _libraryThumbnailAssets[3],
    ),
    LibraryAsset(
      name: l10n.libraryDemoAssetName,
      type: l10n.libraryDemoAssetTypeSound,
      durationLabel: l10n.libraryDemoAssetDuration,
      formatLabel: l10n.libraryDemoFormatMp3,
      backgroundColor: EpochColors.purple,
    ),
  ];

  static const List<String> _libraryThumbnailAssets = [
    'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_asset_1.svg',
    'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_asset_2.svg',
    'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_asset_3.svg',
    'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_asset_4.svg',
  ];
}
