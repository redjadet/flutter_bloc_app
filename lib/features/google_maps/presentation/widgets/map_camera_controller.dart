import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amap;
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Controls camera movements and animations for both Google and Apple Maps.
class MapCameraController {
  MapCameraController({
    required this.cubit,
    required this.useAppleMaps,
    required this.googleController,
    required this.appleController,
  });

  final MapSampleCubit cubit;
  final bool useAppleMaps;
  final Completer<gmaps.GoogleMapController> googleController;
  amap.AppleMapController? appleController;

  Future<gmaps.GoogleMapController?> _ensureGoogleController() async {
    if (!googleController.isCompleted) {
      return null;
    }
    return googleController.future;
  }

  /// Move camera to a specific position without animation.
  Future<void> moveCamera(final gmaps.CameraPosition position) async {
    if (useAppleMaps) {
      final amap.AppleMapController? controller = appleController;
      if (controller == null) return;

      await controller.moveCamera(
        appleCameraUpdateForPosition(position),
      );
      return;
    }

    final gmaps.GoogleMapController? controller =
        await _ensureGoogleController();
    if (controller == null) return;

    await controller.moveCamera(
      gmaps.CameraUpdate.newCameraPosition(position),
    );
  }

  /// Animate camera to focus on a location.
  Future<void> focusOnLocation(
    final MapLocation location, {
    required VoidCallback onAnimationStart,
    required VoidCallback onAnimationEnd,
  }) async {
    onAnimationStart();

    if (useAppleMaps) {
      final amap.AppleMapController? controller = appleController;
      if (controller == null) {
        onAnimationEnd();
        return;
      }

      await controller.animateCamera(appleCameraUpdateForLocation(location));
    } else {
      final gmaps.GoogleMapController? controller =
          await _ensureGoogleController();
      if (controller == null) {
        onAnimationEnd();
        return;
      }

      await controller.animateCamera(cubit.cameraUpdateForLocation(location));
    }

    onAnimationEnd();
  }
}
