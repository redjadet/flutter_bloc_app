import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_app/core/router/app_routes.dart';

void main() {
  test('AppRoutes exposes stable names and paths', () {
    expect(AppRoutes.counter, 'counter');
    expect(AppRoutes.counterPath, '/');
    expect(AppRoutes.example, 'example');
    expect(AppRoutes.examplePath, '/example');
    expect(AppRoutes.settings, 'settings');
    expect(AppRoutes.settingsPath, '/settings');
    expect(AppRoutes.chat, 'chat');
    expect(AppRoutes.chatPath, '/chat');
    expect(AppRoutes.profile, 'profile');
    expect(AppRoutes.profilePath, '/profile');
    expect(AppRoutes.manageAccount, 'manage-account');
    expect(AppRoutes.manageAccountPath, '/manage-account');
  });
}
