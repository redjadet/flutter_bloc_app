import 'dart:async';

import 'package:core/core.dart';

import 'package:geolocator/geolocator.dart';

class const StaffDemoCapturedLocation({
  required final double lat,
  required final double lng,
  required final double? accuracyMeters,
  required final DateTime capturedAtUtc,
});

class StaffDemoLocationService {
  StaffDemoLocationService({
    Future<Position> Function()? currentPositionFetcher,
    Duration locationTimeout = const Duration(seconds: 5),
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
  Future<Result<StaffDemoCapturedLocation>> captureCurrentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const FailureResult(
          PlatformFailure(PlatformFailureReason.unavailable),
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const FailureResult(
          PermissionFailure(PermissionFailureReason.permanentlyDenied),
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const FailureResult(
          PermissionFailure(PermissionFailureReason.denied),
        );
      }
      // Geolocator 14 exposes only denied / deniedForever / whileInUse / always /
      // unableToDetermine. iOS `kCLAuthorizationStatusRestricted` maps to denied;
      // approximate location still reports whileInUse. Distinct
      // PermissionFailureReason.restricted/limited stay in core/domain for other
      // seams — not mappable here without permission_handler.

      final Position pos = await _currentPositionFetcher();
      if (!pos.latitude.isFinite || !pos.longitude.isFinite) {
        return const FailureResult(
          ValidationFailure('invalidCoordinates'),
        );
      }

      return Success(
        StaffDemoCapturedLocation(
          lat: pos.latitude,
          lng: pos.longitude,
          accuracyMeters: pos.accuracy.isFinite ? pos.accuracy : null,
          capturedAtUtc: DateTime.now().toUtc(),
        ),
      );
    } on LocationServiceDisabledException catch (error) {
      return FailureResult(
        PlatformFailure(PlatformFailureReason.unavailable, cause: error),
      );
    } on PermissionDeniedException catch (error) {
      return FailureResult(
        PermissionFailure(PermissionFailureReason.denied, cause: error),
      );
    } on TimeoutException catch (error) {
      return FailureResult(TimeoutFailure(cause: error));
    } on Exception catch (error) {
      return FailureResult(UnknownFailure(cause: error));
    }
  }
}
