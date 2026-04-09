import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';

class StaffDemoProfile {
  const StaffDemoProfile({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.phoneE164,
    required this.isActive,
  });

  final String userId;
  final String displayName;
  final String email;
  final StaffDemoRole role;
  final String? phoneE164;
  final bool isActive;
}
