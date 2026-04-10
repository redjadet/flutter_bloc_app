class StaffDemoInboxItem {
  const StaffDemoInboxItem({
    required this.messageId,
    required this.body,
    required this.type,
    required this.shiftId,
    required this.confirmedAtMs,
    required this.shiftStatus,
  });

  final String messageId;
  final String body;
  final String type;
  final String? shiftId;
  final int? confirmedAtMs;
  final String? shiftStatus;

  bool get isConfirmed => shiftStatus == 'confirmed';
}
