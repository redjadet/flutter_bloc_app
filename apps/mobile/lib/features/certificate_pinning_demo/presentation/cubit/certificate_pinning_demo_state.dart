import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:networking/networking.dart';

part 'certificate_pinning_demo_state.freezed.dart';

enum CertificatePinningDemoStatus { initial, validating, success, failure }

@freezed
sealed class CertificatePinningDemoState with _$CertificatePinningDemoState {
  const factory CertificatePinningDemoState({
    required final CertificatePinningMode mode,
    required final MockCertificateScenario scenario,
    @Default(CertificatePinningDemoStatus.initial) final CertificatePinningDemoStatus status,
    final CertificatePinMatchKind? matchKind,
    final CertificatePinningDemoFailure? failure,
    @Default(<String>[]) final List<String> logLines,
  }) = _CertificatePinningDemoState;
}
