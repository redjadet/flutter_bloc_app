import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/routes_online_therapy_demo.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('landing → client hub → therapists list works', (tester) async {
    final api = OnlineTherapyFakeApi();

    getIt.registerSingleton<OnlineTherapyFakeApi>(api);
    getIt.registerSingleton<TherapyAuthRepository>(
      FakeTherapyAuthRepository(api: api),
    );
    getIt.registerSingleton<TherapistRepository>(
      FakeTherapistRepository(api: api),
    );
    getIt.registerSingleton<AppointmentRepository>(
      FakeAppointmentRepository(api: api),
    );
    getIt.registerSingleton<TherapyMessagingRepository>(
      FakeTherapyMessagingRepository(api: api),
    );
    getIt.registerSingleton<TherapyCallRepository>(
      FakeTherapyCallRepository(api: api),
    );
    getIt.registerSingleton<TherapyAdminRepository>(
      FakeTherapyAdminRepository(api: api),
    );
    getIt.registerSingleton<AuditRepository>(FakeAuditRepository(api: api));
    addTearDown(() async {
      await getIt.reset();
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: AppRoutes.onlineTherapyDemoPath,
          routes: <RouteBase>[createOnlineTherapyDemoRoute()],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'demo@example.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Client flow'));
    await tester.pumpAndSettle();
    expect(find.text('Client — Therapy demo'), findsOneWidget);

    await tester.tap(find.text('Therapists'));
    await tester.pumpAndSettle();
    expect(find.text('Therapists'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
