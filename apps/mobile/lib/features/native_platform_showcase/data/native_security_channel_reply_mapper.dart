import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';

/// Maps raw native channel replies to [NativeSecurityOperationResult].
///
/// Only allowlisted keys and wire-string values are copied into the result;
/// unexpected fields are silently ignored (never echoed into Dart state/UI/logs).
/// Malformed payloads (non-`Map`, wrong/missing `schemaVersion`, unknown
/// `status`/`reasonCode`, or success with failed verify flags) map to
/// `failed`/`malformed_reply` or `failed`/`platform_error`.
abstract final class NativeSecurityChannelReplyMapper {
  static const int supportedSchemaVersion = 1;

  static const Set<String> allowedReasonCodes = <String>{
    'ok',
    'mobile_only',
    'missing_plugin',
    'timeout',
    'malformed_reply',
    'platform_error',
    'secure_enclave_unavailable',
    'keystore_unavailable',
    'biometric_not_enrolled',
    'biometric_lockout',
    'biometric_canceled',
    'biometric_unsupported',
    'concurrent_prompt',
    'not_configured_or_token_null',
    'app_check_error',
  };

  /// Reason codes that may arrive as a PlatformException code from the native
  /// channel. Success / short-circuit / App Check codes are excluded so a
  /// hostile or buggy host cannot paint `Failed • OK` via exception codes.
  static const Set<String> allowedPlatformExceptionCodes = <String>{
    'missing_plugin',
    'timeout',
    'malformed_reply',
    'platform_error',
    'secure_enclave_unavailable',
    'keystore_unavailable',
    'biometric_not_enrolled',
    'biometric_lockout',
    'biometric_canceled',
    'biometric_unsupported',
    'concurrent_prompt',
  };

  static const Set<String> allowedPlatforms = <String>{
    'android',
    'ios',
    'unknown',
  };

  static const Set<String> allowedAlgorithms = <String>{'P256', 'AES-GCM'};

  static NativeSecurityOperationResult fromChannelReply(
    final Object? reply, {
    final NativeSecurityOperation? operation,
  }) {
    if (reply is! Map) {
      return const NativeSecurityOperationResult(
        status: NativeSecurityStatus.failed,
        reasonCode: 'malformed_reply',
        platform: 'unknown',
      );
    }

    final Map<String, Object?> map = reply.map(
      (final key, final value) => MapEntry(key.toString(), value),
    );

    final Object? schemaVersion = map['schemaVersion'];
    if (schemaVersion is! int || schemaVersion != supportedSchemaVersion) {
      return NativeSecurityOperationResult(
        status: NativeSecurityStatus.failed,
        reasonCode: 'malformed_reply',
        platform: _platformOrUnknown(map['platform']),
      );
    }

    final NativeSecurityStatus? status = _parseStatus(map['status']);
    final Object? reasonCodeRaw = map['reasonCode'];
    if (status == null ||
        reasonCodeRaw is! String ||
        reasonCodeRaw.isEmpty ||
        !allowedReasonCodes.contains(reasonCodeRaw)) {
      return NativeSecurityOperationResult(
        status: NativeSecurityStatus.failed,
        reasonCode: 'malformed_reply',
        platform: _platformOrUnknown(map['platform']),
      );
    }

    final bool? verified = _boolOrNull(map['verified']);
    final bool? wrote = _boolOrNull(map['wrote']);
    final bool? readMatched = _boolOrNull(map['readMatched']);
    final bool? deleted = _boolOrNull(map['deleted']);

    NativeSecurityStatus resolvedStatus = status;
    String resolvedReason = reasonCodeRaw;
    if (status == NativeSecurityStatus.success &&
        (!_operationChecksPassed(
              verified: verified,
              wrote: wrote,
              readMatched: readMatched,
              deleted: deleted,
            ) ||
            !_requiredChecksArePresent(
              operation: operation,
              verified: verified,
              wrote: wrote,
              readMatched: readMatched,
              deleted: deleted,
            ))) {
      resolvedStatus = NativeSecurityStatus.failed;
      resolvedReason = 'platform_error';
    }

    return NativeSecurityOperationResult(
      status: resolvedStatus,
      reasonCode: resolvedReason,
      platform: _platformOrUnknown(map['platform']),
      keyResidency: _parseResidency(map['keyResidency']),
      hardwareBacked: _boolOrNull(map['hardwareBacked']),
      algorithm: _parseAlgorithm(map['algorithm']),
      verified: verified,
      challengeByteCount: _intOrNull(map['challengeByteCount']),
      ciphertextByteCount: _intOrNull(map['ciphertextByteCount']),
      plaintextByteCount: _intOrNull(map['plaintextByteCount']),
      aadByteCount: _intOrNull(map['aadByteCount']),
      wrote: wrote,
      readMatched: readMatched,
      deleted: deleted,
    );
  }

  /// Requires evidence for known operations before accepting a native success.
  /// A generic mapper call may omit the operation for isolated schema tests.
  static bool _requiredChecksArePresent({
    required final NativeSecurityOperation? operation,
    required final bool? verified,
    required final bool? wrote,
    required final bool? readMatched,
    required final bool? deleted,
  }) => switch (operation) {
    null => true,
    NativeSecurityOperation.p256SignVerify ||
    NativeSecurityOperation.aesGcmRoundTrip ||
    NativeSecurityOperation.biometricProtectedOperation => verified == true,
    NativeSecurityOperation.secureStorageLifecycle =>
      wrote == true && readMatched == true && deleted == true,
  };

  /// True when no check flags are present, or all present flags are true.
  static bool _operationChecksPassed({
    required final bool? verified,
    required final bool? wrote,
    required final bool? readMatched,
    required final bool? deleted,
  }) {
    if (verified == false) {
      return false;
    }
    if (wrote == false || readMatched == false || deleted == false) {
      return false;
    }
    return true;
  }

  static NativeSecurityStatus? _parseStatus(final Object? raw) {
    if (raw is! String) {
      return null;
    }
    return switch (raw) {
      'success' => NativeSecurityStatus.success,
      'unavailable' => NativeSecurityStatus.unavailable,
      'denied' => NativeSecurityStatus.denied,
      'failed' => NativeSecurityStatus.failed,
      _ => null,
    };
  }

  static NativeSecurityKeyResidency? _parseResidency(final Object? raw) {
    if (raw is! String) {
      return null;
    }
    return switch (raw) {
      'secure_enclave' => NativeSecurityKeyResidency.secureEnclave,
      'android_keystore' => NativeSecurityKeyResidency.androidKeystore,
      'keychain' => NativeSecurityKeyResidency.keychain,
      'software' => NativeSecurityKeyResidency.software,
      'unknown' => NativeSecurityKeyResidency.unknown,
      _ => null,
    };
  }

  static String _platformOrUnknown(final Object? raw) {
    if (raw is String && allowedPlatforms.contains(raw)) {
      return raw;
    }
    return 'unknown';
  }

  static String? _parseAlgorithm(final Object? raw) {
    if (raw is! String) {
      return null;
    }
    return allowedAlgorithms.contains(raw) ? raw : null;
  }

  static bool? _boolOrNull(final Object? raw) => raw is bool ? raw : null;

  static int? _intOrNull(final Object? raw) =>
      raw is int && raw >= 0 ? raw : null;
}
