import 'package:flutter_bloc_app/app/composition/app_composition_root.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/app/router/routes.dart';
import 'package:flutter_bloc_app/app/router/routes_case_study_demo.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/app/router/routes_staff_app_demo.dart';
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

  group('router shell manifests', () {
    test('createCaseStudyDemoShellRoute exposes nested routes', () {
      final ShellRoute shell = createCaseStudyDemoShellRoute(
        AppCompositionRoot.resolveDemoRouteFactory().caseStudyDemoRouteFactory,
      );
      expect(shell.routes, isNotEmpty);
      expect(shell.routes.every((r) => r is GoRoute), isTrue);
    });

    test('createStaffAppDemoShellRoute exposes nested routes', () {
      final ShellRoute shell = createStaffAppDemoShellRoute(
        AppCompositionRoot.resolveDemoRouteFactory().staffAppDemoRouteFactory,
      );
      expect(shell.routes, isNotEmpty);
      expect(shell.routes.every((r) => r is GoRoute), isTrue);
    });

    test('createDemoRoutes includes shell routes for staff and case study', () {
      final routes = createDemoRoutes(
        AppCompositionRoot.resolveDemoRouteFactory(),
      );
      expect(routes.any((RouteBase r) => r is ShellRoute), isTrue);
    });
  });

  group('core and auxiliary routes', () {
    test('createCoreRoutes includes calculator and settings routes', () {
      final routes = createCoreRoutes(
        AppCompositionRoot.resolveCoreRouteFactory(),
      );
      final paths = routes.whereType<GoRoute>().map((r) => r.path).toSet();
      final names = routes.whereType<GoRoute>().map((r) => r.name).toSet();
      expect(names, contains(AppRoutes.calculator));
      expect(paths, contains(AppRoutes.settingsPath));
    });

    test('createAuxiliaryRoutes includes search and todo paths', () {
      final routes = createAuxiliaryRoutes(
        AppCompositionRoot.resolveAuxiliaryRouteFactory(),
      );
      final names = routes.whereType<GoRoute>().map((r) => r.name).toSet();
      expect(names, contains(AppRoutes.search));
      expect(names, contains(AppRoutes.todoList));
      expect(names, contains(AppRoutes.walletconnectAuth));
    });

    test('createDemoRoutes includes chat and playlearn routes', () {
      final routes = createDemoRoutes(
        AppCompositionRoot.resolveDemoRouteFactory(),
      );
      final names = routes.whereType<GoRoute>().map((r) => r.name).toSet();
      expect(names, contains(AppRoutes.chat));
      expect(names, contains(AppRoutes.playlearn));
      expect(names, contains(AppRoutes.genuiDemo));
    });

    test('createAppRoutes includes counter home route', () {
      final routes = createAppRoutes(
        AppCompositionRoot.resolveRouteFactories(),
      );
      final names = routes.whereType<GoRoute>().map((r) => r.name).toSet();
      expect(names, contains(AppRoutes.counter));
    });
  });
}
