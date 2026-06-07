class StaffDemoInboxRecipientSnapshot {
  const StaffDemoInboxRecipientSnapshot({
    required this.messageId,
    this.confirmedAtMs,
  });

  final String messageId;
  final int? confirmedAtMs;
}
