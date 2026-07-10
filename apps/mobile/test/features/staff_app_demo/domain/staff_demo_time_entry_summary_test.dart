import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isFlagged false when no flags', () {
    const StaffDemoTimeEntrySummary summary = StaffDemoTimeEntrySummary(
      entryId: 'e1',
      userId: 'u1',
      entryState: 'open',
      flags: StaffDemoTimeEntryFlags.none(),
      clockInAtClientMs: 1,
      clockOutAtClientMs: null,
    );
    expect(summary.isFlagged, isFalse);
  });

  test('isFlagged true for each flag bit', () {
    StaffDemoTimeEntrySummary withFlags({
      final bool outsideGeofence = false,
      final bool earlyClockIn = false,
      final bool locationInsufficient = false,
      final bool missingScheduledShift = false,
      final bool duplicatePunchAttempt = false,
      final bool deviceClockSkewSuspected = false,
    }) => StaffDemoTimeEntrySummary(
      entryId: 'e1',
      userId: 'u1',
      entryState: 'open',
      flags: StaffDemoTimeEntryFlags(
        outsideGeofence: outsideGeofence,
        earlyClockIn: earlyClockIn,
        locationInsufficient: locationInsufficient,
        missingScheduledShift: missingScheduledShift,
        duplicatePunchAttempt: duplicatePunchAttempt,
        deviceClockSkewSuspected: deviceClockSkewSuspected,
      ),
      clockInAtClientMs: null,
      clockOutAtClientMs: null,
    );

    expect(withFlags(outsideGeofence: true).isFlagged, isTrue);
    expect(withFlags(earlyClockIn: true).isFlagged, isTrue);
    expect(withFlags(locationInsufficient: true).isFlagged, isTrue);
    expect(withFlags(missingScheduledShift: true).isFlagged, isTrue);
    expect(withFlags(duplicatePunchAttempt: true).isFlagged, isTrue);
    expect(withFlags(deviceClockSkewSuspected: true).isFlagged, isTrue);
  });
}
