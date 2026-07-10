import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
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

    group('showChatBackendDisabledBanner', () {
      test('is false when not in web no-backend mode', () {
        const BackendAvailability availability = BackendAvailability(
          firebaseInitialized: false,
          supabaseInitialized: false,
          webNoBackendMode: false,
          allowWebLocalGuestAuth: false,
          allowLocalChatFallback: false,
        );

        expect(availability.showChatBackendDisabledBanner, isFalse);
      });

      test('is true when web no-backend mode and Firebase missing', () {
        const BackendAvailability availability = BackendAvailability(
          firebaseInitialized: false,
          supabaseInitialized: true,
          webNoBackendMode: true,
          allowWebLocalGuestAuth: true,
          allowLocalChatFallback: true,
        );

        expect(availability.showChatBackendDisabledBanner, isTrue);
      });

      test('is true when web no-backend mode and Supabase missing', () {
        const BackendAvailability availability = BackendAvailability(
          firebaseInitialized: true,
          supabaseInitialized: false,
          webNoBackendMode: true,
          allowWebLocalGuestAuth: true,
          allowLocalChatFallback: true,
        );

        expect(availability.showChatBackendDisabledBanner, isTrue);
      });

      test('is false when web no-backend mode and both backends ready', () {
        const BackendAvailability availability = BackendAvailability(
          firebaseInitialized: true,
          supabaseInitialized: true,
          webNoBackendMode: true,
          allowWebLocalGuestAuth: true,
          allowLocalChatFallback: true,
        );

        expect(availability.showChatBackendDisabledBanner, isFalse);
      });
    });

    group('showIotCloudBackendDisabledBanner', () {
      test('is false when not in web no-backend mode', () {
        const BackendAvailability availability = BackendAvailability(
          firebaseInitialized: true,
          supabaseInitialized: false,
          webNoBackendMode: false,
          allowWebLocalGuestAuth: false,
          allowLocalChatFallback: false,
        );

        expect(availability.showIotCloudBackendDisabledBanner, isFalse);
      });

      test('is true when web no-backend mode and Supabase missing', () {
        const BackendAvailability availability = BackendAvailability(
          firebaseInitialized: true,
          supabaseInitialized: false,
          webNoBackendMode: true,
          allowWebLocalGuestAuth: true,
          allowLocalChatFallback: true,
        );

        expect(availability.showIotCloudBackendDisabledBanner, isTrue);
      });

      test('is false when web no-backend mode and Supabase ready', () {
        const BackendAvailability availability = BackendAvailability(
          firebaseInitialized: true,
          supabaseInitialized: true,
          webNoBackendMode: true,
          allowWebLocalGuestAuth: true,
          allowLocalChatFallback: true,
        );

        expect(availability.showIotCloudBackendDisabledBanner, isFalse);
      });
    });
  });
}
