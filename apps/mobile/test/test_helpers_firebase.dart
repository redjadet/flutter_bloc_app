import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void installMockFirebasePlatformForTests({final bool seedDefaultApp = true}) {
  final MockFirebasePlatform mockPlatform = MockFirebasePlatform(
    seedDefaultApp: seedDefaultApp,
  );
  FirebasePlatform.instance = mockPlatform;
  Firebase.delegatePackingProperty = mockPlatform;
}

void resetFirebaseTestDelegate() {
  Firebase.delegatePackingProperty = null;
}

class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform({final bool seedDefaultApp = true}) {
    if (seedDefaultApp) {
      _apps.add(MockFirebaseApp('[DEFAULT]', mockFirebaseOptions));
      _options = mockFirebaseOptions;
    }
  }

  final List<FirebaseAppPlatform> _apps = <FirebaseAppPlatform>[];
  FirebaseOptions? _options;

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _options = options ?? mockFirebaseOptions;
    final MockFirebaseApp app = MockFirebaseApp(name ?? '[DEFAULT]', _options!);
    _apps
      ..clear()
      ..add(app);
    return app;
  }

  @override
  List<FirebaseAppPlatform> get apps =>
      List<FirebaseAppPlatform>.unmodifiable(_apps);

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) {
    if (_apps.isEmpty) {
      throw FirebaseException(
        plugin: 'core',
        code: 'no-app',
        message: 'No Firebase App [$name] has been created',
      );
    }
    return _apps.firstWhere(
      (final FirebaseAppPlatform app) => app.name == name,
      orElse: () => _apps.first,
    );
  }
}

class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp(super.name, super.options);
}

const FirebaseOptions mockFirebaseOptions = FirebaseOptions(
  apiKey: 'fake-api-key',
  appId: 'fake-app-id',
  messagingSenderId: 'fake-sender-id',
  projectId: 'fake-project-id',
  storageBucket: 'fake-project-id.appspot.com',
  databaseURL: 'https://fake-project-id.firebaseio.com',
);
