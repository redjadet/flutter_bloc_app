import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('createAuxiliaryRoutes', () {
    test('returns list of GoRoute instances', () {
      final routes = createAuxiliaryRoutes();
      expect(routes, isA<List<GoRoute>>());
      expect(routes, isNotEmpty);
    });

    test('routes have correct path and name properties', () {
      final routes = createAuxiliaryRoutes();

      // Check that routes have paths and names set
      for (final route in routes) {
        expect(route.path, isNotEmpty);
        expect(route.name, isNotNull);
      }
    });

    test('routes have builder functions', () {
      final routes = createAuxiliaryRoutes();

      // Check that all routes have builders
      for (final route in routes) {
        expect(route.builder, isNotNull);
      }
    });
  });
}
