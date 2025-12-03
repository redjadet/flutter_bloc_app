// coverage:ignore-file
import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amap;
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_controller.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_utils.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class MapSampleMapView extends StatefulWidget {
  const MapSampleMapView({
    required this.initialState,
    required this.cubit,
    required this.useAppleMaps,
    required this.controller,
    super.key,
  });

  final MapSampleState initialState;
  final MapSampleCubit cubit;
  final bool useAppleMaps;
  final MapSampleMapController controller;

  @override
  State<MapSampleMapView> createState() => _MapSampleMapViewState();
}

class _MapSampleMapViewState extends State<MapSampleMapView> {
  late gmaps.MapType _mapType;
  bool _trafficEnabled = false;
  bool _isAnimatingCamera = false;
  late Set<gmaps.Marker> _markers;
  late List<MapLocation> _locations;
  gmaps.MarkerId? _selectedMarkerId;
  late gmaps.CameraPosition _cameraPosition;
  final Completer<gmaps.GoogleMapController> _googleMapController =
      Completer<gmaps.GoogleMapController>();
  gmaps.GoogleMapController? _googleMapControllerInstance;
  amap.AppleMapController? _appleMapController;

  @override
  void initState() {
    super.initState();
    _mapType = widget.initialState.mapType;
    _trafficEnabled = widget.initialState.trafficEnabled;
    _markers = widget.initialState.markers;
    _locations = widget.initialState.locations;
    _selectedMarkerId = widget.initialState.selectedMarkerId;
    _cameraPosition = widget.initialState.cameraPosition;
    widget.controller.focusHandler = _focusOnLocation;
    widget.controller.syncStateHandler = _applyStateUpdate;
  }

  @override
  void didUpdateWidget(final MapSampleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.focusHandler = null;
      oldWidget.controller.syncStateHandler = null;
      widget.controller.focusHandler = _focusOnLocation;
      widget.controller.syncStateHandler = _applyStateUpdate;
    }
    if (oldWidget.initialState != widget.initialState) {
      unawaited(_applyStateUpdate(widget.initialState));
    }
  }

  @override
  Widget build(final BuildContext context) => RepaintBoundary(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(context.responsiveCardRadius),
      child: widget.useAppleMaps ? _buildAppleMap() : _buildGoogleMap(),
    ),
  );

  Widget _buildGoogleMap() => gmaps.GoogleMap(
    mapType: _mapType,
    initialCameraPosition: _cameraPosition,
    markers: _markers,
    trafficEnabled: _trafficEnabled,
    onMapCreated: (final gmaps.GoogleMapController controller) {
      _googleMapControllerInstance = controller;
      if (!_googleMapController.isCompleted) {
        _googleMapController.complete(controller);
      }
    },
    onCameraMove: (final gmaps.CameraPosition position) {
      _cameraPosition = position;
      if (!_isAnimatingCamera) {
        widget.cubit.updateCameraPosition(position);
      }
    },
  );

  Widget _buildAppleMap() => amap.AppleMap(
    mapType: resolveAppleMapType(_mapType),
    initialCameraPosition: appleCameraPositionFromGoogle(_cameraPosition),
    annotations: _buildAppleAnnotations(),
    trafficEnabled: _trafficEnabled,
    onMapCreated: (final amap.AppleMapController controller) {
      _appleMapController = controller;
    },
    onCameraMove: (final amap.CameraPosition position) {
      _cameraPosition = googleCameraPositionFromApple(position);
      if (!_isAnimatingCamera) {
        widget.cubit.updateCameraPosition(_cameraPosition);
      }
    },
  );

  Set<amap.Annotation> _buildAppleAnnotations() {
    final String? selectedId = _selectedMarkerId?.value;
    return _locations
        .map(
          (final MapLocation location) => amap.Annotation(
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

  Future<gmaps.GoogleMapController?> _ensureGoogleController() async {
    if (_googleMapControllerInstance != null) {
      return _googleMapControllerInstance;
    }
    if (!_googleMapController.isCompleted) {
      return null;
    }
    return _googleMapControllerInstance = await _googleMapController.future;
  }

  Future<void> _applyStateUpdate(final MapSampleState state) async {
    if (!mounted) {
      return;
    }
    final bool shouldMoveCamera = state.cameraPosition != _cameraPosition;
    final bool shouldUpdateMapType = state.mapType != _mapType;
    final bool shouldUpdateTraffic = state.trafficEnabled != _trafficEnabled;
    final bool shouldUpdateMarkers = state.markers != _markers;
    final bool shouldUpdateSelection =
        state.selectedMarkerId != _selectedMarkerId;
    final bool shouldUpdateLocations = state.locations != _locations;

    if (shouldMoveCamera) {
      await _moveCamera(state.cameraPosition);
      if (!mounted) {
        return;
      }
    }

    if (shouldUpdateMapType ||
        shouldUpdateTraffic ||
        shouldUpdateMarkers ||
        shouldUpdateSelection ||
        shouldUpdateLocations) {
      setState(() {
        if (shouldUpdateMapType) {
          _mapType = state.mapType;
        }
        if (shouldUpdateTraffic) {
          _trafficEnabled = state.trafficEnabled;
        }
        if (shouldUpdateMarkers) {
          _markers = state.markers;
        }
        if (shouldUpdateSelection) {
          _selectedMarkerId = state.selectedMarkerId;
        }
        if (shouldUpdateLocations) {
          _locations = state.locations;
        }
      });
    }
    _cameraPosition = state.cameraPosition;
  }

  Future<void> _moveCamera(final gmaps.CameraPosition position) async {
    if (widget.useAppleMaps) {
      final amap.AppleMapController? appleController = _appleMapController;
      if (appleController == null) {
        return;
      }
      await appleController.moveCamera(
        appleCameraUpdateForPosition(position),
      );
      return;
    }
    final gmaps.GoogleMapController? controller =
        await _ensureGoogleController();
    if (controller == null) {
      return;
    }
    await controller.moveCamera(
      gmaps.CameraUpdate.newCameraPosition(
        position,
      ),
    );
  }

  Future<void> _focusOnLocation(final MapLocation location) async {
    final gmaps.CameraPosition targetPosition = widget.cubit
        .cameraPositionForLocation(location);
    _isAnimatingCamera = true;
    if (widget.useAppleMaps) {
      final amap.AppleMapController? appleController = _appleMapController;
      if (appleController == null) {
        _isAnimatingCamera = false;
        return;
      }
      await appleController.animateCamera(
        appleCameraUpdateForLocation(location),
      );
    } else {
      final gmaps.GoogleMapController? controller =
          await _ensureGoogleController();
      if (controller == null) {
        _isAnimatingCamera = false;
        return;
      }
      await controller.animateCamera(
        widget.cubit.cameraUpdateForLocation(location),
      );
    }
    // Keep local camera position synced to avoid redundant moves.
    _cameraPosition = targetPosition;
    _isAnimatingCamera = false;
    if (mounted) {
      widget.cubit.focusLocation(location);
    }
  }

  @override
  void dispose() {
    widget.controller.focusHandler = null;
    widget.controller.syncStateHandler = null;
    if (!widget.useAppleMaps) {
      _googleMapControllerInstance?.dispose();
      _googleMapControllerInstance = null;
    }
    _appleMapController = null;
    super.dispose();
  }
}
