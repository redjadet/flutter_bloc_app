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
      when(
        () => remoteConfigService.getString('test_value_1'),
      ).thenReturn('initial');
      when(
        () => remoteConfigService.getString('last_data_source'),
      ).thenReturn('');
      when(
        () => remoteConfigService.getString('last_synced_at'),
      ).thenReturn('');
      when(() => remoteConfigService.clearCache()).thenAnswer((_) async {});
    });

    blocTest<RemoteConfigCubit, RemoteConfigState>(
      'emits loading then loaded when initialize succeeds',
      build: () {
        when(() => remoteConfigService.initialize()).thenAnswer((_) async {});
        when(() => remoteConfigService.forceFetch()).thenAnswer((_) async {});
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(true);
        when(
          () => remoteConfigService.getString('test_value_1'),
        ).thenReturn('awesome');
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true, testValue: 'awesome'),
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
        when(
          () => remoteConfigService.getString('test_value_1'),
        ).thenReturn('initial');
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) async {
        await cubit.initialize();
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(false);
        when(
          () => remoteConfigService.getString('test_value_1'),
        ).thenReturn('updated');
        await cubit.fetchValues();
      },
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true, testValue: 'initial'),
        RemoteConfigLoading(),
        RemoteConfigLoaded(
          isAwesomeFeatureEnabled: false,
          testValue: 'updated',
        ),
      ],
      verify: (_) {
        verify(() => remoteConfigService.initialize()).called(1);
        verify(() => remoteConfigService.forceFetch()).called(2);
      },
    );

    blocTest<RemoteConfigCubit, RemoteConfigState>(
      'clears cache then fetches latest values',
      build: () {
        when(() => remoteConfigService.forceFetch()).thenAnswer((_) async {});
        when(
          () => remoteConfigService.getBool('awesome_feature_enabled'),
        ).thenReturn(true);
        when(
          () => remoteConfigService.getString('test_value_1'),
        ).thenReturn('cached');
        return RemoteConfigCubit(remoteConfigService);
      },
      act: (cubit) => cubit.clearCache(),
      expect: () => const <RemoteConfigState>[
        RemoteConfigLoading(),
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true, testValue: 'cached'),
      ],
      verify: (_) {
        verify(() => remoteConfigService.clearCache()).called(1);
        verify(() => remoteConfigService.forceFetch()).called(1);
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
        when(
          () => remoteConfigService.getString('test_value_1'),
        ).thenReturn('initial');
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
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true, testValue: 'initial'),
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
        when(
          () => remoteConfigService.getString('test_value_1'),
        ).thenReturn('overlap');
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
        RemoteConfigLoaded(isAwesomeFeatureEnabled: true, testValue: 'overlap'),
      ],
      verify: (_) {
        verify(() => remoteConfigService.forceFetch()).called(1);
      },
    );
  });
}
