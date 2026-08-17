import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';

class FirestoreStaffDemoFormsRepository implements StaffDemoFormsRepository {
  FirestoreStaffDemoFormsRepository({
    required this._firestore,
  });

  final FirebaseFirestore _firestore;

  @override
  Future<void> submitAvailability({
    required String userId,
    required DateTime weekStartUtc,
    required Map<String, bool> availabilityByIsoDate,
  }) async {
    final docId = '${userId}_${weekStartUtc.toIso8601String()}';
    await _firestore.collection('staffDemoAvailability').doc(docId).set(
      <String, dynamic>{
        'userId': userId,
        'weekStartUtc': Timestamp.fromDate(weekStartUtc),
        'availability': availabilityByIsoDate,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> submitManagerReport({
    required String userId,
    required String siteId,
    required String notes,
  }) async {
    final docId = _firestore.collection('staffDemoManagerReports').doc().id;
    await _firestore.collection('staffDemoManagerReports').doc(docId).set(
      <String, dynamic>{
        'userId': userId,
        'siteId': siteId,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }
}
