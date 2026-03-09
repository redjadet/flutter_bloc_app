import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('AppRoutes.isSafeRedirectPath', () {
    test('returns false for null or empty', () {
      expect(AppRoutes.isSafeRedirectPath(null), isFalse);
      expect(AppRoutes.isSafeRedirectPath(''), isFalse);
    });

    test('returns false for protocol-relative or external URLs', () {
      expect(AppRoutes.isSafeRedirectPath('//evil.com'), isFalse);
      expect(AppRoutes.isSafeRedirectPath('https://evil.com'), isFalse);
    });

    test('returns true for local paths', () {
      expect(AppRoutes.isSafeRedirectPath('/'), isTrue);
      expect(AppRoutes.isSafeRedirectPath('/iot-demo'), isTrue);
      expect(AppRoutes.isSafeRedirectPath('/supabase-auth'), isTrue);
    });
  });
}
