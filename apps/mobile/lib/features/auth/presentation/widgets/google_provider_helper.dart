import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as firebase_ui_google;
import 'package:flutter/foundation.dart';

firebase_ui_google.GoogleProvider? maybeCreateGoogleProvider([
  FirebaseApp? app,
]) {
  try {
    if (Firebase.apps.isEmpty && app == null) {
      return null;
    }
    final FirebaseApp resolved = app ?? Firebase.app();
    final FirebaseOptions options = resolved.options;
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

    final String resolvedClientId = switch (platformClientId) {
      final id? when id.trim().isNotEmpty => id.trim(),
      _ => options.appId,
    };

    return firebase_ui_google.GoogleProvider(
      clientId: resolvedClientId,
      iOSPreferPlist: preferPlist,
    );
  } on Object {
    return null;
  }
}
