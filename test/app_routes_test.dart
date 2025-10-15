import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppRoutes exposes expected route names', () {
    expect(AppRoutes.counterPath, '/');
    expect(AppRoutes.settingsPath, '/settings');
    expect(AppRoutes.graphqlPath, '/graphql-demo');
  });
}
