import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

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
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: ResilientSvgAssetImage(
        assetPath: 'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_favorite_icon.svg',
        fit: BoxFit.contain,
        fallbackBuilder: () => const SizedBox.shrink(),
      ),
    ),
  );
}
