import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';

/// Firestore map helpers for staff demo inbox (data layer only).
abstract final class StaffDemoInboxFirestoreMap {
  static List<StaffDemoInboxRecipientSnapshot> recipientsFromSnapshot(
    final QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final recipients = <StaffDemoInboxRecipientSnapshot>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      final StaffDemoInboxRecipientSnapshot? mapped = recipientFromData(
        doc.data(),
      );
      if (mapped != null) {
        recipients.add(mapped);
      }
    }
    return recipients;
  }

  static StaffDemoInboxRecipientSnapshot? recipientFromData(
    final Map<String, dynamic> data,
  ) {
    final String? messageId = data['messageId'] as String?;
    if (messageId == null || messageId.isEmpty) {
      return null;
    }
    final Object? confirmedAtRaw = data['confirmedAt'];
    final int? confirmedAtMs = confirmedAtRaw is Timestamp
        ? confirmedAtRaw.toDate().millisecondsSinceEpoch
        : null;
    return StaffDemoInboxRecipientSnapshot(
      messageId: messageId,
      confirmedAtMs: confirmedAtMs,
    );
  }

  /// Pass-through of Firestore message document data (domain API unchanged).
  static Map<String, dynamic>? messageFromData(
    final Map<String, dynamic>? data,
  ) => data;
}
