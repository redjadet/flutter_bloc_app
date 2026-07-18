// Placeholder Firebase options so the project compiles and runs without
// Firebase configuration. FirebaseBootstrapService skips initialization
// when it detects these placeholder values.
//
// To run with Firebase: see docs/integrations/firebase_setup.md and run
// `flutterfire configure` to generate lib/firebase_options.dart.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Placeholder [FirebaseOptions] so the app compiles and skips Firebase init.
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
    apiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'YOUR_ANDROID_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '1:000000000000:android:placeholder',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '000000000000',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'your-project-id',
    ),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'your-project-id.appspot.com',
    ),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'YOUR_IOS_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: '1:000000000000:ios:placeholder',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '000000000000',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'your-project-id',
    ),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'your-project-id.appspot.com',
    ),
    iosClientId: String.fromEnvironment('FIREBASE_IOS_CLIENT_ID'),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.example.flutterBlocApp',
    ),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_MACOS_API_KEY',
      defaultValue: 'YOUR_MACOS_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_MACOS_APP_ID',
      defaultValue: '1:000000000000:ios:placeholder',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '000000000000',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'your-project-id',
    ),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'your-project-id.appspot.com',
    ),
    iosClientId: String.fromEnvironment('FIREBASE_MACOS_CLIENT_ID'),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_MACOS_BUNDLE_ID',
      defaultValue: 'com.example.flutterBlocApp',
    ),
  );
}
