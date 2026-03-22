import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Compact spinner used on settings diagnostics cards (metadata load, clear in flight).
class SettingsDiagnosticsBusyGlyph extends StatelessWidget {
  const SettingsDiagnosticsBusyGlyph({super.key});

  @override
  Widget build(final BuildContext context) {
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
  Widget build(final BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: PlatformAdaptive.textButton(
        context: context,
        onPressed: onPressed,
        child: isBusy ? const SettingsDiagnosticsBusyGlyph() : Text(label),
      ),
    );
  }
}
