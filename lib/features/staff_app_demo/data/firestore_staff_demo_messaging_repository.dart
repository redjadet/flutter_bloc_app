import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';

class FirestoreStaffDemoMessagingRepository {
  FirestoreStaffDemoMessagingRepository({
    required final FirebaseFirestore firestore,
    required final AuthRepository authRepository,
  }) : _firestore = firestore,
       _authRepository = authRepository;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  Future<String> sendShiftAssignment({
    required final String toUserId,
    required final String body,
    required final String siteId,
    required final DateTime startAtUtc,
    required final DateTime endAtUtc,
    required final String timezoneName,
  }) async {
    final fromUserId = _authRepository.currentUser?.id;
    if (fromUserId == null || fromUserId.isEmpty) {
      throw StateError('Not signed in');
    }

    final shiftRef = _firestore.collection('staffDemoShifts').doc();
    await shiftRef.set(<String, dynamic>{
      'userId': toUserId,
      'siteId': siteId,
      'title': 'Shift',
      'startAt': Timestamp.fromDate(startAtUtc),
      'endAt': Timestamp.fromDate(endAtUtc),
      'timezoneName': timezoneName,
      'status': 'assigned',
      'assignedBy': fromUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final msgRef = _firestore.collection('staffDemoMessages').doc();
    await msgRef.set(<String, dynamic>{
      'createdBy': fromUserId,
      'type': 'shift_assignment',
      'shiftId': shiftRef.id,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final recipientRef = _firestore
        .collection('staffDemoMessageRecipients')
        .doc('${msgRef.id}_$toUserId');
    await recipientRef.set(<String, dynamic>{
      'messageId': msgRef.id,
      'userId': toUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return msgRef.id;
  }

  Future<void> confirmShiftAssignment({
    required final String messageId,
    required final String shiftId,
  }) async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Not signed in');
    }

    final recipientRef = _firestore
        .collection('staffDemoMessageRecipients')
        .doc('${messageId}_$userId');
    await recipientRef.set(
      <String, dynamic>{
        'confirmedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await _firestore.collection('staffDemoShifts').doc(shiftId).set(
      <String, dynamic>{
        'status': 'confirmed',
        'confirmationAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
