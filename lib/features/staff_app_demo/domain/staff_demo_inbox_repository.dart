import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';

abstract interface class StaffDemoInboxRepository {
  Stream<List<StaffDemoInboxRecipientSnapshot>> watchRecipients({
    required String userId,
  });

  Future<Map<String, dynamic>?> loadMessage(String messageId);

  Future<String?> loadShiftStatus(String shiftId);
}
