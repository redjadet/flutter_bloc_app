import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_result_unwrap.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('unwrapStaffDemoLocationResult', () {
    final capturedAt = DateTime.utc(2026, 6, 16, 12);

    StaffDemoCapturedLocation location() => StaffDemoCapturedLocation(
      lat: 40.7,
      lng: -74.0,
      accuracyMeters: 12,
      capturedAtUtc: capturedAt,
    );

    test('returns location on success', () {
      final expected = location();

      final actual = unwrapStaffDemoLocationResult(
        Success<StaffDemoCapturedLocation>(expected),
        'test context',
      );

      expect(actual, expected);
    });

    test('returns null and logs on permission failure', () {
      final actual = unwrapStaffDemoLocationResult(
        FailureResult<StaffDemoCapturedLocation>(
          PermissionFailure(PermissionFailureReason.denied),
        ),
        'Staff demo clock-in',
      );

      expect(actual, isNull);
    });

    test('returns null on platform failure', () {
      final actual = unwrapStaffDemoLocationResult(
        FailureResult<StaffDemoCapturedLocation>(
          PlatformFailure(PlatformFailureReason.unavailable),
        ),
        'Staff demo clock-out',
      );

      expect(actual, isNull);
    });
  });
}
