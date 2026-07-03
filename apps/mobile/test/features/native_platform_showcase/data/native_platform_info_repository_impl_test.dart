import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/native_platform_info_repository_impl.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/runtime_platform_probe.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_host_language_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_native_code_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHostLanguageService extends Mock
    implements NativeShowcaseHostLanguageService {}

class _MockNativeCodeService extends Mock
    implements NativeShowcaseNativeCodeService {}

void main() {
  group('NativePlatformInfoRepositoryImpl', () {
    late _MockHostLanguageService hostLanguageService;
    late _MockNativeCodeService nativeCodeService;

    setUp(() {
      hostLanguageService = _MockHostLanguageService();
      nativeCodeService = _MockNativeCodeService();
    });

    test('merges catalog with live interop results', () async {
      when(() => hostLanguageService.invokeSwift()).thenAnswer(
        (_) async => const NativeInteropCallResult(
          kind: NativeInteropBridgeKind.swift,
          status: NativeInteropStatus.success,
          message: 'swift-ok',
        ),
      );
      when(() => hostLanguageService.invokeKotlin()).thenAnswer(
        (_) async => const NativeInteropCallResult(
          kind: NativeInteropBridgeKind.kotlin,
          status: NativeInteropStatus.unavailable,
          message: 'kotlin-off',
        ),
      );
      when(() => nativeCodeService.invokeCpp()).thenReturn(
        const NativeInteropCallResult(
          kind: NativeInteropBridgeKind.cpp,
          status: NativeInteropStatus.success,
          message: 'cpp-ok',
        ),
      );

      final repository = NativePlatformInfoRepositoryImpl(
        probe: const RuntimePlatformProbe(
          isWeb: false,
          platform: TargetPlatform.iOS,
        ),
        hostLanguageService: hostLanguageService,
        nativeCodeService: nativeCodeService,
      );

      final data = await repository.loadShowcase();

      expect(data.platform, AppPlatformKind.ios);
      expect(data.capabilities, hasLength(5));
      expect(
        data.interopResults.map((final r) => r.kind).toList(),
        <NativeInteropBridgeKind>[
          NativeInteropBridgeKind.swift,
          NativeInteropBridgeKind.kotlin,
          NativeInteropBridgeKind.cpp,
        ],
      );
      expect(data.interopResults.first.message, 'swift-ok');
      verify(() => hostLanguageService.invokeSwift()).called(1);
      verify(() => hostLanguageService.invokeKotlin()).called(1);
      verify(() => nativeCodeService.invokeCpp()).called(1);
    });
  });
}
