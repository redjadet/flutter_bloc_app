import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom filter icon matching EPOCH design
class LibraryFilterIcon extends StatelessWidget {
  const LibraryFilterIcon({super.key});

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 24,
    height: 18,
    child: SvgPicture.asset(
      'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_filter_icon.svg',
    ),
  );
}
