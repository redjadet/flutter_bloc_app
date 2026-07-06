import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void installMockFirebasePlatformForTests() {
  final MockFirebasePlatform mockPlatform = MockFirebasePlatform();
  FirebasePlatform.instance = mockPlatform;
  Firebase.delegatePackingProperty = mockPlatform;
}

void resetFirebaseTestDelegate() {
  Firebase.delegatePackingProperty = null;
}

class MockFirebasePlatform extends FirebasePlatform {
  FirebaseOptions? _options;

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _options = options;
    return MockFirebaseApp(name ?? '[DEFAULT]', options ?? mockFirebaseOptions);
  }

  @override
  List<FirebaseAppPlatform> get apps => [
    MockFirebaseApp('[DEFAULT]', _options ?? mockFirebaseOptions),
  ];

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) =>
      MockFirebaseApp(name, _options ?? mockFirebaseOptions);
}

class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp(super.name, super.options);
}

const FirebaseOptions mockFirebaseOptions = FirebaseOptions(
  apiKey: 'fake-api-key',
  appId: 'fake-app-id',
  messagingSenderId: 'fake-sender-id',
  projectId: 'fake-project-id',
);
