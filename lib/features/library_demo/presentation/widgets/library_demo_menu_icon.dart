import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom hamburger menu icon matching EPOCH design
class LibraryMenuIcon extends StatelessWidget {
  const LibraryMenuIcon({super.key});

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 24,
    height: 18,
    child: SvgPicture.asset(
      'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_menu_icon.svg',
    ),
  );
}
