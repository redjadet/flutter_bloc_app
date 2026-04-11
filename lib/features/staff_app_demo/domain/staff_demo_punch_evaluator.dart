import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';

class StaffDemoClockInEvaluation {
  const StaffDemoClockInEvaluation({
    required this.flags,
  });

  final StaffDemoTimeEntryFlags flags;
}

class StaffDemoPunchEvaluator {
  static const Duration earlyClockInThreshold = Duration(minutes: 15);
  static const double maxTrustedAccuracyMeters = 100;

  static StaffDemoClockInEvaluation evaluateClockIn({
    required final DateTime nowUtc,
    required final DateTime? shiftStartUtc,
    required final double? distanceMeters,
    required final double? radiusMeters,
    required final double? accuracyMeters,
  }) {
    final bool missingScheduledShift = shiftStartUtc == null;
    final bool earlyClockIn =
        shiftStartUtc != null &&
        nowUtc.isBefore(shiftStartUtc.subtract(earlyClockInThreshold));

    final bool outsideGeofence =
        distanceMeters != null &&
        radiusMeters != null &&
        distanceMeters > radiusMeters;

    final bool locationInsufficient =
        accuracyMeters == null || accuracyMeters > maxTrustedAccuracyMeters;

    return StaffDemoClockInEvaluation(
      flags: StaffDemoTimeEntryFlags(
        outsideGeofence: outsideGeofence,
        earlyClockIn: earlyClockIn,
        locationInsufficient: locationInsufficient,
        missingScheduledShift: missingScheduledShift,
        duplicatePunchAttempt: false,
        deviceClockSkewSuspected: false,
      ),
    );
  }
}
