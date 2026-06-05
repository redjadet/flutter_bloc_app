import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/test_harness_log_filtering.dart'
    as test_harness_log_filtering;

void main() {
  group('test harness log filtering', () {
    test('ignores Hive key retrieval fallback on web only', () {
      const AppLogEntry hiveKeyError = AppLogEntry(
        level: AppLogLevel.error,
        message: 'HiveKeyManager.getEncryptionKey',
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
        message:
            'Failed to retrieve encryption key from secure storage, using temporary key (data will not persist across restarts).',
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
            'RemoteConfig.forceFetch disabled (Keychain unavailable). '
            'Apple debug/simulator unsigned builds cannot use Firebase Installations.',
      );
      const AppLogEntry keychainError = AppLogEntry(
        level: AppLogLevel.error,
        message: 'RemoteConfig.forceFetch',
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
      const AppLogEntry remoteConfigCancellation = AppLogEntry(
        level: AppLogLevel.error,
        message: 'OfflineFirstRemoteConfigRepository.forceFetch failed',
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
