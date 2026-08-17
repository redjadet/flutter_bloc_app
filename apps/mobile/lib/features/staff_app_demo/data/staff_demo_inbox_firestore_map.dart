import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_message.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';

/// Firestore map helpers for staff demo inbox (data layer only).
abstract final class StaffDemoInboxFirestoreMap {
  static List<StaffDemoInboxRecipientSnapshot> recipientsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
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
    Map<String, dynamic> data,
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

  /// Maps Firestore message document data to a domain inbox message.
  ///
  /// Returns null only when [data] is null. Malformed/missing optional fields
  /// become null on the model (presentation defaults blank strings).
  static StaffDemoInboxMessage? messageFromData(
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      return null;
    }
    return StaffDemoInboxMessage(
      body: _optionalString(data['body']),
      type: _optionalString(data['type']),
      shiftId: _optionalString(data['shiftId']),
    );
  }

  static String? _optionalString(Object? value) {
    if (value is! String) {
      return null;
    }
    return value;
  }
}
