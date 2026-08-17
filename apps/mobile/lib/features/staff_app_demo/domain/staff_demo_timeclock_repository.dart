import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';

class const StaffDemoClockResult({
  required final String entryId,
  required final StaffDemoTimeEntryFlags flags,
  required final String? shiftId,
  required final String? siteId,
  required final double? distanceMeters,
  required final double? radiusMeters,
});

abstract interface class StaffDemoTimeclockRepository {
  Future<StaffDemoClockResult> clockIn();
  Future<StaffDemoClockResult> clockOut();
}
