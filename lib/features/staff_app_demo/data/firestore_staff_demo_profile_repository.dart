import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class FirestoreStaffDemoProfileRepository
    implements StaffDemoProfileRepository {
  FirestoreStaffDemoProfileRepository({
    required final FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<StaffDemoProfile>> listAssignableStaff() async {
    // Keep this query simple to avoid needing composite indexes in demo env.
    // We filter `isActive` client-side below.
    final QuerySnapshot<Map<String, dynamic>> snaps;
    try {
      snaps = await _firestore.collection('staffDemoProfiles').get();
    } on FirebaseException catch (error) {
      // In some environments this list query can be blocked by Firestore rules.
      // The messaging UI supports manual recipient entry, so treat this as a
      // recoverable capability miss rather than a hard failure.
      if (error.code == 'permission-denied') {
        AppLogger.info(
          'FirestoreStaffDemoProfileRepository.listAssignableStaff permission denied; returning empty list',
        );
        return const <StaffDemoProfile>[];
      }
      AppLogger.error(
        'FirestoreStaffDemoProfileRepository.listAssignableStaff failed',
        error,
        error.stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'FirestoreStaffDemoProfileRepository.listAssignableStaff failed',
        error,
        stackTrace,
      );
      rethrow;
    }

    final items = <StaffDemoProfile>[];
    for (final doc in snaps.docs) {
      final data = doc.data();

      // Defensive: keep only valid, active staff.
      final role = StaffDemoRole.tryParse(data['role'] as String?);
      if (role == null) continue;
      final isActive = (data['isActive'] as bool?) ?? true;
      if (!isActive) continue;

      final userId = doc.id;
      items.add(
        StaffDemoProfile(
          userId: userId,
          displayName:
              (data['displayName'] as String?)?.trim().isNotEmpty == true
              ? (data['displayName'] as String).trim()
              : userId,
          email: (data['email'] as String?)?.trim() ?? '',
          role: role,
          phoneE164: (data['phoneE164'] as String?)?.trim(),
          isActive: isActive,
        ),
      );
    }

    items.sort((a, b) => a.displayName.compareTo(b.displayName));
    return items;
  }

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
