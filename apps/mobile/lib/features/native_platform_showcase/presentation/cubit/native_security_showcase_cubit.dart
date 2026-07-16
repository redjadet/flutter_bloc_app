import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_certificate_pin_policy_summary_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/probe_app_check_attestation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/run_native_security_operation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_state.dart';
import 'package:networking/networking.dart';

/// Child cubit nested under `/native-platform-showcase`; no route of its own.
///
/// Calls domain use cases only — no `MethodChannel` / Firebase imports here.
class NativeSecurityShowcaseCubit extends Cubit<NativeSecurityShowcaseState> {
  NativeSecurityShowcaseCubit({
    required this._runOperation,
    required this._probeAppCheck,
    required this._loadCertSummary,
    required this._pinningConfig,
    required this._canOpenMutableDemo,
  }) : super(
         NativeSecurityShowcaseState(
           certificateSummary: _loadCertSummary(
             _pinningConfig,
             canOpenMutableDemo: _canOpenMutableDemo,
           ),
         ),
       );

  final RunNativeSecurityOperationUseCase _runOperation;
  final ProbeAppCheckAttestationUseCase _probeAppCheck;
  final LoadCertificatePinPolicySummaryUseCase _loadCertSummary;
  final CertificatePinningConfig _pinningConfig;
  final bool _canOpenMutableDemo;

  void loadCertificateSummary() {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        certificateSummary: _loadCertSummary(
          _pinningConfig,
          canOpenMutableDemo: _canOpenMutableDemo,
        ),
      ),
    );
  }

  Future<void> runP256() => _runAndApply(
    NativeSecurityOperation.p256SignVerify,
    (final s, final r) => s.copyWith(p256Result: r),
  );

  Future<void> runAesGcm() => _runAndApply(
    NativeSecurityOperation.aesGcmRoundTrip,
    (final s, final r) => s.copyWith(aesResult: r),
  );

  Future<void> runSecureStorage() => _runAndApply(
    NativeSecurityOperation.secureStorageLifecycle,
    (final s, final r) => s.copyWith(storageResult: r),
  );

  Future<void> runBiometric() => _runAndApply(
    NativeSecurityOperation.biometricProtectedOperation,
    (final s, final r) => s.copyWith(biometricResult: r),
  );

  /// Runs P-256 then AES-GCM sequentially. The UI shows two separate run
  /// buttons calling [runP256] / [runAesGcm] directly; this is kept for
  /// callers that want both crypto results in one call.
  Future<void> runCrypto() async {
    await runP256();
    await runAesGcm();
  }

  Future<void> runAppCheck() async {
    if (isClosed || state.isBusy) {
      return;
    }
    emit(state.copyWith(appCheckInFlight: true));
    try {
      final result = await _probeAppCheck();
      if (isClosed) {
        return;
      }
      emit(state.copyWith(appCheckInFlight: false, appCheckResult: result));
    } on Object {
      // Use cases normally never throw; still clear busy and map to a locked
      // failed outcome so the UI cannot stick disabled or crash the route.
      if (!isClosed) {
        emit(
          state.copyWith(
            appCheckInFlight: false,
            appCheckResult: const AppCheckAttestationResult(
              status: AppCheckAttestationStatus.failed,
              providerLabel: 'unknown',
              reasonCode: 'app_check_error',
            ),
          ),
        );
      }
    }
  }

  Future<void> _runAndApply(
    final NativeSecurityOperation operation,
    final NativeSecurityShowcaseState Function(
      NativeSecurityShowcaseState state,
      NativeSecurityOperationResult result,
    )
    apply,
  ) async {
    if (isClosed || state.isBusy) {
      return;
    }
    emit(state.copyWith(inFlight: operation));
    late final NativeSecurityOperationResult result;
    try {
      result = await _runOperation(operation);
    } on Object {
      // Adapters map expected platform failures themselves. Keep this final
      // boundary so a faulty implementation cannot leave every card disabled.
      result = const NativeSecurityOperationResult(
        status: NativeSecurityStatus.failed,
        reasonCode: 'platform_error',
        platform: 'unknown',
      );
    }
    if (isClosed) {
      return;
    }
    emit(apply(state.copyWith(inFlight: null), result));
  }
}
