class StaffDemoOpenEntrySnapshot {
  const StaffDemoOpenEntrySnapshot({
    required this.entryId,
    required this.clockInAtUtc,
    required this.shiftId,
    required this.siteId,
    required this.payload,
  });

  final String entryId;
  final DateTime clockInAtUtc;
  final String? shiftId;
  final String? siteId;

  /// Original punch evidence (lat/lng/accuracy/etc).
  final Map<String, dynamic> payload;
}
