import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Waveform visualization for audio assets matching EPOCH design
class LibraryWaveform extends StatelessWidget {
  const LibraryWaveform({super.key});

  @override
  Widget build(final BuildContext context) => SvgPicture.asset(
    'assets/figma/waveform_last.svg',
  );
}
