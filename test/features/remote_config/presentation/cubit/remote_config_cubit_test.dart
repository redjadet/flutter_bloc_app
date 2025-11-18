import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('RemoteConfigCubit', () {
    late _MockRemoteConfigService remoteConfigService;

    setUp(() {
      remoteConfigService = _MockRemoteConfigService();
      when(
        () => remoteConfigService.getBool('awesome_feature_enabled'),
      ).thenReturn(false);
    });

    blocTest<RemoteConfigCubit, RemoteConfigState>(
      'emits loading then loaded when initialize succeeds',
      build: () {
        when(() => remoteConfigService.initialize()).thenAnswer((_) async {});
        when(() => remoteConfigService.forceFetch()).thenAnswer((_) async {});
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(true);
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true),
      ],
      verify: (_) {
        verify(() => remoteConfigService.initialize()).called(1);
        verify(() => remoteConfigService.forceFetch()).called(1);
      },
    );

    blocTest<RemoteConfigCubit, RemoteConfigState>(
      'emits loading then error when forceFetch throws',
      build: () {
        when(() => remoteConfigService.initialize()).thenAnswer((_) async {});
        when(
          () => remoteConfigService.forceFetch(),
        ).thenThrow(Exception('forceFetch failed'));
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigError('Exception: forceFetch failed'),
      ],
      verify: (_) {
        verify(() => remoteConfigService.initialize()).called(1);
        verify(() => remoteConfigService.forceFetch()).called(1);
      },
    );

    blocTest<RemoteConfigCubit, RemoteConfigState>(
      'emits loading then loaded when fetchValues succeeds after initial load',
      build: () {
        when(() => remoteConfigService.initialize()).thenAnswer((_) async {});
        when(() => remoteConfigService.forceFetch()).thenAnswer((_) async {});
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(true);
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) async {
        await cubit.initialize();
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(false);
        await cubit.fetchValues();
      },
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true),
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: false),
      ],
      verify: (_) {
        verify(() => remoteConfigService.initialize()).called(1);
        verify(() => remoteConfigService.forceFetch()).called(2);
      },
    );

    blocTest<RemoteConfigCubit, RemoteConfigState>(
      'emits loading then error when fetchValues throws after initial load',
      build: () {
        when(() => remoteConfigService.initialize()).thenAnswer((_) async {});
        when(() => remoteConfigService.forceFetch()).thenAnswer((_) async {});
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(true);
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) async {
        await cubit.initialize();
        when(
          () => remoteConfigService.forceFetch(),
        ).thenThrow(Exception('forceFetch after init failed'));
        await cubit.fetchValues();
      },
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true),
        RemoteConfigLoading(),
        RemoteConfigError('Exception: forceFetch after init failed'),
      ],
      verify: (_) {
        verify(() => remoteConfigService.initialize()).called(1);
        verify(() => remoteConfigService.forceFetch()).called(2);
      },
    );

    late Completer<void> overlappingCompleter;

    blocTest<RemoteConfigCubit, RemoteConfigState>(
      'prevents overlapping loads',
      build: () {
        overlappingCompleter = Completer<void>();
        when(() => remoteConfigService.initialize()).thenAnswer((_) async {});
        when(
          () => remoteConfigService.forceFetch(),
        ).thenAnswer((_) => overlappingCompleter.future);
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(true);
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) async {
        final Future<void> firstCall = cubit.initialize();
        await Future<void>.delayed(Duration.zero);
        await cubit.fetchValues();
        overlappingCompleter.complete();
        await firstCall;
      },
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true),
      ],
      verify: (_) {
        verify(() => remoteConfigService.forceFetch()).called(1);
      },
    );
  });
}
