import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:networking/networking.dart';

/// Result of a developer secure-probe attempt.
sealed class SecureProbeOutcome {
  const SecureProbeOutcome();
}

final class const SecureProbeSuccess({
  required final CertificatePinMatchKind matchKind,
}) extends SecureProbeOutcome;

final class SecureProbeFailure extends SecureProbeOutcome {
  const SecureProbeFailure(this.failure);

  final CertificatePinningDemoFailure failure;
}

abstract interface class SecureProbeRepository {
  Future<SecureProbeOutcome> probe();
}
