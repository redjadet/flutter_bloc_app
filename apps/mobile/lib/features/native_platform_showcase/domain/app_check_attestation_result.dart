import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_check_attestation_result.freezed.dart';

enum AppCheckAttestationStatus { issued, unavailable, failed }

/// Evidence that a cached App Check token was (or was not) obtainable.
///
/// Never carries the token string itself — client-side evidence only.
@freezed
abstract class AppCheckAttestationResult with _$AppCheckAttestationResult {
  const factory AppCheckAttestationResult({
    required AppCheckAttestationStatus status,
    required String providerLabel,
    required String reasonCode,
  }) = _AppCheckAttestationResult;
}
