// coverage:ignore-file
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/apple_maps_view.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_view.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_camera_controller.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_controller.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_state_manager.dart';
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
  late final MapStateManager _stateManager;
  late final Completer<gmaps.GoogleMapController> _googleMapController;
  late final MapCameraController _cameraController;
  bool _isAnimatingCamera = false;

  @override
  void initState() {
    super.initState();
    _stateManager = MapStateManager(
      cubit: widget.cubit,
      useAppleMaps: widget.useAppleMaps,
    );
    _stateManager.initialize(widget.initialState);
    _googleMapController = Completer<gmaps.GoogleMapController>();
    _cameraController = MapCameraController(
      cubit: widget.cubit,
      useAppleMaps: widget.useAppleMaps,
      googleController: _googleMapController,
      appleController: null, // Will be set when Apple Maps view is created
    );

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
      child: widget.useAppleMaps
          ? AppleMapsView(
              stateManager: _stateManager,
              cubit: widget.cubit,
              onCameraMove: _handleCameraMove,
              onMapCreated: (final controller) {
                _cameraController.appleController = controller;
              },
            )
          : GoogleMapsView(
              stateManager: _stateManager,
              controller: _googleMapController,
              onCameraMove: _handleCameraMove,
            ),
    ),
  );

  Future<void> _applyStateUpdate(final MapSampleState state) async {
    if (!mounted) return;

    final MapStateChanges changes = _stateManager.applyStateUpdate(state);

    // Handle camera movement if needed
    if (changes.cameraChanged && !_isAnimatingCamera) {
      await _cameraController.moveCamera(state.cameraPosition);
      if (!mounted) return;
    }

    // Update UI if any state changes require rebuild
    // Exclude camera changes from triggering rebuilds to prevent blinking
    // Camera updates from user interaction don't need widget rebuilds
    if (changes.mapTypeChanged ||
        changes.trafficChanged ||
        changes.markersChanged ||
        changes.selectionChanged ||
        changes.locationsChanged) {
      setState(() {});
    }
    // Camera changes are handled by moveCamera above and don't need setState
  }

  void _handleCameraMove(final gmaps.CameraPosition position) {
    if (_isAnimatingCamera) return;
    // Update local state only - don't notify cubit to prevent rebuilds/blinking
    // The cubit only needs camera position for programmatic updates
    _stateManager.updateCameraPosition(position, notifyCubit: false);
  }

  Future<void> _focusOnLocation(final MapLocation location) async {
    final gmaps.CameraPosition targetPosition = widget.cubit
        .cameraPositionForLocation(location);
    _stateManager.setCameraPosition(targetPosition);
    _isAnimatingCamera = true;
    try {
      await _cameraController.focusOnLocation(
        location,
        onAnimationStart: () {
          _isAnimatingCamera = true;
        },
        onAnimationEnd: () {
          _isAnimatingCamera = false;
        },
      );
    } finally {
      _isAnimatingCamera = false;
    }
    if (!mounted) return;
    widget.cubit.focusLocation(location);
  }

  @override
  void dispose() {
    widget.controller.focusHandler = null;
    widget.controller.syncStateHandler = null;
    super.dispose();
  }
}
