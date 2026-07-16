import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_security_operation_result.freezed.dart';

/// Result of a native security channel operation.
///
/// Never carries raw key material, ciphertext, tokens, or challenges — only
/// status/reason codes, residency labels, and byte counts. See
/// `docs/changes/2026-07-15_native_security_showcase.md` for the wire
/// protocol this mirrors.
@freezed
abstract class NativeSecurityOperationResult
    with _$NativeSecurityOperationResult {
  const factory NativeSecurityOperationResult({
    required NativeSecurityStatus status,
    required String reasonCode,
    required String platform,
    NativeSecurityKeyResidency? keyResidency,
    bool? hardwareBacked,
    String? algorithm,
    bool? verified,
    int? challengeByteCount,
    int? ciphertextByteCount,
    int? plaintextByteCount,
    int? aadByteCount,
    bool? wrote,
    bool? readMatched,
    bool? deleted,
  }) = _NativeSecurityOperationResult;
}
