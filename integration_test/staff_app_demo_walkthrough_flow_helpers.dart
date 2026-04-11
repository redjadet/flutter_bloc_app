import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

class FakeStaffDemoLocationService extends StaffDemoLocationService {
  FakeStaffDemoLocationService({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  @override
  Future<StaffDemoCapturedLocation?> captureCurrentLocation() async {
    return StaffDemoCapturedLocation(
      lat: lat,
      lng: lng,
      accuracyMeters: 12,
      capturedAtUtc: DateTime.now().toUtc(),
    );
  }
}

Future<void> openExamplePage(final WidgetTester tester) async {
  await launchTestApp(tester);
  tester
      .widget<AppScope>(find.byType(AppScope))
      .router
      .go(AppRoutes.examplePath);
  await tester.pump(const Duration(milliseconds: 100));
  await pumpUntilFound(tester, find.text('Example Page'));
}

Future<void> openStaffAppDemoFromExample(final WidgetTester tester) async {
  tester
      .widget<AppScope>(find.byType(AppScope))
      .router
      .go(
        AppRoutes.staffAppDemoPath,
      );
  await tester.pump(const Duration(milliseconds: 100));
  // Staff demo boot can take a bit longer on cold Firebase / iOS simulator.
  await pumpUntilFound(
    tester,
    find.text('Home'),
    timeout: const Duration(seconds: 15),
  );
}

Future<String> signInGetUid({
  required final String email,
  required final String password,
}) async {
  final creds = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  final uid = creds.user?.uid ?? '';
  if (uid.isEmpty) {
    throw StateError('Expected a Firebase user uid after sign-in.');
  }
  return uid;
}

Future<void> signOut() => FirebaseAuth.instance.signOut();

Uint8List buildDeterministicPngBytes() => Uint8List.fromList(<int>[
  137, 80, 78, 71, 13, 10, 26, 10, // PNG signature header
  0, 0, 0, 0,
]);
