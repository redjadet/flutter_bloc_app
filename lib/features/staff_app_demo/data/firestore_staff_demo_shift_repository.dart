import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_shift_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';

class FirestoreStaffDemoShiftRepository implements StaffDemoShiftRepository {
  FirestoreStaffDemoShiftRepository({
    required final FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<StaffDemoShift?> findActiveShift({
    required final String userId,
    required final DateTime nowUtc,
  }) async {
    final query = await _firestore
        .collection('staffDemoShifts')
        .where('userId', isEqualTo: userId)
        .where('startAt', isLessThanOrEqualTo: Timestamp.fromDate(nowUtc))
        .orderBy('startAt', descending: true)
        .limit(5)
        .get();

    for (final doc in query.docs) {
      final shift = staffDemoActiveShiftFromFirestoreDoc(
        shiftId: doc.id,
        userId: userId,
        data: doc.data(),
        nowUtc: nowUtc,
      );
      if (shift != null) {
        return shift;
      }
    }

    return null;
  }
}
