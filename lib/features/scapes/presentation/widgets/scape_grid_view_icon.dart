import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

/// Grid view icon for scapes page, matching Figma design
class ScapeGridViewIcon extends StatelessWidget {
  const ScapeGridViewIcon({
    required this.isSelected,
    super.key,
  });

  final bool isSelected;

  @override
  Widget build(final BuildContext context) {
    final double iconSize = UI.scaleFontMax(16);
    final String assetPath = isSelected
        ? 'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_grid_view_icon_selected.svg'
        : 'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_grid_view_icon.svg';
    final Color? iconColor = isSelected ? null : EpochColors.ash;
    final Widget icon = ResilientSvgAssetImage(
      assetPath: assetPath,
      fit: BoxFit.contain,
      fallbackBuilder: () => Icon(
        Icons.grid_view,
        size: iconSize,
        color: iconColor ?? EpochColors.warmGreyLightest,
      ),
    );

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: iconColor == null
          ? icon
          : ColorFiltered(
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              child: icon,
            ),
    );
  }
}

/// List view icon for scapes page, matching Figma design.
class ScapeListViewIcon extends StatelessWidget {
  const ScapeListViewIcon({
    required this.isSelected,
    super.key,
  });

  final bool isSelected;

  @override
  Widget build(final BuildContext context) {
    final double iconSize = UI.scaleFontMax(16);
    final Color iconColor = isSelected
        ? EpochColors.warmGreyLightest
        : EpochColors.ash;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        child: ResilientSvgAssetImage(
          assetPath:
              'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_list_view_icon.svg',
          fit: BoxFit.contain,
          fallbackBuilder: () => Icon(
            Icons.view_list,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
