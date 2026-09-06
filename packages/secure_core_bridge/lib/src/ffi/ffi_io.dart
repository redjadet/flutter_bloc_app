import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:secure_core_bridge/src/ffi/generated_bindings.dart';
import 'package:secure_core_bridge/src/native_api.dart';
import 'package:secure_core_bridge/src/secure_core_native_exception.dart';

const int _maxPlaintextLength = 64 * 1024;
const int _minEnvelopeLength = 1 + 12 + 16;
const int _maxEnvelopeLength = _minEnvelopeLength + _maxPlaintextLength;

SecureCoreNativeApi createPlatformSecureCoreNativeApi() =>
    FfiSecureCoreNativeApi();

final class FfiSecureCoreNativeApi implements SecureCoreNativeApi {
  FfiSecureCoreNativeApi();

  @override
  Uint8List encrypt(Uint8List plaintext) {
    if (plaintext.isEmpty || plaintext.length > _maxPlaintextLength) {
      throw const SecureCoreNativeException(
        SecureCoreNativeFailureKind.invalidInput,
      );
    }
    return _withNativeBytes(plaintext, secure_core_encrypt);
  }

  @override
  Uint8List decrypt(Uint8List ciphertextEnvelope) {
    if (ciphertextEnvelope.length < _minEnvelopeLength ||
        ciphertextEnvelope.length > _maxEnvelopeLength) {
      throw const SecureCoreNativeException(
        SecureCoreNativeFailureKind.malformedCiphertext,
      );
    }
    return _withNativeBytes(ciphertextEnvelope, secure_core_decrypt);
  }

  @override
  bool healthCheck() {
    final int status = secure_core_health_check();
    if (status == SecureCoreStatus.SECURE_CORE_STATUS_OK.value) {
      return true;
    }
    throw _exceptionForStatus(status);
  }

  @override
  String version() {
    final SecureCoreBuffer buffer = secure_core_version();
    try {
      _throwIfFailed(buffer);
      if (buffer.data == nullptr || buffer.len == 0) {
        throw const SecureCoreNativeException(
          SecureCoreNativeFailureKind.internal,
        );
      }
      final Uint8List bytes = buffer.data.asTypedList(buffer.len);
      return utf8.decode(Uint8List.fromList(bytes));
    } finally {
      secure_core_buffer_free(buffer);
    }
  }

  Uint8List _withNativeBytes(
    Uint8List input,
    SecureCoreBuffer Function(Pointer<Uint8>, int) nativeCall,
  ) {
    final Pointer<Uint8> pointer = malloc<Uint8>(input.length);
    final Uint8List nativeInput = pointer.asTypedList(input.length);
    try {
      nativeInput.setAll(0, input);
      final SecureCoreBuffer buffer = nativeCall(pointer, input.length);
      try {
        _throwIfFailed(buffer);
        if (buffer.data == nullptr || buffer.len == 0) {
          throw const SecureCoreNativeException(
            SecureCoreNativeFailureKind.internal,
          );
        }
        return Uint8List.fromList(buffer.data.asTypedList(buffer.len));
      } finally {
        secure_core_buffer_free(buffer);
      }
    } finally {
      nativeInput.fillRange(0, nativeInput.length, 0);
      malloc.free(pointer);
    }
  }

  void _throwIfFailed(SecureCoreBuffer buffer) {
    if (buffer.status == SecureCoreStatus.SECURE_CORE_STATUS_OK.value) {
      return;
    }
    throw _exceptionForStatus(buffer.status);
  }

  SecureCoreNativeException _exceptionForStatus(int status) {
    final SecureCoreStatus code = _statusFromInt(status);
    final SecureCoreNativeFailureKind kind = switch (code) {
      SecureCoreStatus.SECURE_CORE_STATUS_INVALID_INPUT =>
        SecureCoreNativeFailureKind.invalidInput,
      SecureCoreStatus.SECURE_CORE_STATUS_MALFORMED_CIPHERTEXT =>
        SecureCoreNativeFailureKind.malformedCiphertext,
      SecureCoreStatus.SECURE_CORE_STATUS_AUTHENTICATION_FAILED =>
        SecureCoreNativeFailureKind.authenticationFailed,
      SecureCoreStatus.SECURE_CORE_STATUS_UNSUPPORTED_VERSION =>
        SecureCoreNativeFailureKind.unsupportedVersion,
      SecureCoreStatus.SECURE_CORE_STATUS_UNAVAILABLE =>
        SecureCoreNativeFailureKind.unavailable,
      SecureCoreStatus.SECURE_CORE_STATUS_OK ||
      SecureCoreStatus.SECURE_CORE_STATUS_INTERNAL =>
        SecureCoreNativeFailureKind.internal,
    };
    return SecureCoreNativeException(kind, statusCode: status);
  }

  SecureCoreStatus _statusFromInt(int status) {
    try {
      return SecureCoreStatus.fromValue(status);
    } on ArgumentError {
      return SecureCoreStatus.SECURE_CORE_STATUS_INTERNAL;
    }
  }
}
