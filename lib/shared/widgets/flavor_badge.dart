import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/flavor.dart';

class FlavorBadge extends StatelessWidget {
  const FlavorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final flavor = FlavorManager.I.flavor;
    if (flavor == Flavor.prod) return const SizedBox.shrink();

    final ColorScheme colors = Theme.of(context).colorScheme;
    final (String label, Color color) = switch (flavor) {
      Flavor.dev => ('DEV', colors.error),
      Flavor.staging => ('STG', colors.tertiary),
      Flavor.qa => ('QA', colors.secondary),
      Flavor.beta => ('BETA', colors.primary),
      Flavor.prod => ('', colors.primary),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
