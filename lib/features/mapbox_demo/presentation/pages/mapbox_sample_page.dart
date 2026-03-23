import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/cubit/mapbox_sample_cubit.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/cubit/mapbox_sample_state.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/widgets/mapbox_location_list.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/widgets/mapbox_messages.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/widgets/mapbox_sample_map_view.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxSamplePage extends StatefulWidget {
  const MapboxSamplePage({
    super.key,
    this.platformOverride,
  });

  final TargetPlatform? platformOverride;

  @override
  State<MapboxSamplePage> createState() => _MapboxSamplePageState();
}

class _MapboxSamplePageState extends State<MapboxSamplePage> {
  late final TargetPlatform _platform;
  late final bool _isMapboxSupported;
  late final String? _token;
  late final bool _hasValidToken;

  @override
  void initState() {
    super.initState();

    _platform = widget.platformOverride ?? defaultTargetPlatform;
    _isMapboxSupported =
        !kIsWeb &&
        (_platform == TargetPlatform.iOS ||
            _platform == TargetPlatform.android);

    _token = SecretConfig.mapboxAccessToken?.trim();
    _hasValidToken = _token?.isNotEmpty ?? false;
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return CommonPageLayout(
      title: l10n.mapboxPageTitle,
      useResponsiveBody: false,
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(final AppLocalizations l10n) {
    if (!_isMapboxSupported) {
      return MapboxUnsupportedMessage(
        message: l10n.mapboxPageUnsupportedDescription,
      );
    }

    if (!_hasValidToken) {
      return MapboxMissingTokenMessage(
        title: l10n.mapboxPageMissingTokenTitle,
        description: l10n.mapboxPageMissingTokenDescription,
      );
    }

    return TypeSafeBlocBuilder<MapboxSampleCubit, MapboxSampleState>(
      builder: (final context, final state) {
        if (state.isLoading && state.locations.isEmpty) {
          return const CommonLoadingWidget();
        }

        if (state.hasError) {
          return MapboxErrorMessage(
            message: state.errorMessage ?? l10n.googleMapsPageGenericError,
          );
        }

        final CameraOptions cameraOptions = CameraOptions(
          center: Point(
            coordinates: Position(
              state.cameraCenter.longitude,
              state.cameraCenter.latitude,
            ),
          ),
          zoom: state.cameraZoom,
        );

        return LayoutBuilder(
          builder: (final context, final constraints) {
            final bool useHorizontalLayout = constraints.maxWidth >= 900;

            final Widget mapSection = SizedBox(
              height: useHorizontalLayout ? double.infinity : 320,
              child: MapboxSampleMapView(
                locations: state.locations,
                cameraOptions: cameraOptions,
                onSelectLocation: context
                    .cubit<MapboxSampleCubit>()
                    .selectLocation,
              ),
            );

            final Widget detailsSection = ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: useHorizontalLayout ? 360 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MapboxLocationList(
                    locations: state.locations,
                    selectedLocationId: state.selectedLocationId,
                    emptyLabel: l10n.googleMapsPageEmptyLocations,
                    heading: l10n.googleMapsPageLocationsHeading,
                    focusLabel: l10n.googleMapsPageFocusButton,
                    selectedBadgeLabel: l10n.googleMapsPageSelectedBadge,
                    onFocus: (final location) => context
                        .cubit<MapboxSampleCubit>()
                        .focusLocation(location),
                  ),
                ],
              ),
            );

            if (useHorizontalLayout) {
              return Padding(
                padding: context.allGapL,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: mapSection),
                    SizedBox(width: context.responsiveGapL),
                    Flexible(child: detailsSection),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: context.allGapL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  mapSection,
                  SizedBox(height: context.responsiveGapL),
                  detailsSection,
                ],
              ),
            );
          },
        );
      },
    );
  }
}
