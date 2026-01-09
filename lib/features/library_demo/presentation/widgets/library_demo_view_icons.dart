import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Grid view icon matching EPOCH design
class LibraryGridViewIcon extends StatelessWidget {
  const LibraryGridViewIcon({this.isActive = false, super.key});

  final bool isActive;

  @override
  Widget build(final BuildContext context) {
    final String assetPath = isActive
        ? 'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_grid_view_icon_selected.svg'
        : 'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_grid_view_icon.svg';

    return SizedBox(
      width: 16,
      height: 16,
      child: Opacity(
        opacity: isActive ? 1 : 0.6,
        child: SvgPicture.asset(assetPath),
      ),
    );
  }
}

/// List view icon matching EPOCH design
class LibraryListViewIcon extends StatelessWidget {
  const LibraryListViewIcon({this.isActive = false, super.key});

  final bool isActive;

  @override
  Widget build(final BuildContext context) {
    final String assetPath = isActive
        ? 'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_list_view_icon.svg'
        : 'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_list_view_icon_inactive.svg';

    return SizedBox(
      width: 16,
      height: 16,
      child: Opacity(
        opacity: isActive ? 1 : 0.6,
        child: SvgPicture.asset(assetPath),
      ),
    );
  }
}
