import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';

class _MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  group('RemoteConfigRepository', () {
    late _MockFirebaseRemoteConfig remoteConfig;
    late List<String> debugMessages;

    setUpAll(() {
      registerFallbackValue(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
    });

    setUp(() {
      debugDefaultTargetPlatformOverride = null;
      remoteConfig = _MockFirebaseRemoteConfig();
      debugMessages = <String>[];

      when(
        () => remoteConfig.setConfigSettings(any()),
      ).thenAnswer((_) async {});
      when(() => remoteConfig.setDefaults(any())).thenAnswer((_) async {});
      when(
        () => remoteConfig.onConfigUpdated,
      ).thenAnswer((_) => const Stream<RemoteConfigUpdate>.empty());
      when(
        () => remoteConfig.getBool('awesome_feature_enabled'),
      ).thenReturn(false);
      when(() => remoteConfig.getString('test_value_1')).thenReturn('');
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('logs test_value_1 when getString is called', () {
      when(
        () => remoteConfig.getString('test_value_1'),
      ).thenReturn('expected-value');

      final repository = RemoteConfigRepository(
        remoteConfig,
        debugLogger: debugMessages.add,
      );

      expect(repository.getString('test_value_1'), 'expected-value');
      expect(
        debugMessages,
        contains('RemoteConfig[getString] test_value_1="expected-value"'),
      );
    });

    test('logs awesome_feature_enabled when getBool is called', () {
      when(
        () => remoteConfig.getBool('awesome_feature_enabled'),
      ).thenReturn(true);

      final repository = RemoteConfigRepository(
        remoteConfig,
        debugLogger: debugMessages.add,
      );

      expect(repository.getBool('awesome_feature_enabled'), isTrue);
      expect(
        debugMessages,
        contains('RemoteConfig[getBool] awesome_feature_enabled=true'),
      );
    });

    test(
      'logs test_value_1 after realtime update containing the key',
      () async {
        final StreamController<RemoteConfigUpdate> controller =
            StreamController<RemoteConfigUpdate>();

        addTearDown(controller.close);

        when(
          () => remoteConfig.onConfigUpdated,
        ).thenAnswer((_) => controller.stream);
        when(
          () => remoteConfig.fetchAndActivate(),
        ).thenAnswer((_) async => true);
        when(
          () => remoteConfig.getString('test_value_1'),
        ).thenReturn('latest-value');

        final repository = RemoteConfigRepository(
          remoteConfig,
          debugLogger: debugMessages.add,
        );

        await repository.initialize();

        controller.add(RemoteConfigUpdate(<String>{'test_value_1'}));
        await pumpEventQueue(times: 5);

        expect(
          debugMessages,
          contains('RemoteConfig[realtime-update] test_value_1="latest-value"'),
        );
      },
    );

    test(
      'logs awesome_feature_enabled after realtime update containing the key',
      () async {
        final StreamController<RemoteConfigUpdate> controller =
            StreamController<RemoteConfigUpdate>();

        addTearDown(controller.close);

        when(
          () => remoteConfig.onConfigUpdated,
        ).thenAnswer((_) => controller.stream);
        when(
          () => remoteConfig.fetchAndActivate(),
        ).thenAnswer((_) async => true);
        when(
          () => remoteConfig.getBool('awesome_feature_enabled'),
        ).thenReturn(true);

        final repository = RemoteConfigRepository(
          remoteConfig,
          debugLogger: debugMessages.add,
        );

        await repository.initialize();

        controller.add(RemoteConfigUpdate(<String>{'awesome_feature_enabled'}));
        await pumpEventQueue(times: 5);

        expect(
          debugMessages,
          contains(
            'RemoteConfig[realtime-update] awesome_feature_enabled=true',
          ),
        );
      },
    );

    test('forceFetch logs tracked values', () async {
      when(() => remoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
      when(
        () => remoteConfig.getString('test_value_1'),
      ).thenReturn('fetched-value');
      when(
        () => remoteConfig.getBool('awesome_feature_enabled'),
      ).thenReturn(true);

      final repository = RemoteConfigRepository(
        remoteConfig,
        debugLogger: debugMessages.add,
      );

      await repository.forceFetch();

      expect(
        debugMessages,
        contains('RemoteConfig[fetch] test_value_1="fetched-value"'),
      );
      expect(
        debugMessages,
        contains('RemoteConfig[fetch] awesome_feature_enabled=true'),
      );
      final captured = verify(
        () => remoteConfig.setConfigSettings(captureAny()),
      ).captured.cast<RemoteConfigSettings>();
      expect(captured, hasLength(2));
      expect(captured.first.fetchTimeout, const Duration(minutes: 1));
      expect(captured.first.minimumFetchInterval, Duration.zero);
      expect(captured.last.fetchTimeout, const Duration(minutes: 1));
      expect(captured.last.minimumFetchInterval, const Duration(hours: 1));
    });

    test(
      'forceFetch disables retries after Keychain entitlement error',
      () async {
        when(
          () => remoteConfig.fetchAndActivate(),
        ).thenThrow(Exception('SecItemAdd failed with -34018'));

        final repository = RemoteConfigRepository(
          remoteConfig,
          debugLogger: debugMessages.add,
        );

        await repository.forceFetch();
        await repository.forceFetch();

        verify(() => remoteConfig.fetchAndActivate()).called(1);
        verifyNever(() => remoteConfig.getString('test_value_1'));
        verifyNever(() => remoteConfig.getBool('awesome_feature_enabled'));
      },
    );

    test('forceFetch skips native fetch on macOS debug', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final repository = RemoteConfigRepository(
        remoteConfig,
        debugLogger: debugMessages.add,
      );

      await repository.forceFetch();

      verifyNever(() => remoteConfig.fetchAndActivate());
      verifyNever(() => remoteConfig.setConfigSettings(any()));
    });

    test(
      'dispose keeps the repository terminal and does not re-subscribe',
      () async {
        final StreamController<RemoteConfigUpdate> controller =
            StreamController<RemoteConfigUpdate>();

        addTearDown(controller.close);

        when(
          () => remoteConfig.onConfigUpdated,
        ).thenAnswer((_) => controller.stream);

        final repository = RemoteConfigRepository(
          remoteConfig,
          debugLogger: debugMessages.add,
        );

        await repository.initialize();
        await repository.dispose();
        await repository.initialize();

        verify(() => remoteConfig.setConfigSettings(any())).called(1);
        verify(() => remoteConfig.setDefaults(any())).called(1);
        verify(() => remoteConfig.onConfigUpdated).called(1);
      },
    );
  });
}
