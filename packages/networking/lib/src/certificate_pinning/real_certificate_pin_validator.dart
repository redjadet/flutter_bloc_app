import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'certificate_pin_comparator.dart';
import 'certificate_pin_formatter.dart';
import 'certificate_pin_hash_kind.dart';
import 'certificate_pin_result.dart';
import 'certificate_pin_validator.dart';
import 'certificate_pinning_config.dart';
import 'certificate_pinning_failure.dart';
import 'certificate_pinning_logger.dart';
import 'certificate_pinning_mode.dart';
import 'certificate_spki_extractor.dart';

/// SHA-256 certificate / public-key pinning.
///
/// Default material is [CertificatePinHashKind.spki] (SubjectPublicKeyInfo).
/// [CertificatePinHashKind.leafCertificate] remains available for migration.
final class RealCertificatePinValidator implements CertificatePinValidator {
  RealCertificatePinValidator({required this._config, this._logger});

  final CertificatePinningConfig _config;
  final CertificatePinningLogger? _logger;

  @override
  Future<CertificatePinResult> validate({
    required final String host,
    required final int port,
    required final Uint8List certificateBytes,
  }) async {
    final Stopwatch sw = Stopwatch()..start();
    final CertificatePinResult result = validateSync(
      host: host,
      port: port,
      certificateBytes: certificateBytes,
    );
    sw.stop();
    _logger?.logValidation(
      host: host,
      mode: CertificatePinningMode.real,
      result: result,
      elapsed: sw.elapsed,
    );
    return result;
  }

  /// Sync path for Dio [IOHttpClientAdapter.validateCertificate].
  CertificatePinResult validateSync({
    required final String host,
    required final int port,
    required final Uint8List certificateBytes,
  }) {
    if (certificateBytes.isEmpty) {
      return const CertificatePinFailureResult(CertificateMalformedFailure());
    }

    final String normalizedHost = CertificatePinningConfig.normalizeHost(host);
    if (!_config.allowedHosts.contains(normalizedHost)) {
      return const CertificatePinFailureResult(UnsupportedHostFailure());
    }

    final Set<String>? pins = _config.sha256PinsByHost[normalizedHost];
    if (pins == null || pins.isEmpty) {
      return const CertificatePinFailureResult(MissingPinFailure());
    }

    final Uint8List? material = _hashMaterial(certificateBytes);
    if (material == null || material.isEmpty) {
      return const CertificatePinFailureResult(CertificateMalformedFailure());
    }

    final String actual = CertificatePinFormatter.fromSha256Bytes(
      sha256.convert(material).bytes,
    );

    final List<String> ordered = pins.toList(growable: false);
    for (var i = 0; i < ordered.length; i++) {
      final String expected = CertificatePinFormatter.canonicalize(ordered[i]);
      if (CertificatePinComparator.equalStrings(actual, expected)) {
        return CertificatePinSuccess(
          matchKind: i == 0
              ? CertificatePinMatchKind.primary
              : CertificatePinMatchKind.backup,
        );
      }
    }

    return const CertificatePinFailureResult(PinMismatchFailure());
  }

  Uint8List? _hashMaterial(final Uint8List certificateBytes) {
    switch (_config.pinHashKind) {
      case CertificatePinHashKind.spki:
        return CertificateSpkiExtractor.extract(certificateBytes);
      case CertificatePinHashKind.leafCertificate:
        return certificateBytes;
    }
  }
}
