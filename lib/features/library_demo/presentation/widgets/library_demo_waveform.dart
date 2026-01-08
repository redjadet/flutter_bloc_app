import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';

/// Waveform visualization for audio assets matching EPOCH design
class LibraryWaveform extends StatelessWidget {
  const LibraryWaveform({super.key});

  @override
  Widget build(final BuildContext context) => ResilientSvgAssetImage(
    assetPath: 'assets/figma/waveform_last.svg',
    fit: BoxFit.cover,
    fallbackBuilder: () => const SizedBox.shrink(),
  );
}
