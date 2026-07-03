import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Google Maps implementation of the map view.
class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({
    required this.stateManager,
    required this.controller,
    required this.onCameraMove,
    super.key,
  });

  final MapStateManager stateManager;
  final Completer<gmaps.GoogleMapController> controller;
  final ValueChanged<gmaps.CameraPosition> onCameraMove;

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  gmaps.GoogleMapController? _mapController;

  void _onMapCreated(final gmaps.GoogleMapController controller) {
    _mapController = controller;
    if (!widget.controller.isCompleted) {
      widget.controller.complete(controller);
    }
  }

  @override
  Widget build(final BuildContext context) => gmaps.GoogleMap(
    mapType: widget.stateManager.mapType,
    initialCameraPosition: widget.stateManager.cameraPosition,
    markers: widget.stateManager.markers,
    trafficEnabled: widget.stateManager.trafficEnabled,
    onMapCreated: _onMapCreated,
    onCameraMove: widget.onCameraMove,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
