import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom favorite (star) icon matching EPOCH design
class LibraryFavoriteIcon extends StatelessWidget {
  const LibraryFavoriteIcon({super.key});

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 16,
    height: 16,
    child: SvgPicture.asset(
      'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_favorite_icon.svg',
    ),
  );
}
