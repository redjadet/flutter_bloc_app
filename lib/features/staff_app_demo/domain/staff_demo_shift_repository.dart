import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift.dart';

abstract interface class StaffDemoShiftRepository {
  Future<StaffDemoShift?> findActiveShift({
    required String userId,
    required DateTime nowUtc,
  });
}
