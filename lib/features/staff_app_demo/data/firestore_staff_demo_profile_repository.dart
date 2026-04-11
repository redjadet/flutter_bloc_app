import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_profile_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class FirestoreStaffDemoProfileRepository
    implements StaffDemoProfileRepository {
  FirestoreStaffDemoProfileRepository({
    required final FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<StaffDemoProfile>> listAssignableStaff() async {
    final QuerySnapshot<Map<String, dynamic>> snaps;
    try {
      snaps = await _firestore.collection('staffDemoProfiles').get();
    } on FirebaseException catch (error) {
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
      final profile = staffDemoProfileFromFirestoreDoc(
        userId: doc.id,
        data: data,
        omitInactive: true,
      );
      if (profile != null) {
        items.add(profile);
      }
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

    return staffDemoProfileFromFirestoreDoc(userId: userId, data: data);
  }
}
