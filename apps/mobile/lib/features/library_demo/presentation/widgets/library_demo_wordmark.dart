import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class LibraryWordmark extends StatelessWidget {
  const LibraryWordmark({
    required this.title,
    this.height,
    super.key,
  });

  final String title;
  final double? height;

  @override
  Widget build(final BuildContext context) => Container(
    height: height ?? EpochSpacing.wordmarkHeight,
    alignment: Alignment.center,
    child: Semantics(
      label: title,
      child: ResilientSvgAssetImage(
        assetPath:
            'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_wordmark.svg',
        fit: BoxFit.contain,
        fallbackBuilder: () => Text(
          title.toUpperCase(),
          style: EpochTextStyles.wordmark(context),
        ),
      ),
    ),
  );
}
