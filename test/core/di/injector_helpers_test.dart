import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('createRemoteRepositoryOrNull', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('skips Firebase remote repositories on macOS desktop debug', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final Object? repository = createRemoteRepositoryOrNull<Object>(
        context: 'test repository',
        factory: () => Object(),
      );

      expect(shouldSkipFirebaseRemoteRepositories, isTrue);
      expect(repository, isNull);
    });
  });
}
