import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreStaffDemoInboxRepository {
  FirestoreStaffDemoInboxRepository({
    required final FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchRecipients({
    required final String userId,
  }) => _firestore
      .collection('staffDemoMessageRecipients')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();

  Future<Map<String, dynamic>?> loadMessage(final String messageId) async {
    final snap = await _firestore
        .collection('staffDemoMessages')
        .doc(messageId)
        .get();
    return snap.data();
  }
}
