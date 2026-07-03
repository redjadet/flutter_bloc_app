import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';

class StaffDemoTimeEntrySummary {
  const StaffDemoTimeEntrySummary({
    required this.entryId,
    required this.userId,
    required this.entryState,
    required this.flags,
    required this.clockInAtClientMs,
    required this.clockOutAtClientMs,
  });

  final String entryId;
  final String userId;
  final String entryState;
  final StaffDemoTimeEntryFlags flags;
  final int? clockInAtClientMs;
  final int? clockOutAtClientMs;

  bool get isFlagged =>
      flags.outsideGeofence ||
      flags.earlyClockIn ||
      flags.locationInsufficient ||
      flags.missingScheduledShift ||
      flags.deviceClockSkewSuspected ||
      flags.duplicatePunchAttempt;
}
