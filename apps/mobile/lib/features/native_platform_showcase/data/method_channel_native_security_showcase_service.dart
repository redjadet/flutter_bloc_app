import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/native_security_channel_reply_mapper.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_showcase_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';

/// MethodChannel implementation of [NativeSecurityShowcaseService].
///
/// Android Keystore / biometric and iOS CryptoKit / Keychain / LocalAuth own
/// all key material; this adapter only ever sees status/reason codes,
/// residency labels, and byte counts (see [NativeSecurityChannelReplyMapper]).
class MethodChannelNativeSecurityShowcaseService
    implements NativeSecurityShowcaseService {
  const MethodChannelNativeSecurityShowcaseService({
    final MethodChannel? channel,
    this.invokeTimeout = const Duration(seconds: 2),
    this.biometricInvokeTimeout = const Duration(seconds: 60),
  }) : _channel =
           channel ??
           const MethodChannel(
             'com.example.flutter_bloc_app/native_security_showcase',
           );

  /// Deadline for non-interactive crypto/storage channel calls.
  final Duration invokeTimeout;

  /// Deadline for biometric-gated calls (user may need tens of seconds).
  final Duration biometricInvokeTimeout;

  final MethodChannel _channel;

  @override
  Future<NativeSecurityOperationResult> run(
    final NativeSecurityOperation operation,
  ) async {
    if (!_isMobile) {
      return const NativeSecurityOperationResult(
        status: NativeSecurityStatus.unavailable,
        reasonCode: 'mobile_only',
        platform: 'unknown',
      );
    }

    try {
      final Object? reply = await _channel
          .invokeMethod<Object?>(_methodNameFor(operation))
          .timeout(
            _timeoutFor(operation),
            onTimeout: () => throw TimeoutException(
              'Native security handler did not respond in time.',
            ),
          );
      return NativeSecurityChannelReplyMapper.fromChannelReply(
        reply,
        operation: operation,
      );
    } on TimeoutException {
      return const NativeSecurityOperationResult(
        status: NativeSecurityStatus.unavailable,
        reasonCode: 'timeout',
        platform: 'unknown',
      );
    } on MissingPluginException {
      return const NativeSecurityOperationResult(
        status: NativeSecurityStatus.unavailable,
        reasonCode: 'missing_plugin',
        platform: 'unknown',
      );
    } on PlatformException catch (error) {
      final String code =
          NativeSecurityChannelReplyMapper.allowedPlatformExceptionCodes
              .contains(error.code)
          ? error.code
          : 'platform_error';
      return NativeSecurityOperationResult(
        status: _statusForPlatformExceptionCode(code),
        reasonCode: code,
        platform: 'unknown',
      );
    } on Object {
      return const NativeSecurityOperationResult(
        status: NativeSecurityStatus.failed,
        reasonCode: 'platform_error',
        platform: 'unknown',
      );
    }
  }

  Duration _timeoutFor(final NativeSecurityOperation operation) =>
      operation == NativeSecurityOperation.biometricProtectedOperation
      ? biometricInvokeTimeout
      : invokeTimeout;

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String _methodNameFor(final NativeSecurityOperation operation) =>
      switch (operation) {
        NativeSecurityOperation.p256SignVerify => 'p256SignVerify',
        NativeSecurityOperation.aesGcmRoundTrip => 'aesGcmRoundTrip',
        NativeSecurityOperation.secureStorageLifecycle =>
          'secureStorageLifecycle',
        NativeSecurityOperation.biometricProtectedOperation =>
          'biometricProtectedOperation',
      };

  static NativeSecurityStatus _statusForPlatformExceptionCode(
    final String code,
  ) => switch (code) {
    'biometric_canceled' => NativeSecurityStatus.denied,
    'biometric_lockout' => NativeSecurityStatus.denied,
    'biometric_not_enrolled' => NativeSecurityStatus.unavailable,
    'biometric_unsupported' => NativeSecurityStatus.unavailable,
    'secure_enclave_unavailable' => NativeSecurityStatus.unavailable,
    'keystore_unavailable' => NativeSecurityStatus.unavailable,
    'concurrent_prompt' => NativeSecurityStatus.failed,
    _ => NativeSecurityStatus.failed,
  };
}
