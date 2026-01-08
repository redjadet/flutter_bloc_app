import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_asset_tile.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_assets_header.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_category_list.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_models.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_search_row.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_top_nav.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_wordmark.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';

class LibraryDemoBody extends StatelessWidget {
  const LibraryDemoBody({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<LibraryAsset> assets = _libraryAssets(l10n);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.pageHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryTopNav(
            l10n: l10n,
            onBack: () => NavigationUtils.popOrGoHome(context),
          ),
          SizedBox(height: EpochSpacing.gapMedium),
          LibraryWordmark(
            title: l10n.libraryDemoBrandName,
          ),
          SizedBox(height: EpochSpacing.gapMedium),
          Container(
            decoration: BoxDecoration(
              color: EpochColors.darkGrey,
              borderRadius: BorderRadius.circular(
                EpochSpacing.borderRadiusLarge,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              EpochSpacing.panelPadding,
              EpochSpacing.panelPaddingTop,
              EpochSpacing.panelPadding,
              EpochSpacing.panelPaddingBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.libraryDemoPanelTitle,
                  style: EpochTextStyles.heading(context),
                ),
                SizedBox(height: EpochSpacing.gapMedium),
                LibrarySearchRow(l10n: l10n),
                SizedBox(height: EpochSpacing.gapLarge),
                LibraryCategoryList(l10n: l10n),
                SizedBox(height: EpochSpacing.gapSections),
                LibraryAssetsHeader(l10n: l10n),
                SizedBox(height: EpochSpacing.gapSection),
                ...assets.asMap().entries.map(
                  (final entry) => LibraryAssetTile(
                    asset: entry.value,
                    isLast: entry.key == assets.length - 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: EpochSpacing.gapLarge),
        ],
      ),
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
