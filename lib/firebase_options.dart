// Generated from existing Firebase config (firebase.json + platform files).
// Replace with output of `flutterfire configure` when the CLI works.
// Do not commit if it contains real keys (add to .gitignore if needed).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '${defaultTargetPlatform.name}.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSBEGL3Equmr1XgecC3FYUi93Y8cwZIsU',
    appId: '1:473097776453:android:80db6a1c2b04bfc0bd222c',
    messagingSenderId: '473097776453',
    projectId: 'flutter-bloc-app-697e8',
    storageBucket: 'flutter-bloc-app-697e8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2IG7veUZBqGnpQeVWM-9Z89kj_3wSqYc',
    appId: '1:473097776453:ios:6962f6ddc4d7ea12bd222c',
    messagingSenderId: '473097776453',
    projectId: 'flutter-bloc-app-697e8',
    storageBucket: 'flutter-bloc-app-697e8.firebasestorage.app',
    iosBundleId: 'com.example.flutterBlocApp',
    iosClientId: '473097776453-eml27tsnmpj6tj5g1ipl8ec7g0ttd5iu.apps.googleusercontent.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2IG7veUZBqGnpQeVWM-9Z89kj_3wSqYc',
    appId: '1:473097776453:ios:6962f6ddc4d7ea12bd222c',
    messagingSenderId: '473097776453',
    projectId: 'flutter-bloc-app-697e8',
    storageBucket: 'flutter-bloc-app-697e8.firebasestorage.app',
    iosBundleId: 'com.example.flutterBlocApp',
    iosClientId: '473097776453-eml27tsnmpj6tj5g1ipl8ec7g0ttd5iu.apps.googleusercontent.com',
  );
}
