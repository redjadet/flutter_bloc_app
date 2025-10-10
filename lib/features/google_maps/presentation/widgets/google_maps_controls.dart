import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class GoogleMapsControlsCard extends StatelessWidget {
  const GoogleMapsControlsCard({
    super.key,
    required this.heading,
    required this.helpText,
    required this.isHybridMapType,
    required this.trafficEnabled,
    required this.onToggleMapType,
    required this.onToggleTraffic,
    required this.mapTypeHybridLabel,
    required this.mapTypeNormalLabel,
    required this.trafficToggleLabel,
  });

  final String heading;
  final String helpText;
  final bool isHybridMapType;
  final bool trafficEnabled;
  final VoidCallback onToggleMapType;
  final ValueChanged<bool> onToggleTraffic;
  final String mapTypeHybridLabel;
  final String mapTypeNormalLabel;
  final String trafficToggleLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String mapTypeLabel = isHybridMapType
        ? mapTypeNormalLabel
        : mapTypeHybridLabel;

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: UI.cardPadH,
          vertical: UI.cardPadV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(heading, style: theme.textTheme.titleMedium),
            SizedBox(height: UI.gapS),
            FilledButton.icon(
              onPressed: onToggleMapType,
              icon: const Icon(Icons.layers),
              label: Text(mapTypeLabel),
            ),
            SizedBox(height: UI.gapS),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: trafficEnabled,
              title: Text(trafficToggleLabel),
              onChanged: onToggleTraffic,
            ),
            SizedBox(height: UI.gapS),
            Text(helpText, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
