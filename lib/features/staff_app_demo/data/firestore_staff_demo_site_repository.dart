import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_site_firestore_map.dart';
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
      final parsed = staffDemoSiteFromFirestoreMap(
        siteId: doc.id,
        data: data,
      );
      if (parsed != null) {
        sites.add(parsed);
      }
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
    return staffDemoSiteFromFirestoreMap(siteId: siteId, data: data);
  }
}
