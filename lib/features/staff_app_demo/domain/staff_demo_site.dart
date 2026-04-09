class StaffDemoSite {
  const StaffDemoSite({
    required this.siteId,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.radiusMeters,
  });

  final String siteId;
  final String name;
  final double centerLat;
  final double centerLng;
  final double radiusMeters;
}
