import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Waveform visualization for audio assets matching EPOCH design
class LibraryWaveform extends StatelessWidget {
  const LibraryWaveform({super.key});

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: EpochSpacing.assetThumbnailSize,
    height: EpochSpacing.assetThumbnailSize,
    child: SvgPicture.asset(
      'assets/figma/Epoch___Mobile___Library_A_2805-20462/library_waveform.svg',
      fit: BoxFit.cover,
    ),
  );
}
