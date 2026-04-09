import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Demo-friendly heuristic: find a shift for user where startAt <= now <= endAt.
    // Indexing can be added later if needed.
    final query = await _firestore
        .collection('staffDemoShifts')
        .where('userId', isEqualTo: userId)
        .where('startAt', isLessThanOrEqualTo: Timestamp.fromDate(nowUtc))
        .orderBy('startAt', descending: true)
        .limit(5)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final endAtRaw = data['endAt'];
      final siteId = (data['siteId'] as String?)?.trim();
      final tz = (data['timezoneName'] as String?)?.trim();
      if (siteId == null || siteId.isEmpty) continue;
      if (tz == null || tz.isEmpty) continue;
      if (endAtRaw is! Timestamp) continue;
      final endAtUtc = endAtRaw.toDate().toUtc();
      if (nowUtc.isAfter(endAtUtc)) continue;

      final startAtRaw = data['startAt'];
      if (startAtRaw is! Timestamp) continue;
      final startAtUtc = startAtRaw.toDate().toUtc();

      return StaffDemoShift(
        shiftId: doc.id,
        userId: userId,
        siteId: siteId,
        startAtUtc: startAtUtc,
        endAtUtc: endAtUtc,
        timezoneName: tz,
      );
    }

    return null;
  }
}
