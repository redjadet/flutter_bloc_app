import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/firebase_app_check_attestation_service_impl.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAppCheckAttestationServiceImpl', () {
    test('maps a non-null cached token to issued/ok', () async {
      final service = FirebaseAppCheckAttestationServiceImpl(
        tokenReader: ({required final forceRefresh}) async => 'cached-token',
      );

      final result = await service.probeCachedToken();

      expect(result.status, AppCheckAttestationStatus.issued);
      expect(result.reasonCode, 'ok');
    });

    test('never forces a token refresh', () async {
      bool? capturedForceRefresh;
      final service = FirebaseAppCheckAttestationServiceImpl(
        tokenReader: ({required final forceRefresh}) async {
          capturedForceRefresh = forceRefresh;
          return 'cached-token';
        },
      );

      await service.probeCachedToken();

      expect(capturedForceRefresh, isFalse);
    });

    test(
      'maps a null token to unavailable/not_configured_or_token_null',
      () async {
        final service = FirebaseAppCheckAttestationServiceImpl(
          tokenReader: ({required final forceRefresh}) async => null,
        );

        final result = await service.probeCachedToken();

        expect(result.status, AppCheckAttestationStatus.unavailable);
        expect(result.reasonCode, 'not_configured_or_token_null');
        expect(result.providerLabel, 'none');
      },
    );

    test(
      'maps an empty token to unavailable/not_configured_or_token_null',
      () async {
        final service = FirebaseAppCheckAttestationServiceImpl(
          tokenReader: ({required final forceRefresh}) async => '',
        );

        final result = await service.probeCachedToken();

        expect(result.status, AppCheckAttestationStatus.unavailable);
        expect(result.reasonCode, 'not_configured_or_token_null');
      },
    );

    test('maps a thrown error to failed/app_check_error', () async {
      final service = FirebaseAppCheckAttestationServiceImpl(
        tokenReader: ({required final forceRefresh}) async =>
            throw Exception('boom'),
      );

      final result = await service.probeCachedToken();

      expect(result.status, AppCheckAttestationStatus.failed);
      expect(result.reasonCode, 'app_check_error');
      expect(result.providerLabel, 'unknown');
    });

    test(
      'maps Firebase not-activated codes to unavailable/not_configured',
      () async {
        final service = FirebaseAppCheckAttestationServiceImpl(
          tokenReader: ({required final forceRefresh}) async =>
              throw FirebaseException(
                plugin: 'firebase_app_check',
                code: 'not-activated',
                message: 'should-never-surface',
              ),
        );

        final result = await service.probeCachedToken();

        expect(result.status, AppCheckAttestationStatus.unavailable);
        expect(result.reasonCode, 'not_configured_or_token_null');
        expect(result.toString(), isNot(contains('should-never-surface')));
      },
    );

    test('maps native App Check wrapper errors to setup-needed', () async {
      final service = FirebaseAppCheckAttestationServiceImpl(
        tokenReader: ({required final forceRefresh}) async =>
            throw PlatformException(
              code: 'firebase_app_check',
              message: 'should-never-surface',
            ),
      );

      final result = await service.probeCachedToken();

      expect(result.status, AppCheckAttestationStatus.unavailable);
      expect(result.reasonCode, 'not_configured_or_token_null');
      expect(result.toString(), isNot(contains('should-never-surface')));
    });

    test('never surfaces the token string itself in the result', () async {
      final service = FirebaseAppCheckAttestationServiceImpl(
        tokenReader: ({required final forceRefresh}) async =>
            'super-secret-token-value',
      );

      final result = await service.probeCachedToken();

      expect(result.toString(), isNot(contains('super-secret-token-value')));
    });
  });
}
