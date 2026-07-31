import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/fcm_log_redaction.dart';
import 'package:flutter_bloc_app/firebase_options.dart';

/// Top-level background message handler for FCM.
///
/// Must be registered with [FirebaseMessaging.onBackgroundMessage] before
/// the app is bootstrapped. Runs in a separate isolate; do not
/// access GetIt or Flutter bindings here.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(final RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FcmLogRedaction.logRemoteMessage(
      'fcm_background_message',
      message: message,
      source: 'background',
    );
  } on Object catch (error, stackTrace) {
    AppLogger.error('FCM background handler failed', error, stackTrace);
  }
}
