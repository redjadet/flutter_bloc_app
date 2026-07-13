import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/secure_probe_repository.dart';
import 'package:networking/networking.dart';

/// Runs pin validation for the developer demo.
///
/// When global mode is [CertificatePinningMode.disabled] or mock*, uses the
/// mock validator path (no TLS). When mode is [CertificatePinningMode.real],
/// issues a Dio GET to [CertificatePinningConfig.realProbeUrl] (required).
final class SecureProbeRepositoryImpl implements SecureProbeRepository {
  SecureProbeRepositoryImpl({
    required this.config,
    required this.mockValidator,
    required this.dio,
  });

  final CertificatePinningConfig config;
  final MockCertificatePinValidator mockValidator;
  final Dio dio;

  static final Uint8List _demoCertBytes = Uint8List.fromList(
    List<int>.generate(32, (final i) => i),
  );

  @override
  Future<SecureProbeOutcome> probe() async {
    try {
      if (config.mode == CertificatePinningMode.real) {
        return _probeReal();
      }
      final CertificatePinResult result = await mockValidator.validate(
        host: 'demo.pinning.local',
        port: 443,
        certificateBytes: _demoCertBytes,
      );
      return _mapResult(result);
    } on Object catch (_) {
      return const SecureProbeFailure(CertificatePinningDemoUnknownFailure());
    }
  }

  Future<SecureProbeOutcome> _probeReal() async {
    final String? url = config.realProbeUrl;
    if (url == null || url.isEmpty) {
      // Do not feed synthetic bytes into the real validator — that is not a
      // meaningful TLS probe. Require CERT_PINNING_PROBE_URL for mode=real.
      return const SecureProbeFailure(
        CertificatePinningDemoPinFailure(l10nCode: 'validation'),
      );
    }

    try {
      await dio.get<void>(url);
      return const SecureProbeSuccess(
        matchKind: CertificatePinMatchKind.primary,
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.badCertificate) {
        return const SecureProbeFailure(
          CertificatePinningDemoPinFailure(l10nCode: 'pinMismatch'),
        );
      }
      return const SecureProbeFailure(CertificatePinningDemoUnknownFailure());
    }
  }

  SecureProbeOutcome _mapResult(final CertificatePinResult result) {
    return switch (result) {
      CertificatePinSuccess(:final matchKind) => SecureProbeSuccess(
        matchKind: matchKind,
      ),
      CertificatePinFailureResult(:final failure) => SecureProbeFailure(
        CertificatePinningDemoPinFailure.fromDomain(failure),
      ),
    };
  }
}
