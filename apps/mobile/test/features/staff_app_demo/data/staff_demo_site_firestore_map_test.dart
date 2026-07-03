import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_site_firestore_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('staffDemoSiteFromFirestoreMap', () {
    test('parses nested geofenceCenter + geofenceRadiusMeters', () {
      final site = staffDemoSiteFromFirestoreMap(
        siteId: 'site1',
        data: <String, dynamic>{
          'name': ' Demo ',
          'geofenceCenter': <String, dynamic>{'lat': 1.5, 'lng': -2.5},
          'geofenceRadiusMeters': 100,
        },
      );
      expect(site, isNotNull);
      expect(site!.siteId, 'site1');
      expect(site.name, 'Demo');
      expect(site.centerLat, 1.5);
      expect(site.centerLng, -2.5);
      expect(site.radiusMeters, 100);
    });

    test(
      'nested map accepts radiusMeters when geofenceRadiusMeters absent',
      () {
        final site = staffDemoSiteFromFirestoreMap(
          siteId: 's',
          data: <String, dynamic>{
            'name': 'A',
            'geofenceCenter': <String, dynamic>{'lat': 1, 'lng': 2},
            'radiusMeters': 99,
          },
        );
        expect(site!.radiusMeters, 99);
      },
    );

    test('parses geofenceCenter as Firestore GeoPoint', () {
      final site = staffDemoSiteFromFirestoreMap(
        siteId: 'g1',
        data: <String, dynamic>{
          'name': 'Geo site',
          'geofenceCenter': const GeoPoint(10.25, -20.5),
          'geofenceRadiusMeters': 300,
        },
      );
      expect(site, isNotNull);
      expect(site!.centerLat, 10.25);
      expect(site.centerLng, -20.5);
      expect(site.radiusMeters, 300);
    });

    test('GeoPoint site accepts top-level radiusMeters', () {
      final site = staffDemoSiteFromFirestoreMap(
        siteId: 'g2',
        data: <String, dynamic>{
          'name': 'Geo site 2',
          'geofenceCenter': const GeoPoint(1, 2),
          'radiusMeters': 400,
        },
      );
      expect(site!.radiusMeters, 400);
    });

    test('parses flat centerLat, centerLng, radiusMeters (seed script)', () {
      final site = staffDemoSiteFromFirestoreMap(
        siteId: 'site1',
        data: <String, dynamic>{
          'name': 'Demo Warehouse',
          'centerLat': 43.6532,
          'centerLng': -79.3832,
          'radiusMeters': 250,
        },
      );
      expect(site, isNotNull);
      expect(site!.siteId, 'site1');
      expect(site.name, 'Demo Warehouse');
      expect(site.centerLat, 43.6532);
      expect(site.centerLng, -79.3832);
      expect(site.radiusMeters, 250);
    });

    test('returns null when name missing', () {
      expect(
        staffDemoSiteFromFirestoreMap(
          siteId: 'x',
          data: <String, dynamic>{
            'centerLat': 0,
            'centerLng': 0,
            'radiusMeters': 1,
          },
        ),
        isNull,
      );
    });

    test('nested shape wins when geofenceCenter is a map', () {
      final site = staffDemoSiteFromFirestoreMap(
        siteId: 's',
        data: <String, dynamic>{
          'name': 'A',
          'geofenceCenter': <String, dynamic>{'lat': 10, 'lng': 20},
          'geofenceRadiusMeters': 5,
          'centerLat': 99,
          'centerLng': 99,
          'radiusMeters': 99,
        },
      );
      expect(site!.centerLat, 10);
      expect(site.radiusMeters, 5);
    });
  });
}
