import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/watch_native_showcase_telemetry_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadNativePlatformShowcaseUseCase extends Mock
    implements LoadNativePlatformShowcaseUseCase {}

class _MockWatchNativeShowcaseTelemetryUseCase extends Mock
    implements WatchNativeShowcaseTelemetryUseCase {}

void main() {
  group('NativePlatformShowcaseCubit', () {
    late _MockLoadNativePlatformShowcaseUseCase loadShowcase;
    late _MockWatchNativeShowcaseTelemetryUseCase watchTelemetry;
    late StreamController<NativeShowcaseTelemetrySnapshot> telemetryController;

    final loadedData = PlatformShowcaseData(
      platform: AppPlatformKind.macos,
      capabilities: const <NativeCapability>[
        NativeCapability(
          kind: NativeCapabilityKind.nativeViewEmbedding,
          platformDetail: 'AppKit embedding',
        ),
      ],
      interopResults: const <NativeInteropCallResult>[],
    );

    final telemetrySnapshot = NativeShowcaseTelemetrySnapshot(
      status: NativeShowcaseTelemetryStatus.streaming,
      sequence: 1,
      sampleCount: 10,
      averageValue: 12.5,
      sourceRateHz: 60,
      deliveredRateHz: 4,
      droppedCount: 2,
      emittedAt: DateTime(2026, 1, 1),
    );

    setUp(() {
      loadShowcase = _MockLoadNativePlatformShowcaseUseCase();
      watchTelemetry = _MockWatchNativeShowcaseTelemetryUseCase();
      telemetryController = StreamController<NativeShowcaseTelemetrySnapshot>.broadcast();
      when(() => watchTelemetry()).thenAnswer((_) => telemetryController.stream);
    });

    tearDown(() async {
      await telemetryController.close();
    });

    NativePlatformShowcaseCubit buildCubit() =>
        NativePlatformShowcaseCubit(loadShowcase: loadShowcase, watchTelemetry: watchTelemetry);

    blocTest<NativePlatformShowcaseCubit, NativePlatformShowcaseState>(
      'emits loading then loaded when use case succeeds',
      build: () {
        when(() => loadShowcase()).thenAnswer((_) async => loadedData);
        return buildCubit();
      },
      act: (final cubit) => cubit.load(),
      expect: () => <NativePlatformShowcaseState>[
        const NativePlatformShowcaseState.loading(),
        NativePlatformShowcaseState.loaded(loadedData),
      ],
      verify: (_) {
        verify(() => watchTelemetry()).called(1);
      },
    );

    blocTest<NativePlatformShowcaseCubit, NativePlatformShowcaseState>(
      'starts telemetry and updates only telemetry field after load',
      build: () {
        when(() => loadShowcase()).thenAnswer((_) async => loadedData);
        return buildCubit();
      },
      act: (final cubit) async {
        await cubit.load();
        telemetryController.add(telemetrySnapshot);
      },
      expect: () => <NativePlatformShowcaseState>[
        const NativePlatformShowcaseState.loading(),
        NativePlatformShowcaseState.loaded(loadedData),
        NativePlatformShowcaseState.loaded(loadedData, telemetry: telemetrySnapshot),
      ],
    );

    blocTest<NativePlatformShowcaseCubit, NativePlatformShowcaseState>(
      'ignores duplicate or older telemetry sequence',
      build: () {
        when(() => loadShowcase()).thenAnswer((_) async => loadedData);
        return buildCubit();
      },
      act: (final cubit) async {
        await cubit.load();
        telemetryController.add(telemetrySnapshot);
        telemetryController.add(telemetrySnapshot.copyWith(sequence: 1, averageValue: 99));
        telemetryController.add(telemetrySnapshot.copyWith(sequence: 0, averageValue: 1));
      },
      expect: () => <NativePlatformShowcaseState>[
        const NativePlatformShowcaseState.loading(),
        NativePlatformShowcaseState.loaded(loadedData),
        NativePlatformShowcaseState.loaded(loadedData, telemetry: telemetrySnapshot),
      ],
    );

    test('stream error becomes failed telemetry while loaded data remains', () async {
      when(() => loadShowcase()).thenAnswer((_) async => loadedData);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.load();
      telemetryController.addError(Exception('stream failed'));
      await Future<void>.delayed(Duration.zero);

      cubit.state.maybeWhen(
        loaded: (final data, final telemetry) {
          expect(data, loadedData);
          expect(telemetry?.status, NativeShowcaseTelemetryStatus.failed);
          expect(telemetry?.message, contains('stream failed'));
        },
        orElse: () => fail('expected loaded state'),
      );
    },
    );

    blocTest<NativePlatformShowcaseCubit, NativePlatformShowcaseState>(
      'emits loading then error when use case throws',
      build: () {
        when(() => loadShowcase()).thenThrow(Exception('fail'));
        return buildCubit();
      },
      act: (final cubit) => cubit.load(),
      expect: () => <NativePlatformShowcaseState>[
        const NativePlatformShowcaseState.loading(),
        const NativePlatformShowcaseState.error(
          failure: NativePlatformShowcaseFailureKind.loadFailed,
        ),
      ],
      verify: (_) {
        verifyNever(() => watchTelemetry());
      },
    );

    blocTest<NativePlatformShowcaseCubit, NativePlatformShowcaseState>(
      'ignores overlapping load while request is in flight',
      build: () {
        when(() => loadShowcase()).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return loadedData;
        });
        return buildCubit();
      },
      act: (final cubit) async {
        final first = cubit.load();
        final second = cubit.load();
        await Future.wait<void>(<Future<void>>[first, second]);
      },
      expect: () => <NativePlatformShowcaseState>[
        const NativePlatformShowcaseState.loading(),
        NativePlatformShowcaseState.loaded(loadedData),
      ],
      verify: (_) {
        verify(() => loadShowcase()).called(1);
      },
    );

    test('does not emit loaded after cubit closes during load', () async {
      final completer = Completer<PlatformShowcaseData>();
      when(() => loadShowcase()).thenAnswer((_) => completer.future);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final states = <NativePlatformShowcaseState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      final load = cubit.load();
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      completer.complete(loadedData);
      await load;

      expect(states, const <NativePlatformShowcaseState>[
        NativePlatformShowcaseState.loading(),
      ]);
      verify(() => loadShowcase()).called(1);
      verifyNever(() => watchTelemetry());
    });

    test('close cancels telemetry subscription', () async {
      when(() => loadShowcase()).thenAnswer((_) async => loadedData);
      final cubit = buildCubit();
      await cubit.load();
      await cubit.close();
      telemetryController.add(telemetrySnapshot.copyWith(sequence: 99));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.isClosed, isTrue);
      expect(cubit.state, NativePlatformShowcaseState.loaded(loadedData));
    });
  });
}
