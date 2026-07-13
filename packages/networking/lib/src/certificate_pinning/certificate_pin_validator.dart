import 'dart:typed_data';

import 'certificate_pin_result.dart';

/// Validates leaf certificate bytes against configured pins.
abstract interface class CertificatePinValidator {
  Future<CertificatePinResult> validate({
    required String host,
    required int port,
    required Uint8List certificateBytes,
  });
}
