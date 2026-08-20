import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/composition/app_composition_root.dart';
import 'package:flutter_bloc_app/app/composition/features/register_certificate_pinning_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_http_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/routes_certificate_pinning_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/pages/certificate_pinning_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';

import '../../test_helpers.dart';

class _MockGoRouterState extends Mock implements GoRouterState {}

class _TestNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

void main() {
  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    await setupTestDependencies(
      const TestSetupOptions(
        useMockFirebaseAuth: true,
        useMockFirebasePlatform: true,
      ),
    );
    overrideTodoRepositoryForTests();
    FlavorManager.current = Flavor.dev;
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  test('createDemoRoutes includes certificate pinning demo route', () {
    final List<RouteBase> routes = createDemoRoutes(
      AppCompositionRoot.resolveDemoRouteFactory(),
    );
    expect(
      routes.any(
        (RouteBase r) =>
            r is GoRoute &&
            r.name == AppRoutes.certificatePinningDemo &&
            r.path == AppRoutes.certificatePinningDemoPath,
      ),
      isTrue,
    );
  });

  testWidgets('createCertificatePinningDemoRoute redirects in prod flavor', (
    WidgetTester tester,
  ) async {
    FlavorManager.current = Flavor.prod;
    addTearDown(() => FlavorManager.current = Flavor.dev);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    final BuildContext context = tester.element(find.byType(SizedBox));

    final GoRoute goRoute = createCertificatePinningDemoRoute(
      AppCompositionRoot.resolveDemoRouteFactory()
          .certificatePinningDemoRouteFactory,
    ) as GoRoute;
    final Object? redirect = goRoute.redirect!(context, _MockGoRouterState());
    expect(redirect, AppRoutes.counterPath);
  });

  testWidgets('createCertificatePinningDemoRoute allows non-prod debug', (
    WidgetTester tester,
  ) async {
    FlavorManager.current = Flavor.dev;

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    final BuildContext context = tester.element(find.byType(SizedBox));

    final GoRoute goRoute = createCertificatePinningDemoRoute(
      AppCompositionRoot.resolveDemoRouteFactory()
          .certificatePinningDemoRouteFactory,
    ) as GoRoute;
    final Object? redirect = goRoute.redirect!(context, _MockGoRouterState());
    expect(redirect, isNull);
  });

  testWidgets('createCertificatePinningDemoRoute builds demo page', (
    WidgetTester tester,
  ) async {
    if (!getIt.isRegistered<NetworkStatusService>()) {
      getIt.registerSingleton<NetworkStatusService>(
        _TestNetworkStatusService(),
      );
    }
    if (!getIt.isRegistered<TokenRepository>()) {
      getIt.registerSingleton<TokenRepository>(InMemoryTokenRepository());
    }
    if (!getIt.isRegistered<CertificatePinningConfig>()) {
      registerHttpServices();
      registerCertificatePinningDemoServices();
    }

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.certificatePinningDemoPath,
      routes: <RouteBase>[
        createCertificatePinningDemoRoute(
          AppCompositionRoot.resolveDemoRouteFactory()
              .certificatePinningDemoRouteFactory,
        ),
        GoRoute(
          path: AppRoutes.counterPath,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CertificatePinningDemoPage), findsOneWidget);
  });
}
