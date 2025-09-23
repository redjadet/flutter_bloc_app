import 'package:flutter_bloc_app/shared/utils/logger.dart';

class LoggingGuard {
  LoggingGuard._();

  static T withoutLogs<T>(T Function() action) {
    return AppLogger.silence(action);
  }

  static Future<T> withoutLogsAsync<T>(Future<T> Function() action) {
    return AppLogger.silenceAsync(action);
  }
}
