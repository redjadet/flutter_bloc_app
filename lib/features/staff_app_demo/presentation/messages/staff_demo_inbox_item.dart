class StaffDemoInboxItem {
  const StaffDemoInboxItem({
    required this.messageId,
    required this.body,
    required this.type,
    required this.shiftId,
    required this.confirmedAtMs,
  });

  final String messageId;
  final String body;
  final String type;
  final String? shiftId;
  final int? confirmedAtMs;

  bool get isConfirmed => confirmedAtMs != null;
}
