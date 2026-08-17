part of 'test_harness.dart';

bool _isUnexpectedIntegrationLog(AppLogEntry entry) {
  return test_harness_log_filtering.isUnexpectedIntegrationLog(
    entry,
    isWeb: kIsWeb,
  );
}
