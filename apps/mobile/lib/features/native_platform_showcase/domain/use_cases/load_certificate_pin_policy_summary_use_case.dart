import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:networking/networking.dart';

/// Builds a [CertificatePinPolicySummary] from the app's pinning config.
///
/// Domain must not depend on the feature's `data/` layer (Clean
/// Architecture gate), so the concrete mapping function is injected by the
/// composition root from `data/certificate_pin_policy_summary_mapper.dart`.
typedef CertificatePinPolicySummaryBuilder =
    CertificatePinPolicySummary Function(
      CertificatePinningConfig config, {
      required bool canOpenMutableDemo,
    });

class LoadCertificatePinPolicySummaryUseCase {
  const LoadCertificatePinPolicySummaryUseCase(this._build);

  final CertificatePinPolicySummaryBuilder _build;

  CertificatePinPolicySummary call(
    final CertificatePinningConfig config, {
    required final bool canOpenMutableDemo,
  }) => _build(config, canOpenMutableDemo: canOpenMutableDemo);
}
