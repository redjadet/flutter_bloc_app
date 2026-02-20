import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amap;
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_utils.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Apple Maps implementation of the map view.
class AppleMapsView extends StatefulWidget {
  const AppleMapsView({
    required this.stateManager,
    required this.cubit,
    required this.onCameraMove,
    required this.onMapCreated,
    super.key,
  });

  final MapStateManager stateManager;
  final MapSampleCubit cubit;
  final ValueChanged<gmaps.CameraPosition> onCameraMove;
  final ValueChanged<amap.AppleMapController> onMapCreated;

  @override
  State<AppleMapsView> createState() => _AppleMapsViewState();
}

class _AppleMapsViewState extends State<AppleMapsView> {
  Set<amap.Annotation>? _cachedAnnotations;
  String? _cachedSelectedId;
  List<MapLocation>? _cachedLocations;

  @override
  Widget build(final BuildContext context) => amap.AppleMap(
    mapType: resolveAppleMapType(widget.stateManager.mapType),
    initialCameraPosition: appleCameraPositionFromGoogle(
      widget.stateManager.cameraPosition,
    ),
    annotations: _buildAnnotations(),
    trafficEnabled: widget.stateManager.trafficEnabled,
    onMapCreated: widget.onMapCreated,
    onCameraMove: (final position) =>
        widget.onCameraMove(googleCameraPositionFromApple(position)),
  );

  Set<amap.Annotation> _buildAnnotations() {
    final String? selectedId = widget.stateManager.selectedMarkerId?.value;
    final List<MapLocation> locations = widget.stateManager.locations;

    // Cache annotations to avoid rebuilding on every build call
    final existing = _cachedAnnotations;
    if (existing != null &&
        _cachedSelectedId == selectedId &&
        _cachedLocations == locations) {
      return existing;
    }

    _cachedSelectedId = selectedId;
    _cachedLocations = locations;
    final annotations = locations
        .map(
          (final location) => amap.Annotation(
            annotationId: amap.AnnotationId(location.id),
            position: amap.LatLng(
              location.coordinate.latitude,
              location.coordinate.longitude,
            ),
            infoWindow: amap.InfoWindow(
              title: location.title,
              snippet: location.description,
            ),
            zIndex: selectedId == location.id ? 1 : 0,
            onTap: () => widget.cubit.selectLocation(location.id),
          ),
        )
        .toSet();
    _cachedAnnotations = annotations;
    return annotations;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
