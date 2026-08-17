import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';

class const StaffDemoTimeEntrySummary({
  required final String entryId,
  required final String userId,
  required final String entryState,
  required final StaffDemoTimeEntryFlags flags,
  required final int? clockInAtClientMs,
  required final int? clockOutAtClientMs,
}) {
  bool get isFlagged =>
      flags.outsideGeofence ||
      flags.earlyClockIn ||
      flags.locationInsufficient ||
      flags.missingScheduledShift ||
      flags.deviceClockSkewSuspected ||
      flags.duplicatePunchAttempt;
}
