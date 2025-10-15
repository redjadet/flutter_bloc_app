import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/flavor.dart';

class FlavorBadge extends StatelessWidget {
  const FlavorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final flavor = FlavorManager.I.flavor;
    if (flavor == Flavor.prod) return const SizedBox.shrink();
    final ColorScheme colors = Theme.of(context).colorScheme;
    final _FlavorBadgeStyle style = _mapFlavorToBadge(flavor, colors);
    final String tooltipMessage = flavor == Flavor.prod
        ? 'Production flavor'
        : 'Flavor: ${style.label}';
    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 250),
      child: Semantics(
        label: tooltipMessage,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: style.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: style.color.withValues(alpha: 0.6)),
          ),
          child: Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _FlavorBadgeStyle {
  const _FlavorBadgeStyle({required this.label, required this.color});
  final String label;
  final Color color;
}

_FlavorBadgeStyle _mapFlavorToBadge(Flavor flavor, ColorScheme colors) {
  switch (flavor) {
    case Flavor.dev:
      return _FlavorBadgeStyle(label: 'DEV', color: colors.error);
    case Flavor.staging:
      return _FlavorBadgeStyle(label: 'STG', color: colors.tertiary);
    case Flavor.qa:
      return _FlavorBadgeStyle(label: 'QA', color: colors.secondary);
    case Flavor.beta:
      return _FlavorBadgeStyle(label: 'BETA', color: colors.primary);
    case Flavor.prod:
      return _FlavorBadgeStyle(label: 'PROD', color: colors.primary);
  }
}
