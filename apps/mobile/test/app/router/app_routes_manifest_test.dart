import 'package:flutter_bloc_app/app/router/routes.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('app router manifests', () {
    test('createCoreRoutes returns non-empty GoRoute list', () {
      final routes = createCoreRoutes();
      expect(routes, isNotEmpty);
      expect(routes.every((final r) => r is GoRoute), isTrue);
    });

    test('createDemoRoutes returns non-empty route list', () {
      final routes = createDemoRoutes();
      expect(routes, isNotEmpty);
      expect(
        routes.every((final RouteBase r) => r is GoRoute || r is ShellRoute),
        isTrue,
      );
    });

    test('createAppRoutes composes core and demo routes', () {
      final routes = createAppRoutes();
      expect(routes.length, greaterThan(createCoreRoutes().length));
    });
  });
}
