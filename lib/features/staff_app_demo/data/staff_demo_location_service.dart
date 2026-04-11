import 'dart:async';

import 'package:geolocator/geolocator.dart';

class StaffDemoCapturedLocation {
  const StaffDemoCapturedLocation({
    required this.lat,
    required this.lng,
    required this.accuracyMeters,
    required this.capturedAtUtc,
  });

  final double lat;
  final double lng;
  final double? accuracyMeters;
  final DateTime capturedAtUtc;
}

class StaffDemoLocationService {
  StaffDemoLocationService({
    final Future<Position> Function()? currentPositionFetcher,
    final Duration locationTimeout = const Duration(seconds: 5),
  }) : _currentPositionFetcher =
           currentPositionFetcher ??
           (() => Geolocator.getCurrentPosition(
             locationSettings: LocationSettings(
               timeLimit: locationTimeout,
             ),
           ));

  final Future<Position> Function() _currentPositionFetcher;

  /// Uses `Geolocator.getCurrentPosition` with `LocationSettings(timeLimit: …)`
  /// so the Geolocator stack owns the timeout (see geolocator package docs).
  /// Call sites may still inject `currentPositionFetcher` for tests.
  Future<StaffDemoCapturedLocation?> captureCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final Position pos = await _currentPositionFetcher();

      return StaffDemoCapturedLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        accuracyMeters: pos.accuracy.isFinite ? pos.accuracy : null,
        capturedAtUtc: DateTime.now().toUtc(),
      );
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }
}
