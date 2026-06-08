import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadNativePlatformShowcaseUseCase extends Mock
    implements LoadNativePlatformShowcaseUseCase {}

void main() {
  group('NativePlatformShowcaseCubit', () {
    late _MockLoadNativePlatformShowcaseUseCase loadShowcase;

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

    setUp(() {
      loadShowcase = _MockLoadNativePlatformShowcaseUseCase();
    });

    NativePlatformShowcaseCubit buildCubit() =>
        NativePlatformShowcaseCubit(loadShowcase: loadShowcase);

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
    });
  });
}
