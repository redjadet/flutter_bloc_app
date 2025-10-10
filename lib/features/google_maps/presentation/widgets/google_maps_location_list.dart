import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class GoogleMapsLocationList extends StatelessWidget {
  const GoogleMapsLocationList({
    super.key,
    required this.locations,
    required this.selectedMarkerId,
    required this.emptyLabel,
    required this.heading,
    required this.focusLabel,
    required this.selectedBadgeLabel,
    required this.onFocus,
  });

  final List<MapLocation> locations;
  final String? selectedMarkerId;
  final String emptyLabel;
  final String heading;
  final String focusLabel;
  final String selectedBadgeLabel;
  final ValueChanged<MapLocation> onFocus;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (locations.isEmpty) {
      return Text(
        emptyLabel,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(heading, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapS),
        for (final MapLocation location in locations)
          Padding(
            padding: EdgeInsets.only(bottom: UI.gapS),
            child: Card(
              child: ListTile(
                title: Text(location.title),
                subtitle: Text(location.description),
                trailing: _LocationFocusActions(
                  isSelected: selectedMarkerId == location.id,
                  focusLabel: focusLabel,
                  selectedLabel: selectedBadgeLabel,
                  onFocus: () => onFocus(location),
                ),
                onTap: () => onFocus(location),
              ),
            ),
          ),
      ],
    );
  }
}

class _LocationFocusActions extends StatelessWidget {
  const _LocationFocusActions({
    required this.isSelected,
    required this.focusLabel,
    required this.selectedLabel,
    required this.onFocus,
  });

  final bool isSelected;
  final String focusLabel;
  final String selectedLabel;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Container(
            margin: EdgeInsets.only(right: UI.gapXS),
            padding: EdgeInsets.symmetric(
              horizontal: UI.gapS,
              vertical: UI.gapXS,
            ),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(UI.radiusM / 2),
            ),
            child: Text(
              selectedLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
        TextButton.icon(
          onPressed: onFocus,
          icon: const Icon(Icons.near_me),
          label: Text(focusLabel),
        ),
      ],
    );
  }
}
