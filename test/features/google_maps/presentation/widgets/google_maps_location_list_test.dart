import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_coordinate.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_location_list.dart';

void main() {
  group('GoogleMapsLocationList', () {
    final List<MapLocation> mockLocations = [
      MapLocation(
        id: '1',
        title: 'Location 1',
        description: 'Description 1',
        coordinate: const MapCoordinate(latitude: 0.0, longitude: 0.0),
      ),
      MapLocation(
        id: '2',
        title: 'Location 2',
        description: 'Description 2',
        coordinate: const MapCoordinate(latitude: 1.0, longitude: 1.0),
      ),
    ];

    MapLocation? focusedLocation;

    Widget buildSubject({
      List<MapLocation>? locations,
      String? selectedMarkerId,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GoogleMapsLocationList(
            locations: locations ?? mockLocations,
            selectedMarkerId: selectedMarkerId,
            emptyLabel: 'No locations',
            heading: 'Locations',
            focusLabel: 'Focus',
            selectedBadgeLabel: 'Selected',
            onFocus: (location) {
              focusedLocation = location;
            },
          ),
        ),
      );
    }

    setUp(() {
      focusedLocation = null;
    });

    testWidgets('renders heading', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Locations'), findsOneWidget);
    });

    testWidgets('displays empty message when no locations', (tester) async {
      await tester.pumpWidget(buildSubject(locations: []));
      await tester.pumpAndSettle();

      expect(find.text('No locations'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays location cards', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Location 1'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Location 2'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
    });

    testWidgets('shows selected badge for selected location', (tester) async {
      await tester.pumpWidget(buildSubject(selectedMarkerId: '1'));
      await tester.pumpAndSettle();

      expect(find.text('Selected'), findsOneWidget);
    });

    testWidgets('does not show selected badge for unselected location', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(selectedMarkerId: '2'));
      await tester.pumpAndSettle();

      // Only one location should have the badge
      expect(find.text('Selected'), findsOneWidget);
    });

    testWidgets('calls onFocus when location is tapped', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Location 1'));
      await tester.pumpAndSettle();

      expect(focusedLocation, equals(mockLocations[0]));
    });

    testWidgets('calls onFocus when focus button is tapped', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Focus').first);
      await tester.pumpAndSettle();

      expect(focusedLocation, isNotNull);
    });

    testWidgets('renders focus buttons for all locations', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Focus'), findsNWidgets(2));
    });
  });
}
