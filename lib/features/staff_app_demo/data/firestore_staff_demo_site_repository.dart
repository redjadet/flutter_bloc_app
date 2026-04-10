import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';

class FirestoreStaffDemoSiteRepository implements StaffDemoSiteRepository {
  FirestoreStaffDemoSiteRepository({required final FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<StaffDemoSite>> listSites() async {
    final snap = await _firestore
        .collection('staffDemoSites')
        .orderBy('name')
        .limit(200)
        .get();

    final sites = <StaffDemoSite>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final siteId = doc.id.trim();
      if (siteId.isEmpty) continue;

      final name = (data['name'] as String?)?.trim();
      final center = data['geofenceCenter'];
      final radius = data['geofenceRadiusMeters'];

      if (name == null || name.isEmpty) continue;
      if (center is! Map<String, dynamic>) continue;
      final lat = center['lat'];
      final lng = center['lng'];
      if (lat is! num || lng is! num) continue;
      if (radius is! num) continue;

      sites.add(
        StaffDemoSite(
          siteId: siteId,
          name: name,
          centerLat: lat.toDouble(),
          centerLng: lng.toDouble(),
          radiusMeters: radius.toDouble(),
        ),
      );
    }
    return sites;
  }

  @override
  Future<StaffDemoSite?> loadSite({required final String siteId}) async {
    final snap = await _firestore
        .collection('staffDemoSites')
        .doc(siteId)
        .get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;

    final name = (data['name'] as String?)?.trim();
    final center = data['geofenceCenter'];
    final radius = data['geofenceRadiusMeters'];

    if (name == null || name.isEmpty) return null;
    if (center is! Map<String, dynamic>) return null;
    final lat = center['lat'];
    final lng = center['lng'];
    if (lat is! num || lng is! num) return null;
    if (radius is! num) return null;

    return StaffDemoSite(
      siteId: siteId,
      name: name,
      centerLat: lat.toDouble(),
      centerLng: lng.toDouble(),
      radiusMeters: radius.toDouble(),
    );
  }
}
