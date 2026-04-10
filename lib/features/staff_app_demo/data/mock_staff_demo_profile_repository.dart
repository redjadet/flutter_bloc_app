import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';

class MockStaffDemoProfileRepository implements StaffDemoProfileRepository {
  MockStaffDemoProfileRepository({
    final Map<String, StaffDemoProfile> profiles = const {},
  }) : _profiles = profiles;

  final Map<String, StaffDemoProfile> _profiles;

  @override
  Future<StaffDemoProfile?> loadProfile({required final String userId}) async =>
      _profiles[userId];

  @override
  Future<List<StaffDemoProfile>> listAssignableStaff() async {
    final profiles = _profiles.values.where((p) => p.isActive);
    final list = profiles.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return list;
  }
}
