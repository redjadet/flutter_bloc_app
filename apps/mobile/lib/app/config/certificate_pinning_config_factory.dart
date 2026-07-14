import 'package:flutter/foundation.dart';
import 'package:networking/networking.dart';

/// Builds immutable pinning config from flavor + dart-defines.
///
/// Default mode is always [CertificatePinningMode.disabled] unless
/// `--dart-define=CERT_PINNING_MODE=` overrides it.
abstract final class CertificatePinningConfigFactory {
  static CertificatePinningConfig fromBootstrap({
    required final bool isProd,
    required final bool isReleaseMode,
  }) {
    final CertificatePinningMode mode = _parseMode(
      const String.fromEnvironment('CERT_PINNING_MODE'),
    );
    final Set<String> hosts = _parseHosts(
      const String.fromEnvironment('CERT_PINNING_HOSTS'),
    );
    final Map<String, Set<String>> pins = _parsePins(
      const String.fromEnvironment('CERT_PINNING_PINS'),
    );
    const String probe = String.fromEnvironment('CERT_PINNING_PROBE_URL');
    const bool verbose = bool.fromEnvironment('CERT_PINNING_VERBOSE');
    final CertificatePinHashKind pinHashKind = _parseHashKind(
      const String.fromEnvironment('CERT_PINNING_HASH_KIND'),
    );

    final CertificatePinningConfig config =
        CertificatePinningConfig(
          mode: mode,
          pinHashKind: pinHashKind,
          allowedHosts: hosts,
          sha256PinsByHost: pins,
          realProbeUrl: probe.isEmpty ? null : probe,
          // ignore: avoid_redundant_argument_values -- CERT_PINNING_VERBOSE dart-define
          enableVerboseLogging: verbose,
        )..validate(
          isProdRelease: isProd && isReleaseMode,
          isWeb: kIsWeb,
        );
    return config;
  }

  static CertificatePinningMode _parseMode(final String raw) {
    if (raw.isEmpty) {
      return CertificatePinningMode.disabled;
    }
    switch (raw.trim().toLowerCase()) {
      case 'disabled':
        return CertificatePinningMode.disabled;
      case 'mocksuccess':
      case 'mock_success':
        return CertificatePinningMode.mockSuccess;
      case 'mockfailure':
      case 'mock_failure':
        return CertificatePinningMode.mockFailure;
      case 'real':
        return CertificatePinningMode.real;
      default:
        throw StateError(
          'Unknown CERT_PINNING_MODE="$raw". '
          'Use disabled|mockSuccess|mockFailure|real.',
        );
    }
  }

  /// `spki` (default) or `leaf` / `leafCertificate`.
  static CertificatePinHashKind _parseHashKind(final String raw) {
    if (raw.isEmpty) {
      return CertificatePinHashKind.spki;
    }
    switch (raw.trim().toLowerCase()) {
      case 'spki':
      case 'publickey':
      case 'public_key':
        return CertificatePinHashKind.spki;
      case 'leaf':
      case 'leafcertificate':
      case 'leaf_certificate':
        return CertificatePinHashKind.leafCertificate;
      default:
        throw StateError(
          'Unknown CERT_PINNING_HASH_KIND="$raw". '
          'Use spki|leaf.',
        );
    }
  }

  /// Comma-separated hosts: `api.example.com,cdn.example.com`
  static Set<String> _parseHosts(final String raw) {
    if (raw.trim().isEmpty) {
      return const <String>{};
    }
    return raw.split(',').map((final h) => h.trim()).where((final h) => h.isNotEmpty).toSet();
  }

  /// Format: `host=sha256/PIN|sha256/PIN2;host2=sha256/PIN`
  static Map<String, Set<String>> _parsePins(final String raw) {
    if (raw.trim().isEmpty) {
      return const <String, Set<String>>{};
    }
    final Map<String, Set<String>> out = <String, Set<String>>{};
    for (final String chunk in raw.split(';')) {
      final String trimmed = chunk.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final int eq = trimmed.indexOf('=');
      if (eq <= 0) {
        throw StateError(
          'Invalid CERT_PINNING_PINS entry "$trimmed". '
          'Expected host=sha256/PIN|sha256/PIN2',
        );
      }
      final String host = trimmed.substring(0, eq).trim();
      final Set<String> pins = trimmed
          .substring(eq + 1)
          .split('|')
          .map((final p) => p.trim())
          .where((final p) => p.isNotEmpty)
          .toSet();
      out[host] = pins;
    }
    return out;
  }

  @visibleForTesting
  static CertificatePinningMode parseModeForTest(final String raw) => _parseMode(raw);

  @visibleForTesting
  static CertificatePinHashKind parseHashKindForTest(final String raw) => _parseHashKind(raw);

  @visibleForTesting
  static Set<String> parseHostsForTest(final String raw) => _parseHosts(raw);

  @visibleForTesting
  static Map<String, Set<String>> parsePinsForTest(final String raw) => _parsePins(raw);
}
