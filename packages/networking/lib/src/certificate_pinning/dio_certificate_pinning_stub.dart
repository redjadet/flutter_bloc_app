import 'package:dio/dio.dart';

import 'certificate_pin_validator.dart';
import 'certificate_pinning_config.dart';
import 'certificate_pinning_mode.dart';

/// Web / non-IO: certificate pinning adapter is unavailable.
///
/// Fail closed when [CertificatePinningMode.real] is requested — never silently
/// skip pinning on a platform that cannot enforce it.
void applyCertificatePinning(
  final Dio dio, {
  required final CertificatePinningConfig config,
  required final CertificatePinValidator validator,
}) {
  if (config.mode == CertificatePinningMode.real) {
    throw UnsupportedError(
      'Certificate pinning mode=real requires dart:io '
      '(not available on web). Keep CERT_PINNING_MODE=disabled on web.',
    );
  }
}
