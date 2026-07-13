import 'package:networking/networking.dart';

/// Demo-only TLS pinning policy wired to shared [CertificatePinningConfig].
final class CertificatePinningPolicy {
  const CertificatePinningPolicy({required this.config});

  final CertificatePinningConfig config;

  bool get enabled => config.mode != CertificatePinningMode.disabled;
}
