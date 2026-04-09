class StaffDemoShift {
  const StaffDemoShift({
    required this.shiftId,
    required this.userId,
    required this.siteId,
    required this.startAtUtc,
    required this.endAtUtc,
    required this.timezoneName,
  });

  final String shiftId;
  final String userId;
  final String siteId;
  final DateTime startAtUtc;
  final DateTime endAtUtc;
  final String timezoneName;
}
