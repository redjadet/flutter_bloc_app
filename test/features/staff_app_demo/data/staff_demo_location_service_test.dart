import 'dart:async';

import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

/// Honors [LocationSettings.timeLimit] like the real method-channel stack:
/// after [timeLimit], throws [TimeoutException] (never completes with a hang).
class _TimeoutAfterLimitGeolocatorPlatform extends GeolocatorPlatform {
  LocationSettings? lastLocationSettings;

  @override
  Future<LocationPermission> checkPermission() async => LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async => LocationPermission.always;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    lastLocationSettings = locationSettings;
    final limit = locationSettings?.timeLimit;
    if (limit == null) {
      return Completer<Position>().future;
    }
    await Future<void>.delayed(limit);
    throw TimeoutException('Timed out waiting for position update.', limit);
  }
}

void main() {
  final previousPlatform = GeolocatorPlatform.instance;
  final fake = _TimeoutAfterLimitGeolocatorPlatform();

  setUp(() {
    GeolocatorPlatform.instance = fake;
  });

  tearDown(() {
    GeolocatorPlatform.instance = previousPlatform;
  });

  test('captureCurrentLocation returns null when Geolocator times out', () async {
    const timeout = Duration(milliseconds: 20);
    final service = StaffDemoLocationService(locationTimeout: timeout);

    final result = await service.captureCurrentLocation();

    expect(result, isNull);
    expect(fake.lastLocationSettings?.timeLimit, timeout);
  });

  test('injected fetcher timeout still returns null', () async {
    final previousPlatform = GeolocatorPlatform.instance;
    GeolocatorPlatform.instance = _TimeoutAfterLimitGeolocatorPlatform();
    addTearDown(() => GeolocatorPlatform.instance = previousPlatform);

    final service = StaffDemoLocationService(
      locationTimeout: const Duration(seconds: 5),
      currentPositionFetcher: () async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        throw TimeoutException('injected', const Duration(seconds: 1));
      },
    );

    expect(await service.captureCurrentLocation(), isNull);
  });
}
