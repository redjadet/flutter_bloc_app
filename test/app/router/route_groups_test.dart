import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('createAuxiliaryRoutes', () {
    test('returns non-empty list of RouteBase', () {
      final List<RouteBase> routes = createAuxiliaryRoutes();
      expect(routes, isNotEmpty);
      expect(routes.every((final RouteBase r) => r is GoRoute), isTrue);
    });

    test('routes have correct path and name properties', () {
      final List<RouteBase> routes = createAuxiliaryRoutes();

      for (final RouteBase route in routes) {
        final GoRoute go = route as GoRoute;
        expect(go.path, isNotEmpty);
        expect(go.name, isNotNull);
      }
    });

    test('routes have builder functions', () {
      final List<RouteBase> routes = createAuxiliaryRoutes();

      for (final RouteBase route in routes) {
        final GoRoute go = route as GoRoute;
        expect(go.builder, isNotNull);
      }
    });
  });
}
