abstract interface class StaffDemoMessagingRepository {
  Future<String> sendShiftAssignment({
    required String toUserId,
    required String body,
    required String siteId,
    required DateTime startAtUtc,
    required DateTime endAtUtc,
    required String timezoneName,
  });

  Future<void> confirmShiftAssignment({
    required String messageId,
    required String shiftId,
  });
}
