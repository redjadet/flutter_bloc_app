import 'dart:collection';

import 'certificate_pin_formatter.dart';
import 'certificate_pin_hash_kind.dart';
import 'certificate_pinning_mode.dart';

/// Immutable certificate pinning configuration.
final class CertificatePinningConfig {
  CertificatePinningConfig({
    required this.mode,
    final Set<String>? allowedHosts,
    final Map<String, Set<String>>? sha256PinsByHost,
    this.validationTimeout = const Duration(seconds: 2),
    this.enableVerboseLogging = false,
    this.realProbeUrl,
    this.pinHashKind = CertificatePinHashKind.spki,
  }) : allowedHosts = UnmodifiableSetView<String>(
         Set<String>.unmodifiable(
           (allowedHosts ?? const <String>{}).map(normalizeHost),
         ),
       ),
       sha256PinsByHost = _freezePins(sha256PinsByHost);

  /// Safe default: pinning off for all flavors until explicitly enabled.
  factory CertificatePinningConfig.disabled({
    final bool enableVerboseLogging = false,
  }) => CertificatePinningConfig(
    mode: CertificatePinningMode.disabled,
    enableVerboseLogging: enableVerboseLogging,
  );

  final CertificatePinningMode mode;
  final Set<String> allowedHosts;
  final Map<String, Set<String>> sha256PinsByHost;
  final Duration validationTimeout;
  final bool enableVerboseLogging;
  final String? realProbeUrl;

  /// Material hashed for pin comparison. Defaults to SPKI.
  final CertificatePinHashKind pinHashKind;

  /// DNS hosts compared case-insensitively (lowercase ASCII).
  static String normalizeHost(final String host) => host.trim().toLowerCase();

  /// Fail closed for unsafe production / incomplete configuration.
  void validate({required final bool isProdRelease, final bool isWeb = false}) {
    if (isProdRelease &&
        (mode == CertificatePinningMode.mockSuccess ||
            mode == CertificatePinningMode.mockFailure)) {
      throw StateError(
        'Certificate pinning mock modes are forbidden in production release '
        'builds (mode=$mode).',
      );
    }

    if (mode != CertificatePinningMode.real) {
      return;
    }

    if (isWeb) {
      throw StateError(
        'Certificate pinning mode=real is not supported on web '
        '(dart:io adapter unavailable). Use disabled or a native target.',
      );
    }

    if (allowedHosts.isEmpty) {
      throw StateError(
        'Certificate pinning mode=real requires at least one allowed host.',
      );
    }

    for (final String host in allowedHosts) {
      final Set<String>? pins = sha256PinsByHost[host];
      if (pins == null || pins.isEmpty) {
        throw StateError(
          'Certificate pinning mode=real requires pins for host "$host".',
        );
      }
      for (final String pin in pins) {
        if (!CertificatePinFormatter.isValidFormat(pin)) {
          throw StateError(
            'Invalid certificate pin format for host "$host". '
            'Expected sha256/<base64>.',
          );
        }
      }
    }

    for (final String host in sha256PinsByHost.keys) {
      if (!allowedHosts.contains(host)) {
        throw StateError(
          'Pin map contains host "$host" that is not in allowedHosts.',
        );
      }
    }
  }

  static Map<String, Set<String>> _freezePins(
    final Map<String, Set<String>>? source,
  ) {
    if (source == null || source.isEmpty) {
      return const <String, Set<String>>{};
    }
    final Map<String, Set<String>> frozen = <String, Set<String>>{};
    for (final MapEntry<String, Set<String>> entry in source.entries) {
      final String host = normalizeHost(entry.key);
      final List<String> ordered = entry.value
          .map(CertificatePinFormatter.canonicalize)
          .toList(growable: false);
      frozen[host] = UnmodifiableSetView<String>(
        LinkedHashSet<String>.from(ordered),
      );
    }
    return UnmodifiableMapView<String, Set<String>>(frozen);
  }
}
