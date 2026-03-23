import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxSampleMapView extends StatefulWidget {
  const MapboxSampleMapView({
    required this.locations,
    required this.cameraOptions,
    required this.onSelectLocation,
    super.key,
  });

  final List<MapLocation> locations;
  final CameraOptions cameraOptions;
  final ValueChanged<String> onSelectLocation;

  @override
  State<MapboxSampleMapView> createState() => _MapboxSampleMapViewState();
}

class _MapboxSampleMapViewState extends State<MapboxSampleMapView> {
  PointAnnotationManager? _pointAnnotationManager;
  Cancelable? _tapCancelable;

  String _locationsSignature = '';

  Future<void> _initializeAnnotationsIfNeeded() async {
    final PointAnnotationManager? manager = _pointAnnotationManager;
    if (manager == null) return;
    if (widget.locations.isEmpty) return;

    final String signature = widget.locations
        .map((final location) => location.id)
        .join('|');
    if (signature == _locationsSignature) return;

    _locationsSignature = signature;

    await manager.deleteAll();

    final List<PointAnnotationOptions> options = widget.locations.map((
      final location,
    ) {
      return PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            location.coordinate.longitude,
            location.coordinate.latitude,
          ),
        ),
        textField: location.title,
        textSize: 12,
        customData: <String, Object>{
          'locationId': location.id,
        },
      );
    }).toList();

    await manager.createMulti(options);
  }

  @override
  void didUpdateWidget(covariant final MapboxSampleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_initializeAnnotationsIfNeeded());
  }

  @override
  void dispose() {
    _tapCancelable?.cancel();
    super.dispose();
  }

  void _onMapCreated(final MapboxMap controller) {
    unawaited(() async {
      final PointAnnotationManager manager = await controller.annotations
          .createPointAnnotationManager(
            id: 'mapbox_locations',
          );

      if (!mounted) return;

      _pointAnnotationManager = manager;
      _tapCancelable = manager.tapEvents(
        onTap: (final annotation) {
          final Object? rawId = annotation.customData?['locationId'];
          if (rawId is! String) return;
          widget.onSelectLocation(rawId);
        },
      );

      await _initializeAnnotationsIfNeeded();
    }());
  }

  @override
  Widget build(final BuildContext context) {
    return MapWidget(
      cameraOptions: widget.cameraOptions,
      onMapCreated: _onMapCreated,
    );
  }
}
