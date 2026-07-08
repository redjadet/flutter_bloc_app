import 'package:app_shared_flutter/app_shared_flutter.dart';

class LoggingGuard {
  LoggingGuard._();

  static T withoutLogs<T>(T Function() action) {
    return AppLogger.silence(action);
  }

  static Future<T> withoutLogsAsync<T>(Future<T> Function() action) {
    return AppLogger.silenceAsync(action);
  }
}
