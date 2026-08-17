import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Waveform visualization for audio assets matching EPOCH design
class LibraryWaveform extends StatelessWidget {
  const LibraryWaveform({super.key});

  @override
  Widget build(BuildContext context) => ResilientSvgAssetImage(
    assetPath: 'assets/figma/waveform_last.svg',
    fit: BoxFit.cover,
    fallbackBuilder: () => const SizedBox.shrink(),
  );
}
