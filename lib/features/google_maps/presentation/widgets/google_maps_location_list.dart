import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class GoogleMapsLocationList extends StatelessWidget {
  const GoogleMapsLocationList({
    required this.locations,
    required this.selectedMarkerId,
    required this.emptyLabel,
    required this.heading,
    required this.focusLabel,
    required this.selectedBadgeLabel,
    required this.onFocus,
    super.key,
  });

  final List<MapLocation> locations;
  final String? selectedMarkerId;
  final String emptyLabel;
  final String heading;
  final String focusLabel;
  final String selectedBadgeLabel;
  final ValueChanged<MapLocation> onFocus;

  @override
  Widget build(final BuildContext context) {
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
        SizedBox(height: context.responsiveGapS),
        for (final MapLocation location in locations)
          Padding(
            key: ValueKey('map-location-${location.id}'),
            padding: EdgeInsets.only(bottom: context.responsiveGapS),
            child: CommonCard(
              padding: EdgeInsets.zero,
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
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Container(
            margin: EdgeInsets.only(right: context.responsiveGapXS),
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveGapS,
              vertical: context.responsiveGapXS,
            ),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(
                context.responsiveCardRadius / 2,
              ),
            ),
            child: Text(
              selectedLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
        PlatformAdaptive.textButton(
          context: context,
          onPressed: onFocus,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.near_me),
              SizedBox(width: context.responsiveHorizontalGapS),
              Text(focusLabel),
            ],
          ),
        ),
      ],
    );
  }
}
