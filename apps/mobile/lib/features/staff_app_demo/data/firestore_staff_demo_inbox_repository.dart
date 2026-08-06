import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_inbox_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_message.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';

class FirestoreStaffDemoInboxRepository implements StaffDemoInboxRepository {
  FirestoreStaffDemoInboxRepository({
    required this._firestore,
  });

  final FirebaseFirestore _firestore;

  @override
  Stream<List<StaffDemoInboxRecipientSnapshot>> watchRecipients({
    required final String userId,
  }) {
    return _firestore
        .collection('staffDemoMessageRecipients')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(StaffDemoInboxFirestoreMap.recipientsFromSnapshot)
        .transform(
          StreamTransformer<
            List<StaffDemoInboxRecipientSnapshot>,
            List<StaffDemoInboxRecipientSnapshot>
          >.fromHandlers(
            handleError:
                (
                  final error,
                  final stackTrace,
                  final sink,
                ) {
                  if (error is FirebaseException &&
                      error.code == 'permission-denied') {
                    AppLogger.info(
                      'FirestoreStaffDemoInboxRepository.watchRecipients permission denied; emitting empty list',
                    );
                    sink.add(const <StaffDemoInboxRecipientSnapshot>[]);
                    return;
                  }
                  sink.addError(error, stackTrace);
                },
          ),
        );
  }

  @override
  Future<StaffDemoInboxMessage?> loadMessage(final String messageId) async {
    final snap = await _firestore
        .collection('staffDemoMessages')
        .doc(messageId)
        .get();
    return StaffDemoInboxFirestoreMap.messageFromData(snap.data());
  }

  @override
  Future<String?> loadShiftStatus(final String shiftId) async {
    final snap = await _firestore
        .collection('staffDemoShifts')
        .doc(shiftId)
        .get();
    final data = snap.data();
    return (data?['status'] as String?)?.trim();
  }
}
