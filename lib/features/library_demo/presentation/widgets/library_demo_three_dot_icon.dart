import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom three-dot menu icon matching EPOCH design
class LibraryThreeDotIcon extends StatelessWidget {
  const LibraryThreeDotIcon({super.key});

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 6,
    height: 16,
    child: SvgPicture.asset(
      'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_three_dot_icon.svg',
    ),
  );
}
