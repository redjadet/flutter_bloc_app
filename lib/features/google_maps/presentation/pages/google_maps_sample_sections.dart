part of 'google_maps_sample_page.dart';

class _GoogleMapsMapSection extends StatelessWidget {
  const _GoogleMapsMapSection({
    required this.controller,
    required this.cubit,
    required this.useAppleMaps,
  });

  final MapSampleMapController controller;
  final MapSampleCubit cubit;
  final bool useAppleMaps;

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<MapSampleCubit, MapSampleState>(
        buildWhen:
            (final MapSampleState previous, final MapSampleState current) =>
                previous.cameraPosition != current.cameraPosition ||
                previous.markers != current.markers ||
                previous.mapType != current.mapType ||
                previous.trafficEnabled != current.trafficEnabled ||
                previous.locations != current.locations ||
                previous.selectedMarkerId != current.selectedMarkerId,
        builder: (final BuildContext context, final MapSampleState state) =>
            RepaintBoundary(
              child: MapSampleMapView(
                state: state,
                cubit: cubit,
                useAppleMaps: useAppleMaps,
                controller: controller,
              ),
            ),
      );
}

class _GoogleMapsControlsSection extends StatelessWidget {
  const _GoogleMapsControlsSection({
    required this.l10n,
    required this.onToggleMapType,
    required this.onToggleTraffic,
  });

  final AppLocalizations l10n;
  final VoidCallback onToggleMapType;
  final ValueChanged<bool> onToggleTraffic;

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<MapSampleCubit, MapSampleState, _ControlsViewModel>(
        selector: (final MapSampleState state) => _ControlsViewModel(
          isHybridMapType: state.mapType == gmaps.MapType.hybrid,
          trafficEnabled: state.trafficEnabled,
        ),
        builder:
            (final BuildContext context, final _ControlsViewModel viewModel) =>
                GoogleMapsControlsCard(
                  heading: l10n.googleMapsPageControlsHeading,
                  helpText: l10n.googleMapsPageApiKeyHelp,
                  isHybridMapType: viewModel.isHybridMapType,
                  trafficEnabled: viewModel.trafficEnabled,
                  onToggleMapType: onToggleMapType,
                  onToggleTraffic: onToggleTraffic,
                  mapTypeHybridLabel: l10n.googleMapsPageMapTypeHybrid,
                  mapTypeNormalLabel: l10n.googleMapsPageMapTypeNormal,
                  trafficToggleLabel: l10n.googleMapsPageTrafficToggle,
                ),
      );
}

class _GoogleMapsLocationListSection extends StatelessWidget {
  const _GoogleMapsLocationListSection({
    required this.l10n,
    required this.onFocus,
  });

  final AppLocalizations l10n;
  final ValueChanged<MapLocation> onFocus;

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<MapSampleCubit, MapSampleState, _LocationListViewModel>(
        selector: (final MapSampleState state) => _LocationListViewModel(
          locations: state.locations,
          selectedMarkerId: state.selectedMarkerId?.value,
        ),
        builder:
            (
              final BuildContext context,
              final _LocationListViewModel viewModel,
            ) => GoogleMapsLocationList(
              locations: viewModel.locations,
              selectedMarkerId: viewModel.selectedMarkerId,
              emptyLabel: l10n.googleMapsPageEmptyLocations,
              heading: l10n.googleMapsPageLocationsHeading,
              focusLabel: l10n.googleMapsPageFocusButton,
              selectedBadgeLabel: l10n.googleMapsPageSelectedBadge,
              onFocus: onFocus,
            ),
      );
}

class _ControlsViewModel extends Equatable {
  const _ControlsViewModel({
    required this.isHybridMapType,
    required this.trafficEnabled,
  });

  final bool isHybridMapType;
  final bool trafficEnabled;

  @override
  List<Object?> get props => <Object?>[isHybridMapType, trafficEnabled];
}

class _LocationListViewModel extends Equatable {
  const _LocationListViewModel({
    required this.locations,
    required this.selectedMarkerId,
  });

  final List<MapLocation> locations;
  final String? selectedMarkerId;

  @override
  List<Object?> get props => <Object?>[locations, selectedMarkerId];
}
