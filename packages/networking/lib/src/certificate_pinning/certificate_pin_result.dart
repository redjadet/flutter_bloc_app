import 'certificate_pinning_failure.dart';

enum CertificatePinMatchKind { primary, backup }

/// Outcome of a pin validation attempt.
sealed class CertificatePinResult {
  const CertificatePinResult();
}

final class CertificatePinSuccess extends CertificatePinResult {
  const CertificatePinSuccess({required this.matchKind});

  final CertificatePinMatchKind matchKind;
}

final class CertificatePinFailureResult extends CertificatePinResult {
  const CertificatePinFailureResult(this.failure);

  final CertificatePinningFailure failure;
}
