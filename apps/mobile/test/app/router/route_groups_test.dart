import 'package:flutter_bloc_app/app/composition/app_composition_root.dart';
import 'package:flutter_bloc_app/app/router/route_groups.dart';
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

  group('createAuxiliaryRoutes', () {
    test('returns non-empty list of RouteBase', () {
      final List<RouteBase> routes = createAuxiliaryRoutes(
        AppCompositionRoot.resolveAuxiliaryRouteFactory(),
      );
      expect(routes, isNotEmpty);
      expect(routes.every((RouteBase r) => r is GoRoute), isTrue);
    });

    test('routes have correct path and name properties', () {
      final List<RouteBase> routes = createAuxiliaryRoutes(
        AppCompositionRoot.resolveAuxiliaryRouteFactory(),
      );

      for (final RouteBase route in routes) {
        final GoRoute go = route as GoRoute;
        expect(go.path, isNotEmpty);
        expect(go.name, isNotNull);
      }
    });

    test('routes have pageBuilder functions', () {
      final List<RouteBase> routes = createAuxiliaryRoutes(
        AppCompositionRoot.resolveAuxiliaryRouteFactory(),
      );

      for (final RouteBase route in routes) {
        final GoRoute go = route as GoRoute;
        expect(go.pageBuilder, isNotNull);
      }
    });
  });
}
