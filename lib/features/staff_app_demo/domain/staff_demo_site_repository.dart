import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';

abstract interface class StaffDemoSiteRepository {
  Future<List<StaffDemoSite>> listSites();
  Future<StaffDemoSite?> loadSite({required String siteId});
}
