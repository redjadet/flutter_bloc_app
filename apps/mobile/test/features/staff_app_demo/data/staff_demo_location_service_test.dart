import 'dart:async';
import 'package:core/core.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  _FakeGeolocatorPlatform();

  bool serviceEnabled = true;
  bool throwOnServiceCheck = false;
  bool throwOnCheckPermission = false;
  bool throwOnRequestPermission = false;
  LocationPermission checkPermissionResult = LocationPermission.always;
  LocationPermission requestPermissionResult = LocationPermission.always;
  bool requestPermissionCalled = false;
  Future<Position> Function()? positionFuture;
  LocationSettings? lastLocationSettings;

  @override
  Future<LocationPermission> checkPermission() async {
    if (throwOnCheckPermission) {
      throw PlatformException(code: 'test', message: 'checkPermission failed');
    }
    return checkPermissionResult;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCalled = true;
    if (throwOnRequestPermission) {
      throw PlatformException(
        code: 'test',
        message: 'requestPermission failed',
      );
    }
    return requestPermissionResult;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (throwOnServiceCheck) {
      throw PlatformException(
        code: 'test',
        message: 'isLocationServiceEnabled failed',
      );
    }
    return serviceEnabled;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    lastLocationSettings = locationSettings;
    final future = positionFuture;
    if (future != null) {
      return future();
    }
    final limit = locationSettings?.timeLimit;
    if (limit == null) {
      return Completer<Position>().future;
    }
    await Future<void>.delayed(limit);
    throw TimeoutException('Timed out waiting for position update.', limit);
  }
}

Position _samplePosition({double latitude = 41.0, double longitude = 29.0}) =>
    Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.utc(2026, 1, 1),
      accuracy: 12,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  late GeolocatorPlatform previousPlatform;
  late _FakeGeolocatorPlatform fake;

  setUp(() {
    previousPlatform = GeolocatorPlatform.instance;
    fake = _FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = fake;
  });

  tearDown(() {
    GeolocatorPlatform.instance = previousPlatform;
  });

  test('returns PlatformFailure when location service disabled', () async {
    fake.serviceEnabled = false;
    final service = StaffDemoLocationService();

    final result = await service.captureCurrentLocation();

    expect(result, isA<FailureResult<StaffDemoCapturedLocation>>());
    expect(result.failureOrNull, isA<PlatformFailure>());
  });

  test('returns UnknownFailure when isLocationServiceEnabled throws', () async {
    fake.throwOnServiceCheck = true;
    final service = StaffDemoLocationService();

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<UnknownFailure>());
  });

  test('returns UnknownFailure when checkPermission throws', () async {
    fake.throwOnCheckPermission = true;
    final service = StaffDemoLocationService();

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<UnknownFailure>());
  });

  test('returns UnknownFailure when requestPermission throws', () async {
    fake.checkPermissionResult = LocationPermission.denied;
    fake.throwOnRequestPermission = true;
    final service = StaffDemoLocationService();

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<UnknownFailure>());
  });

  test('returns PermissionFailure when permission denied forever', () async {
    fake.checkPermissionResult = LocationPermission.deniedForever;
    final service = StaffDemoLocationService();

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<PermissionFailure>());
    final failure = result.failureOrNull! as PermissionFailure;
    expect(failure.reason, PermissionFailureReason.permanentlyDenied);
  });

  test(
    'returns PermissionFailure when permission denied after request',
    () async {
      fake.checkPermissionResult = LocationPermission.denied;
      fake.requestPermissionResult = LocationPermission.denied;
      final service = StaffDemoLocationService();

      final result = await service.captureCurrentLocation();

      expect(result.failureOrNull, isA<PermissionFailure>());
      final failure = result.failureOrNull! as PermissionFailure;
      expect(failure.reason, PermissionFailureReason.denied);
    },
  );

  test(
    'requests permission when status is unableToDetermine then captures location',
    () async {
      fake.checkPermissionResult = LocationPermission.unableToDetermine;
      fake.requestPermissionResult = LocationPermission.whileInUse;
      final service = StaffDemoLocationService(
        currentPositionFetcher: () async => _samplePosition(),
      );

      final result = await service.captureCurrentLocation();

      expect(fake.requestPermissionCalled, isTrue);
      expect(result, isA<Success<StaffDemoCapturedLocation>>());
    },
  );

  test(
    'returns PermissionFailure when permission stays unableToDetermine after request',
    () async {
      fake.checkPermissionResult = LocationPermission.unableToDetermine;
      fake.requestPermissionResult = LocationPermission.unableToDetermine;
      final service = StaffDemoLocationService();

      final result = await service.captureCurrentLocation();

      expect(fake.requestPermissionCalled, isTrue);
      expect(result.failureOrNull, isA<PermissionFailure>());
      final failure = result.failureOrNull! as PermissionFailure;
      expect(failure.reason, PermissionFailureReason.denied);
    },
  );

  test('returns TimeoutFailure when Geolocator times out', () async {
    const timeout = Duration(milliseconds: 20);
    final service = StaffDemoLocationService(locationTimeout: timeout);

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<TimeoutFailure>());
    expect(fake.lastLocationSettings?.timeLimit, timeout);
  });

  test('injected fetcher timeout maps to TimeoutFailure', () async {
    final service = StaffDemoLocationService(
      currentPositionFetcher: () async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        throw TimeoutException('injected', const Duration(seconds: 1));
      },
    );

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<TimeoutFailure>());
  });

  test('returns ValidationFailure when coordinates are non-finite', () async {
    final service = StaffDemoLocationService(
      currentPositionFetcher: () async => _samplePosition(latitude: double.nan),
    );

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<ValidationFailure>());
    final failure = result.failureOrNull! as ValidationFailure;
    expect(failure.code, 'invalidCoordinates');
  });

  test('returns Success with captured location on happy path', () async {
    final service = StaffDemoLocationService(
      currentPositionFetcher: () async => _samplePosition(),
    );

    final result = await service.captureCurrentLocation();

    expect(result, isA<Success<StaffDemoCapturedLocation>>());
    final location = result.getOrNull()!;
    expect(location.lat, 41.0);
    expect(location.lng, 29.0);
    expect(location.accuracyMeters, 12);
  });

  test('returns PlatformFailure when getCurrentPosition throws '
      'LocationServiceDisabledException', () async {
    final service = StaffDemoLocationService(
      currentPositionFetcher: () async {
        throw const LocationServiceDisabledException();
      },
    );

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<PlatformFailure>());
    final failure = result.failureOrNull! as PlatformFailure;
    expect(failure.reason, PlatformFailureReason.unavailable);
  });

  test('returns PermissionFailure when getCurrentPosition throws '
      'PermissionDeniedException', () async {
    final service = StaffDemoLocationService(
      currentPositionFetcher: () async {
        throw const PermissionDeniedException('denied during fetch');
      },
    );

    final result = await service.captureCurrentLocation();

    expect(result.failureOrNull, isA<PermissionFailure>());
    final failure = result.failureOrNull! as PermissionFailure;
    expect(failure.reason, PermissionFailureReason.denied);
  });
}
