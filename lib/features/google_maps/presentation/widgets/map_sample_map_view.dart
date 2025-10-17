import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amap;
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class MapSampleMapController {
  Future<void> Function(MapLocation location)? _focusHandler;

  Future<void> focusOnLocation(MapLocation location) async {
    final handler = _focusHandler;
    if (handler == null) {
      return;
    }
    await handler(location);
  }

  void _attach(Future<void> Function(MapLocation location) handler) {
    _focusHandler = handler;
  }

  void _detach() {
    _focusHandler = null;
  }
}

class MapSampleMapView extends StatefulWidget {
  const MapSampleMapView({
    super.key,
    required this.state,
    required this.cubit,
    required this.useAppleMaps,
    required this.controller,
  });

  final MapSampleState state;
  final MapSampleCubit cubit;
  final bool useAppleMaps;
  final MapSampleMapController controller;

  @override
  State<MapSampleMapView> createState() => _MapSampleMapViewState();
}

class _MapSampleMapViewState extends State<MapSampleMapView> {
  final Completer<gmaps.GoogleMapController> _googleMapController =
      Completer<gmaps.GoogleMapController>();
  gmaps.GoogleMapController? _googleMapControllerInstance;
  amap.AppleMapController? _appleMapController;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(_focusOnLocation);
  }

  @override
  void didUpdateWidget(MapSampleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller._detach();
      widget.controller._attach(_focusOnLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UI.radiusM),
      child: widget.useAppleMaps ? _buildAppleMap() : _buildGoogleMap(),
    );
  }

  Widget _buildGoogleMap() {
    final MapSampleState state = widget.state;
    return gmaps.GoogleMap(
      mapType: state.mapType,
      initialCameraPosition: state.cameraPosition,
      markers: state.markers,
      trafficEnabled: state.trafficEnabled,
      onMapCreated: (gmaps.GoogleMapController controller) {
        _googleMapControllerInstance = controller;
        if (!_googleMapController.isCompleted) {
          _googleMapController.complete(controller);
        }
      },
      onCameraMove: widget.cubit.updateCameraPosition,
    );
  }

  Widget _buildAppleMap() {
    final MapSampleState state = widget.state;
    return amap.AppleMap(
      mapType: _resolveAppleMapType(state.mapType),
      initialCameraPosition: _toAppleCameraPosition(state.cameraPosition),
      annotations: _buildAppleAnnotations(state),
      trafficEnabled: state.trafficEnabled,
      onMapCreated: (amap.AppleMapController controller) {
        _appleMapController = controller;
      },
      onCameraMove: (amap.CameraPosition position) {
        widget.cubit.updateCameraPosition(_toGoogleCameraPosition(position));
      },
    );
  }

  Set<amap.Annotation> _buildAppleAnnotations(MapSampleState state) {
    final String? selectedId = state.selectedMarkerId?.value;
    return state.locations
        .map(
          (MapLocation location) => amap.Annotation(
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
  }

  amap.MapType _resolveAppleMapType(gmaps.MapType mapType) {
    switch (mapType) {
      case gmaps.MapType.hybrid:
        return amap.MapType.hybrid;
      case gmaps.MapType.satellite:
        return amap.MapType.satellite;
      default:
        return amap.MapType.standard;
    }
  }

  amap.CameraPosition _toAppleCameraPosition(gmaps.CameraPosition position) {
    return amap.CameraPosition(
      target: amap.LatLng(position.target.latitude, position.target.longitude),
      zoom: position.zoom,
      pitch: position.tilt,
      heading: position.bearing,
    );
  }

  gmaps.CameraPosition _toGoogleCameraPosition(amap.CameraPosition position) {
    return gmaps.CameraPosition(
      target: gmaps.LatLng(position.target.latitude, position.target.longitude),
      zoom: position.zoom,
      tilt: position.pitch,
      bearing: position.heading,
    );
  }

  amap.CameraUpdate _appleCameraUpdateForLocation(MapLocation location) {
    return amap.CameraUpdate.newCameraPosition(
      amap.CameraPosition(
        target: amap.LatLng(
          location.coordinate.latitude,
          location.coordinate.longitude,
        ),
        zoom: 14,
        pitch: 22,
      ),
    );
  }

  Future<gmaps.GoogleMapController?> _ensureGoogleController() async {
    if (_googleMapControllerInstance != null) {
      return _googleMapControllerInstance;
    }
    if (!_googleMapController.isCompleted) {
      return null;
    }
    _googleMapControllerInstance = await _googleMapController.future;
    return _googleMapControllerInstance;
  }

  Future<void> _focusOnLocation(MapLocation location) async {
    if (widget.useAppleMaps) {
      final amap.AppleMapController? appleController = _appleMapController;
      if (appleController == null) {
        return;
      }
      await appleController.animateCamera(
        _appleCameraUpdateForLocation(location),
      );
    } else {
      final gmaps.GoogleMapController? controller =
          await _ensureGoogleController();
      if (controller == null) {
        return;
      }
      await controller.animateCamera(
        widget.cubit.cameraUpdateForLocation(location),
      );
    }
    if (mounted) {
      widget.cubit.selectLocation(location.id);
    }
  }

  @override
  void dispose() {
    widget.controller._detach();
    if (!widget.useAppleMaps) {
      _googleMapControllerInstance?.dispose();
      _googleMapControllerInstance = null;
    }
    _appleMapController = null;
    super.dispose();
  }
}
