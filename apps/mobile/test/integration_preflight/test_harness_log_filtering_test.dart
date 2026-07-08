@TestOn('vm')
library;

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/test_harness_log_filtering.dart'
    as test_harness_log_filtering;

void main() {
  group('test harness log filtering', () {
    test('ignores Hive key retrieval fallback on web only', () {
      const AppLogEntry hiveKeyError = AppLogEntry(
        level: AppLogLevel.error,
        message: IntegrationLogMessages.hiveKeyManagerGetEncryptionKey,
        error: 'OperationError',
      );

      expect(
        test_harness_log_filtering.isIgnoredIntegrationLog(
          hiveKeyError,
          isWeb: true,
        ),
        isTrue,
      );
      expect(
        test_harness_log_filtering.isIgnoredIntegrationLog(
          hiveKeyError,
          isWeb: false,
        ),
        isFalse,
      );
    });

    test('ignores temporary in-memory Hive key warning on web only', () {
      const AppLogEntry temporaryKeyWarning = AppLogEntry(
        level: AppLogLevel.warning,
        message: IntegrationLogMessages.hiveEncryptionKeyFallback,
      );

      expect(
        test_harness_log_filtering.isIgnoredIntegrationLog(
          temporaryKeyWarning,
          isWeb: true,
        ),
        isTrue,
      );
      expect(
        test_harness_log_filtering.isIgnoredIntegrationLog(
          temporaryKeyWarning,
          isWeb: false,
        ),
        isFalse,
      );
    });

    test('ignores Apple debug Remote Config Keychain noise', () {
      const AppLogEntry keychainWarning = AppLogEntry(
        level: AppLogLevel.warning,
        message:
            '${IntegrationLogMessages.remoteConfigForceFetchDisabledPrefix}. '
            'Apple debug/simulator unsigned builds cannot use Firebase Installations.',
      );
      const AppLogEntry keychainError = AppLogEntry(
        level: AppLogLevel.error,
        message: IntegrationLogMessages.remoteConfigForceFetch,
        error:
            '[firebase_remote_config/unknown] Failed to get installations token. '
            'SecItemCopyMatching (-34018)',
      );

      expect(
        test_harness_log_filtering.isIgnoredIntegrationLog(
          keychainWarning,
          isWeb: false,
        ),
        isTrue,
      );
      expect(
        test_harness_log_filtering.isIgnoredIntegrationLog(
          keychainError,
          isWeb: false,
        ),
        isTrue,
      );
    });

    test('still ignores known remote config cancellation noise', () {
      final AppLogEntry remoteConfigCancellation = AppLogEntry(
        level: AppLogLevel.error,
        message: IntegrationLogMessages.offlineFirstRemoteConfigFetchFailed(
          'forceFetch',
        ),
        error: '[firebase_remote_config/unknown] cancelled',
      );

      expect(
        test_harness_log_filtering.isUnexpectedIntegrationLog(
          remoteConfigCancellation,
          isWeb: false,
        ),
        isFalse,
      );
    });
  });
}
