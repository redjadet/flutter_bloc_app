import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';

/// Parses `staffDemoProfiles/{userId}` document data into [StaffDemoProfile].
///
/// When [omitInactive] is true, returns null for inactive profiles (used when
/// building assignable staff lists).
StaffDemoProfile? staffDemoProfileFromFirestoreDoc({
  required final String userId,
  required final Map<String, dynamic> data,
  final bool omitInactive = false,
}) {
  final role = StaffDemoRole.tryParse(data['role'] as String?);
  if (role == null) return null;

  final isActive = (data['isActive'] as bool?) ?? true;
  if (omitInactive && !isActive) return null;

  return StaffDemoProfile(
    userId: userId,
    displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
        ? (data['displayName'] as String).trim()
        : userId,
    email: (data['email'] as String?)?.trim() ?? '',
    role: role,
    phoneE164: (data['phoneE164'] as String?)?.trim(),
    isActive: isActive,
  );
}
