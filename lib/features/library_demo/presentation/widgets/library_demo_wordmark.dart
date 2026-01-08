import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

class LibraryWordmark extends StatelessWidget {
  const LibraryWordmark({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(final BuildContext context) => Container(
    height: EpochSpacing.wordmarkHeight,
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
