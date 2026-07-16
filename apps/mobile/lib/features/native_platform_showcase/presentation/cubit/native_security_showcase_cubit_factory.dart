import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_certificate_pin_policy_summary_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/probe_app_check_attestation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/run_native_security_operation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:networking/networking.dart';

/// Composition helper so demo routes stay under the file-length budget.
NativeSecurityShowcaseCubit createNativeSecurityShowcaseCubit() =>
    NativeSecurityShowcaseCubit(
      runOperation: getIt<RunNativeSecurityOperationUseCase>(),
      probeAppCheck: getIt<ProbeAppCheckAttestationUseCase>(),
      loadCertSummary: getIt<LoadCertificatePinPolicySummaryUseCase>(),
      pinningConfig: getIt<CertificatePinningConfig>(),
      canOpenMutableDemo: !kReleaseMode && !FlavorManager.I.isProd,
    );
