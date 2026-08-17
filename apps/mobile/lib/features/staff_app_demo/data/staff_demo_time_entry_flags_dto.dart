import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';

/// Wire DTO for [StaffDemoTimeEntryFlags] sync / Firestore payloads.
class const StaffDemoTimeEntryFlagsDto({
  required final bool outsideGeofence,
  required final bool earlyClockIn,
  required final bool locationInsufficient,
  required final bool missingScheduledShift,
  required final bool duplicatePunchAttempt,
  required final bool deviceClockSkewSuspected,
}) {
  StaffDemoTimeEntryFlagsDto.fromDomain(StaffDemoTimeEntryFlags flags)
    : this(
        outsideGeofence: flags.outsideGeofence,
        earlyClockIn: flags.earlyClockIn,
        locationInsufficient: flags.locationInsufficient,
        missingScheduledShift: flags.missingScheduledShift,
        duplicatePunchAttempt: flags.duplicatePunchAttempt,
        deviceClockSkewSuspected: flags.deviceClockSkewSuspected,
      );

  factory StaffDemoTimeEntryFlagsDto.fromJson(
    Map<String, dynamic> json,
  ) => StaffDemoTimeEntryFlagsDto(
    outsideGeofence: (json['outsideGeofence'] as bool?) ?? false,
    earlyClockIn: (json['earlyClockIn'] as bool?) ?? false,
    locationInsufficient: (json['locationInsufficient'] as bool?) ?? false,
    missingScheduledShift: (json['missingScheduledShift'] as bool?) ?? false,
    duplicatePunchAttempt: (json['duplicatePunchAttempt'] as bool?) ?? false,
    deviceClockSkewSuspected:
        (json['deviceClockSkewSuspected'] as bool?) ?? false,
  );

  StaffDemoTimeEntryFlags toDomain() => StaffDemoTimeEntryFlags(
    outsideGeofence: outsideGeofence,
    earlyClockIn: earlyClockIn,
    locationInsufficient: locationInsufficient,
    missingScheduledShift: missingScheduledShift,
    duplicatePunchAttempt: duplicatePunchAttempt,
    deviceClockSkewSuspected: deviceClockSkewSuspected,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'outsideGeofence': outsideGeofence,
    'earlyClockIn': earlyClockIn,
    'locationInsufficient': locationInsufficient,
    'missingScheduledShift': missingScheduledShift,
    'duplicatePunchAttempt': duplicatePunchAttempt,
    'deviceClockSkewSuspected': deviceClockSkewSuspected,
  };
}
