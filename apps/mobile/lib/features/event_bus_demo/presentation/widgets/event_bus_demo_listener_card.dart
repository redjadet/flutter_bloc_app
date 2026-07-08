import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';

/// Card shell for one Event Bus listener panel in the demo.
class EventBusDemoListenerCard extends StatelessWidget {
  const EventBusDemoListenerCard({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: context.allGapM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                SizedBox(width: context.responsiveGapS),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.responsiveGapM),
            child,
          ],
        ),
      ),
    );
  }
}
