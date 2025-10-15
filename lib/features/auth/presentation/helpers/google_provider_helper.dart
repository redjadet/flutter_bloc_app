import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as firebase_ui_google;
import 'package:flutter/foundation.dart';

firebase_ui_google.GoogleProvider? maybeCreateGoogleProvider([
  FirebaseApp? app,
]) {
  app ??= Firebase.app();
  if (Firebase.apps.isEmpty) {
    return null;
  }

  try {
    final FirebaseApp app = Firebase.app();
    final FirebaseOptions options = app.options;
    final TargetPlatform platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return null;
    }

    final bool isIOS = platform == TargetPlatform.iOS;
    final String? platformClientId = isIOS
        ? options.iosClientId
        : options.androidClientId;
    final bool preferPlist =
        isIOS && (platformClientId?.trim().isEmpty ?? true);

    final String resolvedClientId =
        (platformClientId?.trim().isNotEmpty ?? false)
        ? platformClientId!.trim()
        : options.appId;

    return firebase_ui_google.GoogleProvider(
      clientId: resolvedClientId,
      iOSPreferPlist: preferPlist,
    );
  } on FirebaseException {
    return null;
  } on Exception {
    return null;
  }
}
