part of 'test_harness.dart';

bool _isUnexpectedIntegrationLog(final AppLogEntry entry) {
  return test_harness_log_filtering.isUnexpectedIntegrationLog(
    entry,
    isWeb: kIsWeb,
  );
}
