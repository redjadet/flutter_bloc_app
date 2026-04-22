// Contract tests: Firestore field shapes must match `functions/tool/seed_staff_demo.js`.
//
// Canonical payloads live in:
//   test/features/staff_app_demo/data/staff_demo_seed_document_fixtures.dart
//
// Run:
//   flutter test test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart
//
// Also executed via `tool/check_regression_guards.sh` (checklist focused guards).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_content_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_profile_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_shift_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_site_firestore_map.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_test/flutter_test.dart';

import 'staff_demo_seed_document_fixtures.dart';

void main() {
  group('staff demo seed vs Firestore mappers (contract)', () {
    test('staffDemoSites/site1 shape from seed_staff_demo.js parses', () {
      final site = staffDemoSiteFromFirestoreMap(
        siteId: kStaffDemoSeedSiteId,
        data: kStaffDemoSeedSite1Document,
      );
      expect(site, isNotNull);
      expect(site!.name, 'Demo Warehouse');
      expect(site.siteId, kStaffDemoSeedSiteId);
    });

    test('staffDemoContent/welcome_pdf shape from seed parses', () {
      final item = staffDemoContentItemFromFirestoreMap(
        contentId: kStaffDemoSeedWelcomePdfContentId,
        data: kStaffDemoSeedWelcomePdfDocument,
      );
      expect(item, isNotNull);
      expect(item!.title, 'Welcome (PDF)');
      expect(item.storagePath, 'staff-app-demo/content/welcome.pdf');
    });

    test(
      'staffDemoShifts/shift1 shape from seed parses when now in window',
      () {
        final startAt = DateTime.utc(2026, 6, 1, 10, 0);
        final endAt = DateTime.utc(2026, 6, 1, 20, 0);
        final nowUtc = DateTime.utc(2026, 6, 1, 15, 0);
        const employeeUid = 'seed_employee_uid_placeholder';
        final fixture = staffDemoSeedShift1Document(
          employeeUid: employeeUid,
          startAt: Timestamp.fromDate(startAt),
          endAt: Timestamp.fromDate(endAt),
        );
        final shift = staffDemoActiveShiftFromFirestoreDoc(
          shiftId: 'shift1',
          userId: employeeUid,
          data: fixture,
          nowUtc: nowUtc,
        );
        expect(shift, isNotNull);
        expect(shift!.siteId, kStaffDemoSeedSiteId);
        expect(shift.timezoneName, 'UTC');
      },
    );

    test(
      'staffDemoProfiles employee shape from seed parses for assignable list',
      () {
        const employeeUid = 'seed_employee_uid_placeholder';
        final profile = staffDemoProfileFromFirestoreDoc(
          userId: employeeUid,
          data: kStaffDemoSeedEmployeeProfileDocument,
          omitInactive: true,
        );
        expect(profile, isNotNull);
        expect(profile!.displayName, 'Staff Demo Employee');
        expect(profile.role, StaffDemoRole.employee);
        expect(profile.email, kStaffDemoSeedEmployeeEmail);
      },
    );
  });
}
