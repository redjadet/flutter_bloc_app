import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('createDemoRoutes includes IAP demo route', () {
    final List<RouteBase> routes = createDemoRoutes();
    expect(
      routes.any(
        (final RouteBase r) =>
            r is GoRoute &&
            r.name == AppRoutes.iapDemo &&
            r.path == AppRoutes.iapDemoPath,
      ),
      isTrue,
    );
  });
}
