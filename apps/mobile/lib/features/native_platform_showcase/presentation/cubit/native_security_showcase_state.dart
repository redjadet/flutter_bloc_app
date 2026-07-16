import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_security_showcase_state.freezed.dart';

@freezed
abstract class NativeSecurityShowcaseState with _$NativeSecurityShowcaseState {
  const factory NativeSecurityShowcaseState({
    required CertificatePinPolicySummary certificateSummary,
    NativeSecurityOperation? inFlight,
    @Default(false) bool appCheckInFlight,
    NativeSecurityOperationResult? p256Result,
    NativeSecurityOperationResult? aesResult,
    NativeSecurityOperationResult? storageResult,
    NativeSecurityOperationResult? biometricResult,
    AppCheckAttestationResult? appCheckResult,
  }) = _NativeSecurityShowcaseState;

  const NativeSecurityShowcaseState._();

  /// Shared busy gate for crypto/storage/biometric + App Check buttons.
  bool get isBusy => inFlight != null || appCheckInFlight;
}
