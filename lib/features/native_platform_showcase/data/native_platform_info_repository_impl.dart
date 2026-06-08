import 'package:flutter_bloc_app/features/native_platform_showcase/data/platform_showcase_mapper.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/runtime_platform_probe.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_platform_info_repository.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_host_language_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_native_code_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';

class NativePlatformInfoRepositoryImpl implements NativePlatformInfoRepository {
  NativePlatformInfoRepositoryImpl({
    required final NativeShowcaseHostLanguageService hostLanguageService,
    required final NativeShowcaseNativeCodeService nativeCodeService,
    final RuntimePlatformProbe? probe,
  }) : this._(
         hostLanguageService: hostLanguageService,
         nativeCodeService: nativeCodeService,
         probe: probe,
       );

  NativePlatformInfoRepositoryImpl._({
    required this._hostLanguageService,
    required this._nativeCodeService,
    final RuntimePlatformProbe? probe,
  }) : _probe = probe ?? const RuntimePlatformProbe();

  final RuntimePlatformProbe _probe;
  final NativeShowcaseHostLanguageService _hostLanguageService;
  final NativeShowcaseNativeCodeService _nativeCodeService;

  @override
  Future<PlatformShowcaseData> loadShowcase() async {
    final AppPlatformKind platform = _probe.resolve();
    final PlatformShowcaseData catalog = mapShowcase(platform);
    final List<NativeInteropCallResult> interopResults =
        await _loadInteropResults();
    return catalog.copyWith(interopResults: interopResults);
  }

  Future<List<NativeInteropCallResult>> _loadInteropResults() async {
    final List<NativeInteropCallResult> hostResults = await Future.wait(
      <Future<NativeInteropCallResult>>[
        _hostLanguageService.invokeSwift(),
        _hostLanguageService.invokeKotlin(),
      ],
    );
    return <NativeInteropCallResult>[
      ...hostResults,
      _nativeCodeService.invokeCpp(),
    ];
  }
}
