import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';

abstract interface class StaffDemoTimeclockLocalStore {
  Future<StaffDemoOpenEntrySnapshot?> loadOpenEntry({required String userId});

  Future<void> saveOpenEntry({
    required String userId,
    required StaffDemoOpenEntrySnapshot snapshot,
  });

  Future<void> clearOpenEntry({required String userId});
}
