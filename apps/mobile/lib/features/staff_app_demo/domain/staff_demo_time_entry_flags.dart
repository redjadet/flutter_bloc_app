class const StaffDemoTimeEntryFlags({
  required final bool outsideGeofence,
  required final bool earlyClockIn,
  required final bool locationInsufficient,
  required final bool missingScheduledShift,
  required final bool duplicatePunchAttempt,
  required final bool deviceClockSkewSuspected,
}) {
  const StaffDemoTimeEntryFlags.none()
    : this(
        outsideGeofence: false,
        earlyClockIn: false,
        locationInsufficient: false,
        missingScheduledShift: false,
        duplicatePunchAttempt: false,
        deviceClockSkewSuspected: false,
      );

  /// Readable flag map for demo UI (not a wire contract).
  Map<String, bool> get asMap => <String, bool>{
    'outsideGeofence': outsideGeofence,
    'earlyClockIn': earlyClockIn,
    'locationInsufficient': locationInsufficient,
    'missingScheduledShift': missingScheduledShift,
    'duplicatePunchAttempt': duplicatePunchAttempt,
    'deviceClockSkewSuspected': deviceClockSkewSuspected,
  };
}
