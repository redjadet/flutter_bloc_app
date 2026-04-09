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
}
