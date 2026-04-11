import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';

/// Parses `staffDemoSites/{siteId}` document data into [StaffDemoSite].
///
/// Supports:
/// - **Firestore GeoPoint** on `geofenceCenter` (console / native writes).
/// - **Nested map** on `geofenceCenter`: `{ lat, lng }` with
///   `geofenceRadiusMeters` or top-level `radiusMeters`.
/// - **Flat fields** (seed script / legacy): `centerLat`, `centerLng`,
///   `radiusMeters`.
StaffDemoSite? staffDemoSiteFromFirestoreMap({
  required final String siteId,
  required final Map<String, dynamic> data,
}) {
  final trimmedId = siteId.trim();
  if (trimmedId.isEmpty) return null;

  final name = (data['name'] as String?)?.trim();
  if (name == null || name.isEmpty) return null;

  final center = data['geofenceCenter'];
  if (center is GeoPoint) {
    final r = data['geofenceRadiusMeters'] ?? data['radiusMeters'];
    if (r is! num) return null;
    return StaffDemoSite(
      siteId: trimmedId,
      name: name,
      centerLat: center.latitude,
      centerLng: center.longitude,
      radiusMeters: r.toDouble(),
    );
  }
  if (center is Map<String, dynamic>) {
    final latRaw = center['lat'];
    final lngRaw = center['lng'];
    if (latRaw is! num || lngRaw is! num) return null;
    final r = data['geofenceRadiusMeters'] ?? data['radiusMeters'];
    if (r is! num) return null;
    return StaffDemoSite(
      siteId: trimmedId,
      name: name,
      centerLat: latRaw.toDouble(),
      centerLng: lngRaw.toDouble(),
      radiusMeters: r.toDouble(),
    );
  }

  final clat = data['centerLat'];
  final clng = data['centerLng'];
  final rad = data['radiusMeters'];
  if (clat is! num || clng is! num || rad is! num) return null;
  return StaffDemoSite(
    siteId: trimmedId,
    name: name,
    centerLat: clat.toDouble(),
    centerLng: clng.toDouble(),
    radiusMeters: rad.toDouble(),
  );
}
