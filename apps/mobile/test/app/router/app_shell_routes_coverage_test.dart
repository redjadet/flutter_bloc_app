import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/app/router/routes_case_study_demo.dart';
import 'package:flutter_bloc_app/app/router/routes.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/app/router/routes_staff_app_demo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('router shell manifests', () {
    test('createCaseStudyDemoShellRoute exposes nested routes', () {
      final ShellRoute shell = createCaseStudyDemoShellRoute();
      expect(shell.routes, isNotEmpty);
      expect(shell.routes.every((final r) => r is GoRoute), isTrue);
    });

    test('createStaffAppDemoShellRoute exposes nested routes', () {
      final ShellRoute shell = createStaffAppDemoShellRoute();
      expect(shell.routes, isNotEmpty);
      expect(shell.routes.every((final r) => r is GoRoute), isTrue);
    });

    test('createDemoRoutes includes shell routes for staff and case study', () {
      final routes = createDemoRoutes();
      expect(routes.any((final RouteBase r) => r is ShellRoute), isTrue);
    });
  });

  group('core and auxiliary routes', () {
    test('createCoreRoutes includes calculator and settings routes', () {
      final routes = createCoreRoutes();
      final paths = routes
          .whereType<GoRoute>()
          .map((final r) => r.path)
          .toSet();
      final names = routes
          .whereType<GoRoute>()
          .map((final r) => r.name)
          .toSet();
      expect(names, contains(AppRoutes.calculator));
      expect(paths, contains(AppRoutes.settingsPath));
    });

    test('createAuxiliaryRoutes includes search and todo paths', () {
      final routes = createAuxiliaryRoutes();
      final names = routes
          .whereType<GoRoute>()
          .map((final r) => r.name)
          .toSet();
      expect(names, contains(AppRoutes.search));
      expect(names, contains(AppRoutes.todoList));
      expect(names, contains(AppRoutes.walletconnectAuth));
    });

    test('createDemoRoutes includes chat and playlearn routes', () {
      final routes = createDemoRoutes();
      final names = routes
          .whereType<GoRoute>()
          .map((final r) => r.name)
          .toSet();
      expect(names, contains(AppRoutes.chat));
      expect(names, contains(AppRoutes.playlearn));
      expect(names, contains(AppRoutes.genuiDemo));
    });

    test('createAppRoutes includes counter home route', () {
      final routes = createAppRoutes();
      final names = routes
          .whereType<GoRoute>()
          .map((final r) => r.name)
          .toSet();
      expect(names, contains(AppRoutes.counter));
    });
  });
}
