import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:networking/networking.dart';

part 'certificate_pinning_demo_state.freezed.dart';

enum CertificatePinningDemoStatus { initial, validating, success, failure }

@freezed
sealed class CertificatePinningDemoState with _$CertificatePinningDemoState {
  const factory CertificatePinningDemoState({
    required CertificatePinningMode mode,
    required MockCertificateScenario scenario,
    @Default(CertificatePinningDemoStatus.initial)
    CertificatePinningDemoStatus status,
    CertificatePinMatchKind? matchKind,
    CertificatePinningDemoFailure? failure,
    @Default(<String>[]) List<String> logLines,
  }) = _CertificatePinningDemoState;
}
