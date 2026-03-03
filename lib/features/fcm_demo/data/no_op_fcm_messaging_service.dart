import 'dart:async';

import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';

/// No-op [FcmMessagingService] when Firebase is not initialized (e.g. placeholder
/// config, web, or unsupported platform). Allows the FCM demo page to load
/// without crashing; UI can show "Firebase not available" or similar.
class NoOpFcmMessagingService implements FcmMessagingService {
  @override
  Future<FcmPermissionState> requestPermission() async =>
      FcmPermissionState.notDetermined;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<String?> getApnsToken() async => null;

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Stream<PushMessage> get foregroundMessages =>
      const Stream<PushMessage>.empty();

  @override
  Stream<PushMessage> get openedMessages => const Stream<PushMessage>.empty();

  @override
  Stream<String> get tokenRefreshes => const Stream<String>.empty();
}
