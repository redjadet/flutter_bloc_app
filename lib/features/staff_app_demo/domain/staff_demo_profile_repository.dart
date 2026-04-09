import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';

abstract interface class StaffDemoProfileRepository {
  Future<StaffDemoProfile?> loadProfile({required String userId});
}
