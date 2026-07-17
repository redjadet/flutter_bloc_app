import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';

/// Wire DTO for [StaffDemoTimeEntryFlags] sync / Firestore payloads.
class StaffDemoTimeEntryFlagsDto {
  const StaffDemoTimeEntryFlagsDto({
    required this.outsideGeofence,
    required this.earlyClockIn,
    required this.locationInsufficient,
    required this.missingScheduledShift,
    required this.duplicatePunchAttempt,
    required this.deviceClockSkewSuspected,
  });

  StaffDemoTimeEntryFlagsDto.fromDomain(final StaffDemoTimeEntryFlags flags)
    : outsideGeofence = flags.outsideGeofence,
      earlyClockIn = flags.earlyClockIn,
      locationInsufficient = flags.locationInsufficient,
      missingScheduledShift = flags.missingScheduledShift,
      duplicatePunchAttempt = flags.duplicatePunchAttempt,
      deviceClockSkewSuspected = flags.deviceClockSkewSuspected;

  factory StaffDemoTimeEntryFlagsDto.fromJson(
    final Map<String, dynamic> json,
  ) => StaffDemoTimeEntryFlagsDto(
    outsideGeofence: (json['outsideGeofence'] as bool?) ?? false,
    earlyClockIn: (json['earlyClockIn'] as bool?) ?? false,
    locationInsufficient: (json['locationInsufficient'] as bool?) ?? false,
    missingScheduledShift: (json['missingScheduledShift'] as bool?) ?? false,
    duplicatePunchAttempt: (json['duplicatePunchAttempt'] as bool?) ?? false,
    deviceClockSkewSuspected: (json['deviceClockSkewSuspected'] as bool?) ?? false,
  );

  final bool outsideGeofence;
  final bool earlyClockIn;
  final bool locationInsufficient;
  final bool missingScheduledShift;
  final bool duplicatePunchAttempt;
  final bool deviceClockSkewSuspected;

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
