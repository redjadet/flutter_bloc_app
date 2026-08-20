import 'package:flutter_bloc_app/app/composition/app_composition_root.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test_helpers.dart';

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
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  test('createDemoRoutes includes IAP demo route', () {
    final List<RouteBase> routes = createDemoRoutes(
      AppCompositionRoot.resolveDemoRouteFactory(),
    );
    expect(
      routes.any(
        (RouteBase r) =>
            r is GoRoute &&
            r.name == AppRoutes.iapDemo &&
            r.path == AppRoutes.iapDemoPath,
      ),
      isTrue,
    );
  });

  test('createDemoRoutes includes Event Bus demo route', () {
    final List<RouteBase> routes = createDemoRoutes(
      AppCompositionRoot.resolveDemoRouteFactory(),
    );
    expect(
      routes.any(
        (RouteBase r) =>
            r is GoRoute &&
            r.name == AppRoutes.eventBusDemo &&
            r.path == AppRoutes.eventBusDemoPath,
      ),
      isTrue,
    );
  });

  test('createDemoRoutes includes Native Platform Showcase route', () {
    final List<RouteBase> routes = createDemoRoutes(
      AppCompositionRoot.resolveDemoRouteFactory(),
    );
    expect(
      routes.any(
        (RouteBase r) =>
            r is GoRoute &&
            r.name == AppRoutes.nativePlatformShowcase &&
            r.path == AppRoutes.nativePlatformShowcasePath,
      ),
      isTrue,
    );
  });
}
