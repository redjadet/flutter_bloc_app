import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_favorite_icon.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_models.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_three_dot_icon.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_waveform.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

class LibraryAssetTile extends StatelessWidget {
  const LibraryAssetTile({
    required this.asset,
    super.key,
  });

  final LibraryAsset asset;

  @override
  Widget build(final BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      vertical: EpochSpacing.gapMedium / 2,
    ),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: EpochColors.warmGrey.withValues(alpha: 0.35),
        ),
      ),
    ),
    child: SizedBox(
      height: EpochSpacing.assetThumbnailSize,
      child: Row(
        children: [
          // Asset art and info
          Expanded(
            child: Row(
              children: [
                // Thumbnail
                _buildThumbnail(),
                const SizedBox(width: 12),
                // Asset info
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          asset.name,
                          style: EpochTextStyles.assetName(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          asset.type.toUpperCase(),
                          style: EpochTextStyles.assetType(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: EpochSpacing.gapAssetGroup),
          // Metadata and icons
          Row(
            children: [
              SizedBox(
                width: 41,
                child: Text(
                  asset.durationLabel,
                  style: EpochTextStyles.metadata(context),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(width: EpochSpacing.gapSection),
              SizedBox(
                width: 35,
                child: Text(
                  asset.formatLabel,
                  style: EpochTextStyles.metadata(context),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(width: EpochSpacing.gapSection),
              const LibraryFavoriteIcon(),
              SizedBox(width: EpochSpacing.gapLarge),
              const LibraryThreeDotIcon(),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildThumbnail() {
    if (asset.isAudio) {
      return Container(
        width: EpochSpacing.assetThumbnailSize,
        height: EpochSpacing.assetThumbnailSize,
        decoration: BoxDecoration(
          color: asset.backgroundColor ?? EpochColors.pink,
          borderRadius: BorderRadius.circular(EpochSpacing.borderRadiusSmall),
        ),
        child: const LibraryWaveform(),
      );
    }

    if (asset.thumbnailAssetPath != null) {
      final String assetPath = asset.thumbnailAssetPath!;
      final bool isSvg = assetPath.toLowerCase().endsWith('.svg');
      return ClipRRect(
        borderRadius: BorderRadius.circular(EpochSpacing.borderRadiusSmall),
        child: SizedBox(
          width: EpochSpacing.assetThumbnailSize,
          height: EpochSpacing.assetThumbnailSize,
          child: isSvg
              ? ResilientSvgAssetImage(
                  assetPath: assetPath,
                  fit: BoxFit.contain,
                  fallbackBuilder: () => Container(
                    color: EpochColors.warmGreyLightest.withValues(
                      alpha: 0.2,
                    ),
                  ),
                )
              : Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  width: EpochSpacing.assetThumbnailSize,
                  height: EpochSpacing.assetThumbnailSize,
                ),
        ),
      );
    }

    return Container(
      width: EpochSpacing.assetThumbnailSize,
      height: EpochSpacing.assetThumbnailSize,
      decoration: BoxDecoration(
        color: EpochColors.warmGreyLightest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(EpochSpacing.borderRadiusSmall),
      ),
    );
  }
}
