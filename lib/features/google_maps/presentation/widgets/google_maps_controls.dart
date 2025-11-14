import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class GoogleMapsControlsCard extends StatelessWidget {
  const GoogleMapsControlsCard({
    required this.heading,
    required this.helpText,
    required this.isHybridMapType,
    required this.trafficEnabled,
    required this.onToggleMapType,
    required this.onToggleTraffic,
    required this.mapTypeHybridLabel,
    required this.mapTypeNormalLabel,
    required this.trafficToggleLabel,
    super.key,
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
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String mapTypeLabel = isHybridMapType
        ? mapTypeNormalLabel
        : mapTypeHybridLabel;

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(heading, style: theme.textTheme.titleMedium),
          SizedBox(height: context.responsiveGapS),
          FilledButton.icon(
            onPressed: onToggleMapType,
            icon: const Icon(Icons.layers),
            label: Text(mapTypeLabel),
          ),
          SizedBox(height: context.responsiveGapS),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: trafficEnabled,
            title: Text(trafficToggleLabel),
            onChanged: onToggleTraffic,
          ),
          SizedBox(height: context.responsiveGapS),
          Text(helpText, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
