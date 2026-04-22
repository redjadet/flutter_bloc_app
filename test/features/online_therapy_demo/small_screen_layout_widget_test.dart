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
  testWidgets('online therapy demo has no overflow on small iPhone screens', (
    tester,
  ) async {
    final originalOnError = FlutterError.onError;
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      errors.add(details);
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });

    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(320 * 2, 568 * 2);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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
    if (errors.isNotEmpty) {
      fail(
        errors
            .map((e) => '${e.exceptionAsString()}\n${e.context}\n${e.library}')
            .join('\n\n'),
      );
    }

    // Login
    await tester.enterText(find.byType(TextField), 'demo@example.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    if (errors.isNotEmpty) {
      fail(
        errors
            .map((e) => '${e.exceptionAsString()}\n${e.context}\n${e.library}')
            .join('\n\n'),
      );
    }

    // Navigate through a few screens to catch overflow regressions.
    await tester.tap(find.text('Therapist flow'));
    await tester.pumpAndSettle();
    expect(find.text('Therapist — Therapy demo'), findsOneWidget);

    await tester.tap(find.text('Appointments'));
    await tester.pumpAndSettle();
    expect(find.text('Appointments'), findsOneWidget);
    if (errors.isNotEmpty) {
      fail(
        errors
            .map((e) => '${e.exceptionAsString()}\n${e.context}\n${e.library}')
            .join('\n\n'),
      );
    }

    // Scroll down a bit to exercise long content on short screens.
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    if (errors.isNotEmpty) {
      fail(
        errors
            .map((e) => '${e.exceptionAsString()}\n${e.context}\n${e.library}')
            .join('\n\n'),
      );
    }

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Messaging'));
    await tester.pumpAndSettle();
    expect(find.text('Messaging'), findsOneWidget);
    if (errors.isNotEmpty) {
      fail(
        errors
            .map((e) => '${e.exceptionAsString()}\n${e.context}\n${e.library}')
            .join('\n\n'),
      );
    }
  });
}
