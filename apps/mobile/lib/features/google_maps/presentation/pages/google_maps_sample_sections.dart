// coverage:ignore-file
// Part file - tested indirectly via google_maps_sample_page tests

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
  Widget build(BuildContext context) =>
      TypeSafeBlocListener<MapSampleCubit, MapSampleState>(
        listenWhen: _mapStateChanged,
        listener: (context, state) async {
          await controller.syncWithState(state);
        },
        child: TypeSafeBlocBuilder<MapSampleCubit, MapSampleState>(
          buildWhen: (previous, current) => false,
          builder: (context, state) => RepaintBoundary(
            child: MapSampleMapView(
              initialState: state,
              cubit: cubit,
              useAppleMaps: useAppleMaps,
              controller: controller,
            ),
          ),
        ),
      );

  bool _mapStateChanged(
    MapSampleState previous,
    MapSampleState current,
  ) =>
      previous.cameraPosition != current.cameraPosition ||
      previous.markers != current.markers ||
      previous.mapType != current.mapType ||
      previous.trafficEnabled != current.trafficEnabled ||
      previous.locations != current.locations ||
      previous.selectedMarkerId != current.selectedMarkerId;
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
  Widget build(BuildContext context) =>
      TypeSafeBlocSelector<MapSampleCubit, MapSampleState, _ControlsViewModel>(
        selector: (state) => _ControlsViewModel(
          isHybridMapType: state.mapType == gmaps.MapType.hybrid,
          trafficEnabled: state.trafficEnabled,
        ),
        builder: (context, viewModel) => GoogleMapsControlsCard(
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
  Widget build(BuildContext context) =>
      TypeSafeBlocSelector<
        MapSampleCubit,
        MapSampleState,
        _LocationListViewModel
      >(
        selector: (state) => _LocationListViewModel(
          locations: state.locations,
          selectedMarkerId: state.selectedMarkerId?.value,
        ),
        builder:
            (
              context,
              viewModel,
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
