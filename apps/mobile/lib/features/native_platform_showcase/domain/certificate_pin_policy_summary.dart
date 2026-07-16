import 'package:freezed_annotation/freezed_annotation.dart';

part 'certificate_pin_policy_summary.freezed.dart';

/// Summary of the app's certificate pinning policy for display only.
///
/// Never carries raw pin/certificate material — counts and labels only.
@freezed
abstract class CertificatePinPolicySummary with _$CertificatePinPolicySummary {
  const factory CertificatePinPolicySummary({
    required String modeName,
    required String pinHashKindName,
    required int configuredHostCount,
    required int primaryPinCount,
    required int backupPinCount,
    required bool canOpenMutableDemo,
  }) = _CertificatePinPolicySummary;
}
