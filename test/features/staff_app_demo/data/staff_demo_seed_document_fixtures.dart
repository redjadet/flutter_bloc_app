// Canonical Firestore field payloads for `npm --prefix functions run seed:staff-demo`.
//
// **Single Dart source of truth** for contract tests. When you change
// `functions/tool/seed_staff_demo.js`, update this file in the same PR and
// run:
//   flutter test test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Document id written by the seed for the demo site.
const String kStaffDemoSeedSiteId = 'site1';

/// `staffDemoSites/site1` merge payload (numeric fields match seed literals).
const Map<String, dynamic> kStaffDemoSeedSite1Document = <String, dynamic>{
  'name': 'Demo Warehouse',
  'centerLat': 43.6532,
  'centerLng': -79.3832,
  'radiusMeters': 250,
  'geofenceCenter': <String, dynamic>{'lat': 43.6532, 'lng': -79.3832},
  'geofenceRadiusMeters': 250,
};

/// `staffDemoContent/welcome_pdf` merge payload.
const String kStaffDemoSeedWelcomePdfContentId = 'welcome_pdf';

const Map<String, dynamic> kStaffDemoSeedWelcomePdfDocument = <String, dynamic>{
  'title': 'Welcome (PDF)',
  'type': 'pdf',
  'storagePath': 'staff-app-demo/content/welcome.pdf',
  'isPublished': true,
};

/// Employee profile fields (doc id is the Auth uid; use a placeholder in tests).
const String kStaffDemoSeedEmployeeEmail = 'staffdemo.employee@example.com';

const Map<String, dynamic> kStaffDemoSeedEmployeeProfileDocument =
    <String, dynamic>{
      'displayName': 'Staff Demo Employee',
      'email': kStaffDemoSeedEmployeeEmail,
      'role': 'employee',
      'isActive': true,
    };

/// `staffDemoShifts/shift1`-shaped document (timestamps are caller-provided).
Map<String, dynamic> staffDemoSeedShift1Document({
  required final String employeeUid,
  required final Timestamp startAt,
  required final Timestamp endAt,
}) => <String, dynamic>{
  'userId': employeeUid,
  'siteId': kStaffDemoSeedSiteId,
  'startAt': startAt,
  'endAt': endAt,
  'timezoneName': 'UTC',
  'status': 'assigned',
};
