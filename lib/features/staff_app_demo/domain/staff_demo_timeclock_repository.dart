import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';

class StaffDemoClockResult {
  const StaffDemoClockResult({
    required this.entryId,
    required this.flags,
    required this.shiftId,
    required this.siteId,
    required this.distanceMeters,
    required this.radiusMeters,
  });

  final String entryId;
  final StaffDemoTimeEntryFlags flags;
  final String? shiftId;
  final String? siteId;
  final double? distanceMeters;
  final double? radiusMeters;
}

abstract interface class StaffDemoTimeclockRepository {
  Future<StaffDemoClockResult> clockIn();
  Future<StaffDemoClockResult> clockOut();
}
