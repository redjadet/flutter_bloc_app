import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:networking/networking.dart';

/// Maps [CertificatePinningConfig] to a display-only [CertificatePinPolicySummary].
///
/// Never exposes raw pins/hosts — counts and enum-name labels only.
abstract final class CertificatePinPolicySummaryMapper {
  static CertificatePinPolicySummary fromConfig(
    final CertificatePinningConfig config, {
    required final bool canOpenMutableDemo,
  }) {
    final int hosts = config.allowedHosts.length;
    final int totalPins = List<Set<String>>.from(
      config.sha256PinsByHost.values,
    ).fold<int>(0, (final sum, final pins) => sum + pins.length);
    return CertificatePinPolicySummary(
      modeName: config.mode.name,
      pinHashKindName: config.pinHashKind.name,
      configuredHostCount: hosts,
      // Pinning config intentionally stores an unordered set without rotation
      // roles. Show the exact total rather than inventing primary/backup roles.
      primaryPinCount: totalPins,
      backupPinCount: 0,
      canOpenMutableDemo: canOpenMutableDemo,
    );
  }
}
