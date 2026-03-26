import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('createDemoRoutes includes IAP demo route', () {
    final routes = createDemoRoutes();
    expect(
      routes.any(
        (r) => r.name == AppRoutes.iapDemo && r.path == AppRoutes.iapDemoPath,
      ),
      isTrue,
    );
  });
}
