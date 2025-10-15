import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
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
    });
  });
}
