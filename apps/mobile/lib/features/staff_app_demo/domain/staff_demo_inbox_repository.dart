import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_message.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';

abstract interface class StaffDemoInboxRepository {
  Stream<List<StaffDemoInboxRecipientSnapshot>> watchRecipients({
    required String userId,
  });

  Future<StaffDemoInboxMessage?> loadMessage(String messageId);

  Future<String?> loadShiftStatus(String shiftId);
}
