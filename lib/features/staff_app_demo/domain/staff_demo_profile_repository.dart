import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';

abstract interface class StaffDemoProfileRepository {
  Future<StaffDemoProfile?> loadProfile({required String userId});

  /// Returns active staff profiles that can receive a shift assignment in the demo.
  Future<List<StaffDemoProfile>> listAssignableStaff();
}
