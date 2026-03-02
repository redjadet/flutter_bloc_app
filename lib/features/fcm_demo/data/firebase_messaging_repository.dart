import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Maps FCM [AuthorizationStatus] to domain [FcmPermissionState].
FcmPermissionState _mapPermissionState(final AuthorizationStatus status) {
  return switch (status) {
    AuthorizationStatus.authorized => FcmPermissionState.authorized,
    AuthorizationStatus.denied => FcmPermissionState.denied,
    AuthorizationStatus.notDetermined => FcmPermissionState.notDetermined,
    AuthorizationStatus.provisional => FcmPermissionState.provisional,
  };
}

/// Converts [RemoteMessage.data] to [Map<String, String>].
Map<String, String> _dataToStringMap(final Map<String, dynamic>? data) {
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
  final RemoteMessage message, {
  required final PushMessageSource source,
}) {
  final Map<String, String> dataMap = _dataToStringMap(message.data);
  final String? title =
      message.notification?.title ??
      (dataMap['title']?.isNotEmpty == true ? dataMap['title'] : null);
  final String? body =
      message.notification?.body ?? (dataMap['body']?.isNotEmpty == true ? dataMap['body'] : null);
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
    final FirebaseMessaging? messaging,
    final Stream<RemoteMessage>? foregroundMessages,
    final Stream<RemoteMessage>? openedMessages,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _foregroundMessages = foregroundMessages ?? FirebaseMessaging.onMessage,
       _openedMessages = openedMessages ?? FirebaseMessaging.onMessageOpenedApp;

  final FirebaseMessaging _messaging;
  final Stream<RemoteMessage> _foregroundMessages;
  final Stream<RemoteMessage> _openedMessages;

  @override
  Future<FcmPermissionState> requestPermission() async {
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
    AppLogger.debug(
      'FCM initial message (opened from notification): '
      'id=${push.messageId} title=${push.title} body=${push.body}',
    );
    return push;
  }

  @override
  Stream<PushMessage> get foregroundMessages => _foregroundMessages.map(
    (final m) {
      final PushMessage p = _toPushMessage(
        m,
        source: PushMessageSource.foreground,
      );
      AppLogger.debug(
        'FCM foreground message: id=${p.messageId} title=${p.title} '
        'body=${p.body}',
      );
      return p;
    },
  );

  @override
  Stream<PushMessage> get openedMessages => _openedMessages.map(
    (final m) {
      final PushMessage p = _toPushMessage(
        m,
        source: PushMessageSource.opened,
      );
      AppLogger.debug(
        'FCM opened-from-notification: id=${p.messageId} title=${p.title} '
        'body=${p.body}',
      );
      return p;
    },
  );

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;
}
