import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';

/// Redacted FCM logging helpers — never log title, body, data values, or tokens.
abstract final class FcmLogRedaction {
  static Map<String, Object?> summaryFromPushMessage(
    final PushMessage message,
  ) => <String, Object?>{
    'source': message.source.name,
    'hasMessageId': message.messageId.isNotEmpty,
    'hasTitle': message.title?.isNotEmpty ?? false,
    'hasBody': message.body?.isNotEmpty ?? false,
    'dataKeyCount': message.data.length,
  };

  static Map<String, Object?> summaryFromRemoteMessage(
    final RemoteMessage message, {
    required final String source,
  }) {
    final String? title = message.notification?.title;
    final String? body = message.notification?.body;
    return <String, Object?>{
      'source': source,
      'hasMessageId': (message.messageId?.isNotEmpty ?? false),
      'hasTitle': title?.isNotEmpty ?? false,
      'hasBody': body?.isNotEmpty ?? false,
      'dataKeyCount': message.data.length,
    };
  }

  static void logPushMessage(
    final String event, {
    required final PushMessage message,
  }) {
    AppLogger.event(
      AppLogLevel.debug,
      event,
      fields: summaryFromPushMessage(message),
    );
  }

  static void logRemoteMessage(
    final String event, {
    required final RemoteMessage message,
    required final String source,
  }) {
    AppLogger.event(
      AppLogLevel.debug,
      event,
      fields: summaryFromRemoteMessage(message, source: source),
    );
  }
}
