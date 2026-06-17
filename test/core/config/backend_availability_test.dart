import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/config/backend_availability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendAvailability', () {
    test('fromBootstrap mirrors platform policy flags', () {
      final BackendAvailability availability =
          BackendAvailability.fromBootstrap();

      expect(availability.webNoBackendMode, kIsWeb);
      expect(availability.allowWebLocalGuestAuth, kIsWeb);
      expect(availability.allowLocalChatFallback, kIsWeb);
    });

    test('exposes bootstrap readiness flags', () {
      final BackendAvailability availability = const BackendAvailability(
        firebaseInitialized: true,
        supabaseInitialized: false,
        webNoBackendMode: true,
        allowWebLocalGuestAuth: true,
        allowLocalChatFallback: true,
      );

      expect(availability.firebaseInitialized, isTrue);
      expect(availability.supabaseInitialized, isFalse);
    });
  });
}
