import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/flavor.dart';

class FlavorBadge extends StatelessWidget {
  const FlavorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final flavor = FlavorManager.I.flavor;
    if (flavor == Flavor.prod) return const SizedBox.shrink();
    final ColorScheme colors = Theme.of(context).colorScheme;
    final FlavorBadgeStyle style = mapFlavorToBadge(flavor, colors);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
    );
  }
}

@immutable
class FlavorBadgeStyle {
  const FlavorBadgeStyle({required this.label, required this.color});
  final String label;
  final Color color;
}

FlavorBadgeStyle mapFlavorToBadge(Flavor flavor, ColorScheme colors) {
  switch (flavor) {
    case Flavor.dev:
      return FlavorBadgeStyle(label: 'DEV', color: colors.error);
    case Flavor.staging:
      return FlavorBadgeStyle(label: 'STG', color: colors.tertiary);
    case Flavor.qa:
      return FlavorBadgeStyle(label: 'QA', color: colors.secondary);
    case Flavor.beta:
      return FlavorBadgeStyle(label: 'BETA', color: colors.primary);
    case Flavor.prod:
      return FlavorBadgeStyle(label: '', color: colors.primary);
  }
}
