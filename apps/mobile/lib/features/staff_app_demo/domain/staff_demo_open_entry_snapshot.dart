class StaffDemoOpenEntrySnapshot {
  const StaffDemoOpenEntrySnapshot({
    required this.entryId,
    required this.clockInAtUtc,
    required this.shiftId,
    required this.siteId,
  });

  final String entryId;
  final DateTime clockInAtUtc;
  final String? shiftId;
  final String? siteId;
}
