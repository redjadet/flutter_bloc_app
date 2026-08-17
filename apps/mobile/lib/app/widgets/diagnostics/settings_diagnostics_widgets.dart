import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Compact spinner used on settings diagnostics cards (metadata load, clear in flight).
class SettingsDiagnosticsBusyGlyph extends StatelessWidget {
  const SettingsDiagnosticsBusyGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    final double s = context.responsiveGapM;
    return SizedBox(
      height: s,
      width: s,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

/// Trailing clear control on a diagnostics card (shows [label] or busy glyph).
class SettingsDiagnosticsClearButton extends StatelessWidget {
  const SettingsDiagnosticsClearButton({
    required this.label,
    required this.isBusy,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: PlatformAdaptive.textButton(
        context: context,
        onPressed: onPressed,
        child: isBusy ? const SettingsDiagnosticsBusyGlyph() : Text(label),
      ),
    );
  }
}
