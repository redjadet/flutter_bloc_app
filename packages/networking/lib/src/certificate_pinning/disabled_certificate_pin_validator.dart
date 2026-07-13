import 'dart:typed_data';

import 'certificate_pin_result.dart';
import 'certificate_pin_validator.dart';

/// Always succeeds; used when pinning mode is [CertificatePinningMode.disabled].
final class DisabledCertificatePinValidator implements CertificatePinValidator {
  const DisabledCertificatePinValidator();

  @override
  Future<CertificatePinResult> validate({
    required final String host,
    required final int port,
    required final Uint8List certificateBytes,
  }) async =>
      const CertificatePinSuccess(matchKind: CertificatePinMatchKind.primary);
}
