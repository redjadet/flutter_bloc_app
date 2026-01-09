import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

/// Custom favorite (star) icon for scapes, matching Figma design
class ScapeFavoriteIcon extends StatelessWidget {
  const ScapeFavoriteIcon({
    required this.isFavorite,
    required this.color,
    this.size = 16,
    super.key,
  });

  final bool isFavorite;
  final Color color;
  final double size;

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: ResilientSvgAssetImage(
        assetPath:
            'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_favorite_icon.svg',
        fit: BoxFit.contain,
        fallbackBuilder: () => const SizedBox.shrink(),
      ),
    ),
  );
}
