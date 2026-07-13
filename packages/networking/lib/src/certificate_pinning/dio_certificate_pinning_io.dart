import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'certificate_pin_result.dart';
import 'certificate_pin_validator.dart';
import 'certificate_pinning_config.dart';
import 'certificate_pinning_mode.dart';
import 'real_certificate_pin_validator.dart';

/// Applies leaf-certificate pin checks to [dio] when mode is [CertificatePinningMode.real].
///
/// Uses [IOHttpClientAdapter.validateCertificate] after system trust succeeds.
/// Never sets [HttpClient.badCertificateCallback] to accept all certificates.
void applyCertificatePinning(
  final Dio dio, {
  required final CertificatePinningConfig config,
  required final CertificatePinValidator validator,
}) {
  if (config.mode != CertificatePinningMode.real) {
    return;
  }

  final RealCertificatePinValidator realValidator;
  if (validator is RealCertificatePinValidator) {
    realValidator = validator;
  } else {
    throw StateError(
      'applyCertificatePinning(mode=real) requires RealCertificatePinValidator.',
    );
  }

  CreateHttpClient? existingCreateHttpClient;
  final HttpClientAdapter current = dio.httpClientAdapter;
  if (current is IOHttpClientAdapter) {
    existingCreateHttpClient = current.createHttpClient;
  }

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: existingCreateHttpClient,
    validateCertificate:
        (
          final X509Certificate? certificate,
          final String host,
          final int port,
        ) {
          if (certificate == null) {
            return false;
          }
          final CertificatePinResult result = realValidator.validateSync(
            host: host,
            port: port,
            certificateBytes: Uint8List.fromList(certificate.der),
          );
          return result is CertificatePinSuccess;
        },
  );
}
