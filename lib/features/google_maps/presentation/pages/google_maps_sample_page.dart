import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_controls.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_layout.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_location_list.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_messages.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_view.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class GoogleMapsSamplePage extends StatefulWidget {
  const GoogleMapsSamplePage({super.key, this.platformService});

  final NativePlatformService? platformService;

  @override
  State<GoogleMapsSamplePage> createState() => _GoogleMapsSamplePageState();
}

class _GoogleMapsSamplePageState extends State<GoogleMapsSamplePage> {
  late final MapSampleMapController _mapViewController;
  late final NativePlatformService _platformService;
  bool _hasRequiredApiKey = true;
  bool _isCheckingApiKey = false;
  late final bool _useAppleMaps;

  MapSampleCubit get _cubit => context.read<MapSampleCubit>();

  @override
  void initState() {
    super.initState();
    _mapViewController = MapSampleMapController();
    _useAppleMaps = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    _platformService = widget.platformService ?? NativePlatformService();
    if (_isMapsSupported && !_useAppleMaps) {
      _resolveApiKeyAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: RootAwareBackButton(homeTooltip: l10n.homeTitle),
        title: Text(l10n.googleMapsPageTitle),
      ),
      body: !_isMapsSupported
          ? GoogleMapsUnsupportedMessage(
              message: l10n.googleMapsPageUnsupportedDescription,
            )
          : (!_useAppleMaps && _isCheckingApiKey)
          ? const Center(child: CircularProgressIndicator())
          : (!_useAppleMaps && !_hasRequiredApiKey)
          ? GoogleMapsMissingKeyMessage(
              title: l10n.googleMapsPageMissingKeyTitle,
              description: l10n.googleMapsPageMissingKeyDescription,
            )
          : BlocBuilder<MapSampleCubit, MapSampleState>(
              builder: (BuildContext context, MapSampleState state) {
                if (state.isLoading && state.markers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.hasError) {
                  return GoogleMapsErrorMessage(
                    message:
                        state.errorMessage ?? l10n.googleMapsPageGenericError,
                  );
                }
                return GoogleMapsContentLayout(
                  map: MapSampleMapView(
                    state: state,
                    cubit: _cubit,
                    useAppleMaps: _useAppleMaps,
                    controller: _mapViewController,
                  ),
                  controls: _buildControls(context, state),
                  locations: _buildLocationList(context, state),
                );
              },
            ),
    );
  }

  Widget _buildControls(BuildContext context, MapSampleState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return GoogleMapsControlsCard(
      heading: l10n.googleMapsPageControlsHeading,
      helpText: l10n.googleMapsPageApiKeyHelp,
      isHybridMapType: state.mapType == gmaps.MapType.hybrid,
      trafficEnabled: state.trafficEnabled,
      onToggleMapType: _cubit.toggleMapType,
      onToggleTraffic: (_) => _cubit.toggleTraffic(),
      mapTypeHybridLabel: l10n.googleMapsPageMapTypeHybrid,
      mapTypeNormalLabel: l10n.googleMapsPageMapTypeNormal,
      trafficToggleLabel: l10n.googleMapsPageTrafficToggle,
    );
  }

  Widget _buildLocationList(BuildContext context, MapSampleState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return GoogleMapsLocationList(
      locations: state.locations,
      selectedMarkerId: state.selectedMarkerId?.value,
      emptyLabel: l10n.googleMapsPageEmptyLocations,
      heading: l10n.googleMapsPageLocationsHeading,
      focusLabel: l10n.googleMapsPageFocusButton,
      selectedBadgeLabel: l10n.googleMapsPageSelectedBadge,
      onFocus: (MapLocation location) {
        unawaited(_mapViewController.focusOnLocation(location));
      },
    );
  }

  bool get _isMapsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  Future<void> _resolveApiKeyAvailability() async {
    if (_useAppleMaps) {
      return;
    }
    setState(() {
      _isCheckingApiKey = true;
    });
    final bool hasKey = await _platformService.hasGoogleMapsApiKey();
    if (!mounted) {
      return;
    }
    setState(() {
      _hasRequiredApiKey = hasKey;
      _isCheckingApiKey = false;
    });
  }
}
