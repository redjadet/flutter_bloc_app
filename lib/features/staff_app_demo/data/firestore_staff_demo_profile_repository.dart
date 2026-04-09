import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';

class FirestoreStaffDemoProfileRepository
    implements StaffDemoProfileRepository {
  FirestoreStaffDemoProfileRepository({
    required final FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<StaffDemoProfile?> loadProfile({required final String userId}) async {
    final snap = await _firestore
        .collection('staffDemoProfiles')
        .doc(userId)
        .get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;

    final role = StaffDemoRole.tryParse(data['role'] as String?);
    if (role == null) return null;

    return StaffDemoProfile(
      userId: userId,
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? (data['displayName'] as String).trim()
          : userId,
      email: (data['email'] as String?)?.trim() ?? '',
      role: role,
      phoneE164: (data['phoneE164'] as String?)?.trim(),
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }
}
