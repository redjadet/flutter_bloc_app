import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Custom favorite (star) icon matching EPOCH design
class LibraryFavoriteIcon extends StatelessWidget {
  const LibraryFavoriteIcon({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 16,
    height: 16,
    child: SvgPicture.asset(
      'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_favorite_icon.svg',
    ),
  );
}
