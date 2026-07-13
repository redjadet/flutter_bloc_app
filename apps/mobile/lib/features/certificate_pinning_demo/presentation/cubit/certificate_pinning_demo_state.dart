import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:networking/networking.dart';

enum CertificatePinningDemoStatus { initial, validating, success, failure }

final class CertificatePinningDemoState extends Equatable {
  const CertificatePinningDemoState({
    required this.mode,
    required this.scenario,
    this.status = CertificatePinningDemoStatus.initial,
    this.matchKind,
    this.failure,
    this.logLines = const <String>[],
  });

  final CertificatePinningDemoStatus status;
  final CertificatePinningMode mode;
  final MockCertificateScenario scenario;
  final CertificatePinMatchKind? matchKind;
  final CertificatePinningDemoFailure? failure;
  final List<String> logLines;

  CertificatePinningDemoState copyWith({
    final CertificatePinningDemoStatus? status,
    final CertificatePinningMode? mode,
    final MockCertificateScenario? scenario,
    final CertificatePinMatchKind? matchKind,
    final CertificatePinningDemoFailure? failure,
    final List<String>? logLines,
    final bool clearFailure = false,
    final bool clearMatch = false,
  }) => CertificatePinningDemoState(
    status: status ?? this.status,
    mode: mode ?? this.mode,
    scenario: scenario ?? this.scenario,
    matchKind: clearMatch ? null : (matchKind ?? this.matchKind),
    failure: clearFailure ? null : (failure ?? this.failure),
    logLines: logLines ?? this.logLines,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    mode,
    scenario,
    matchKind,
    failure,
    logLines,
  ];
}
