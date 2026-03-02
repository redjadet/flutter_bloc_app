import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';

/// Domain contract for FCM: permission, token, and message streams.
abstract class FcmMessagingService {
  /// Request notification permission. Returns current permission state.
  Future<FcmPermissionState> requestPermission();

  /// Get current FCM registration token, or null if unavailable.
  Future<String?> getToken();

  /// Get APNs token (Apple only); null on other platforms or when unavailable.
  Future<String?> getApnsToken();

  /// Message that launched the app from terminated state, if any.
  Future<PushMessage?> getInitialMessage();

  /// Stream of messages received while app is in foreground.
  Stream<PushMessage> get foregroundMessages;

  /// Stream of messages that opened the app from background (user tapped).
  Stream<PushMessage> get openedMessages;

  /// Stream of new FCM tokens when refreshed.
  Stream<String> get tokenRefreshes;
}
