import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/fcm_log_redaction.dart';
import 'package:utilities/utilities.dart';

/// Maps FCM [AuthorizationStatus] to domain [FcmPermissionState].
FcmPermissionState _mapPermissionState(AuthorizationStatus status) {
  return switch (status) {
    AuthorizationStatus.authorized => FcmPermissionState.authorized,
    AuthorizationStatus.denied => FcmPermissionState.denied,
    AuthorizationStatus.notDetermined => FcmPermissionState.notDetermined,
    AuthorizationStatus.provisional => FcmPermissionState.provisional,
  };
}

/// Converts [RemoteMessage.data] to [Map<String, String>].
Map<String, String> _dataToStringMap(Map<String, dynamic>? data) {
  if (data == null || data.isEmpty) return const {};
  final Map<String, String> result = {};
  for (final MapEntry<String, dynamic> e in data.entries) {
    result[e.key] = e.value?.toString() ?? '';
  }
  return result;
}

/// Converts [RemoteMessage] to [PushMessage].
/// Uses notification.title/body when present; falls back to data['title']/data['body']
/// so simulator .apns payloads (which may not set notification) still show in UI.
PushMessage _toPushMessage(
  RemoteMessage message, {
  required PushMessageSource source,
}) {
  final Map<String, String> dataMap = _dataToStringMap(message.data);
  final String? title =
      message.notification?.title ??
      (dataMap['title']?.isNotEmpty == true ? dataMap['title'] : null);
  final String? body =
      message.notification?.body ??
      (dataMap['body']?.isNotEmpty == true ? dataMap['body'] : null);
  return PushMessage(
    messageId: message.messageId ?? '',
    title: title,
    body: body,
    sentTime: message.sentTime,
    data: dataMap,
    source: source,
  );
}

/// FCM implementation of [FcmMessagingService].
class FirebaseMessagingRepository implements FcmMessagingService {
  FirebaseMessagingRepository({
    FirebaseMessaging? messaging,
    Stream<RemoteMessage>? foregroundMessages,
    Stream<RemoteMessage>? openedMessages,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _foregroundMessages = foregroundMessages ?? FirebaseMessaging.onMessage,
       _openedMessages = openedMessages ?? FirebaseMessaging.onMessageOpenedApp;

  final FirebaseMessaging _messaging;
  final Stream<RemoteMessage> _foregroundMessages;
  final Stream<RemoteMessage> _openedMessages;

  @override
  Future<FcmPermissionState> requestPermission() async {
    final NotificationSettings current = await _messaging
        .getNotificationSettings();
    final AuthorizationStatus status = current.authorizationStatus;
    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional ||
        status == AuthorizationStatus.denied) {
      // Do not re-prompt after the OS has a determined answer.
      return _mapPermissionState(status);
    }
    final NotificationSettings settings = await _messaging.requestPermission();
    return _mapPermissionState(settings.authorizationStatus);
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } on Exception catch (error, stackTrace) {
      AppLogger.error('FCM getToken failed', error, stackTrace);
      return null;
    }
  }

  @override
  Future<String?> getApnsToken() async {
    try {
      return await _messaging.getAPNSToken();
    } on Exception catch (error, stackTrace) {
      AppLogger.error('FCM getAPNSToken failed', error, stackTrace);
      return null;
    }
  }

  @override
  Future<PushMessage?> getInitialMessage() async {
    final RemoteMessage? message = await _messaging.getInitialMessage();
    if (message == null) return null;
    final PushMessage push = _toPushMessage(
      message,
      source: PushMessageSource.initial,
    );
    FcmLogRedaction.logPushMessage(
      'fcm_initial_message',
      message: push,
    );
    return push;
  }

  @override
  Stream<PushMessage> get foregroundMessages => _foregroundMessages.map(
    (m) {
      final PushMessage p = _toPushMessage(
        m,
        source: PushMessageSource.foreground,
      );
      FcmLogRedaction.logPushMessage(
        'fcm_foreground_message',
        message: p,
      );
      return p;
    },
  );

  @override
  Stream<PushMessage> get openedMessages => _openedMessages.map(
    (m) {
      final PushMessage p = _toPushMessage(
        m,
        source: PushMessageSource.opened,
      );
      FcmLogRedaction.logPushMessage(
        'fcm_opened_message',
        message: p,
      );
      return p;
    },
  );

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;
}
