import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_punch_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StaffDemoPunchEvaluator.evaluateClockIn', () {
    test('flags missing shift when shiftStartUtc is null', () {
      final eval = StaffDemoPunchEvaluator.evaluateClockIn(
        nowUtc: DateTime.utc(2026, 1, 1, 10, 0),
        shiftStartUtc: null,
        distanceMeters: null,
        radiusMeters: null,
        accuracyMeters: null,
      );

      expect(eval.flags.missingScheduledShift, true);
    });

    test('flags early clock-in when more than 15 minutes early', () {
      final eval = StaffDemoPunchEvaluator.evaluateClockIn(
        nowUtc: DateTime.utc(2026, 1, 1, 9, 30),
        shiftStartUtc: DateTime.utc(2026, 1, 1, 10, 0),
        distanceMeters: null,
        radiusMeters: null,
        accuracyMeters: 10,
      );

      expect(eval.flags.earlyClockIn, true);
    });

    test('does not flag early clock-in at 15 minutes early boundary', () {
      final eval = StaffDemoPunchEvaluator.evaluateClockIn(
        nowUtc: DateTime.utc(2026, 1, 1, 9, 45),
        shiftStartUtc: DateTime.utc(2026, 1, 1, 10, 0),
        distanceMeters: null,
        radiusMeters: null,
        accuracyMeters: 10,
      );

      expect(eval.flags.earlyClockIn, false);
    });

    test('flags outside geofence when distance > radius', () {
      final eval = StaffDemoPunchEvaluator.evaluateClockIn(
        nowUtc: DateTime.utc(2026, 1, 1, 10, 0),
        shiftStartUtc: DateTime.utc(2026, 1, 1, 10, 0),
        distanceMeters: 120,
        radiusMeters: 100,
        accuracyMeters: 10,
      );

      expect(eval.flags.outsideGeofence, true);
    });

    test('flags location insufficient when accuracy missing', () {
      final eval = StaffDemoPunchEvaluator.evaluateClockIn(
        nowUtc: DateTime.utc(2026, 1, 1, 10, 0),
        shiftStartUtc: DateTime.utc(2026, 1, 1, 10, 0),
        distanceMeters: 10,
        radiusMeters: 100,
        accuracyMeters: null,
      );

      expect(eval.flags.locationInsufficient, true);
    });
  });
}
