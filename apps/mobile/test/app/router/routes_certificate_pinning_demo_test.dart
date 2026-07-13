import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/composition/features/register_certificate_pinning_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_http_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/routes_certificate_pinning_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/pages/certificate_pinning_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';

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
  setUp(() async {
    await getIt.reset(dispose: true);
    FlavorManager.current = Flavor.dev;
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test('createDemoRoutes includes certificate pinning demo route', () {
    final List<RouteBase> routes = createDemoRoutes();
    expect(
      routes.any(
        (final RouteBase r) =>
            r is GoRoute &&
            r.name == AppRoutes.certificatePinningDemo &&
            r.path == AppRoutes.certificatePinningDemoPath,
      ),
      isTrue,
    );
  });

  testWidgets('createCertificatePinningDemoRoute redirects in prod flavor', (
    final WidgetTester tester,
  ) async {
    FlavorManager.current = Flavor.prod;
    addTearDown(() => FlavorManager.current = Flavor.dev);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    final BuildContext context = tester.element(find.byType(SizedBox));

    final GoRoute goRoute = createCertificatePinningDemoRoute() as GoRoute;
    final Object? redirect = goRoute.redirect!(context, _MockGoRouterState());
    expect(redirect, AppRoutes.counterPath);
  });

  testWidgets('createCertificatePinningDemoRoute allows non-prod debug', (
    final WidgetTester tester,
  ) async {
    FlavorManager.current = Flavor.dev;

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    final BuildContext context = tester.element(find.byType(SizedBox));

    final GoRoute goRoute = createCertificatePinningDemoRoute() as GoRoute;
    final Object? redirect = goRoute.redirect!(context, _MockGoRouterState());
    expect(redirect, isNull);
  });

  testWidgets('createCertificatePinningDemoRoute builds demo page', (
    final WidgetTester tester,
  ) async {
    getIt.registerSingleton<NetworkStatusService>(_TestNetworkStatusService());
    getIt.registerSingleton<TokenRepository>(InMemoryTokenRepository());
    registerHttpServices();
    registerCertificatePinningDemoServices();

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.certificatePinningDemoPath,
      routes: <RouteBase>[
        createCertificatePinningDemoRoute(),
        GoRoute(
          path: AppRoutes.counterPath,
          builder: (final context, final state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CertificatePinningDemoPage), findsOneWidget);
  });
}
