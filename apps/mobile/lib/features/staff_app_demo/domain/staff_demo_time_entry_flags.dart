class StaffDemoTimeEntryFlags {
  const StaffDemoTimeEntryFlags({
    required this.outsideGeofence,
    required this.earlyClockIn,
    required this.locationInsufficient,
    required this.missingScheduledShift,
    required this.duplicatePunchAttempt,
    required this.deviceClockSkewSuspected,
  });

  const StaffDemoTimeEntryFlags.none()
    : outsideGeofence = false,
      earlyClockIn = false,
      locationInsufficient = false,
      missingScheduledShift = false,
      duplicatePunchAttempt = false,
      deviceClockSkewSuspected = false;

  final bool outsideGeofence;
  final bool earlyClockIn;
  final bool locationInsufficient;
  final bool missingScheduledShift;
  final bool duplicatePunchAttempt;
  final bool deviceClockSkewSuspected;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'outsideGeofence': outsideGeofence,
    'earlyClockIn': earlyClockIn,
    'locationInsufficient': locationInsufficient,
    'missingScheduledShift': missingScheduledShift,
    'duplicatePunchAttempt': duplicatePunchAttempt,
    'deviceClockSkewSuspected': deviceClockSkewSuspected,
  };
}
