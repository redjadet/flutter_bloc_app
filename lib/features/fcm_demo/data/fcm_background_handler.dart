import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Top-level background message handler for FCM.
///
/// Must be registered with [FirebaseMessaging.onBackgroundMessage] before
/// the app is bootstrapped. Runs in a separate isolate; do not
/// access GetIt or Flutter bindings here.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(final RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    final String title = message.notification?.title ?? '(no title)';
    final String body = message.notification?.body ?? '(no body)';
    AppLogger.debug(
      'FCM background message: id=${message.messageId} title=$title body=$body',
    );
  } on Object catch (error, stackTrace) {
    AppLogger.error('FCM background handler failed', error, stackTrace);
  }
}
