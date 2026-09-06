import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_failure.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_repository.dart';
import 'package:secure_core_bridge/secure_core_bridge.dart';

final class FfiSecureCoreRepository implements SecureCoreRepository {
  FfiSecureCoreRepository(this._nativeApi);

  final SecureCoreNativeApi _nativeApi;

  @override
  Future<EncryptedPayload> encrypt(String plaintext) async {
    if (plaintext.trim().isEmpty) {
      throw SecureCoreFailures.invalidInput;
    }
    final Uint8List bytes = Uint8List.fromList(utf8.encode(plaintext));
    try {
      final Uint8List envelope = _nativeApi.encrypt(bytes);
      return EncryptedPayload(base64Encode(envelope));
    } on SecureCoreNativeException catch (error) {
      throw _mapNative(error);
    } on FormatException {
      throw SecureCoreFailures.invalidInput;
    } on Object {
      throw SecureCoreFailures.internal;
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
  }

  @override
  Future<String> decrypt(EncryptedPayload ciphertext) async {
    try {
      final Uint8List envelope = base64Decode(ciphertext.base64Envelope);
      final Uint8List plaintext = _nativeApi.decrypt(envelope);
      try {
        return utf8.decode(plaintext);
      } finally {
        plaintext.fillRange(0, plaintext.length, 0);
      }
    } on SecureCoreNativeException catch (error) {
      throw _mapNative(error);
    } on FormatException {
      throw SecureCoreFailures.malformedCiphertext;
    } on Object {
      throw SecureCoreFailures.internal;
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      return _nativeApi.healthCheck();
    } on SecureCoreNativeException catch (error) {
      throw _mapNative(error);
    } on Object {
      throw SecureCoreFailures.internal;
    }
  }

  @override
  Future<String> version() async {
    try {
      return _nativeApi.version();
    } on SecureCoreNativeException catch (error) {
      throw _mapNative(error);
    } on Object {
      throw SecureCoreFailures.internal;
    }
  }

  SecureCoreFailure _mapNative(SecureCoreNativeException error) {
    return switch (error.kind) {
      SecureCoreNativeFailureKind.invalidInput =>
        SecureCoreFailures.invalidInput,
      SecureCoreNativeFailureKind.malformedCiphertext =>
        SecureCoreFailures.malformedCiphertext,
      SecureCoreNativeFailureKind.authenticationFailed =>
        SecureCoreFailures.authenticationFailed,
      SecureCoreNativeFailureKind.unsupportedVersion =>
        SecureCoreFailures.unsupportedVersion,
      SecureCoreNativeFailureKind.unavailable => SecureCoreFailures.unavailable,
      SecureCoreNativeFailureKind.internal => SecureCoreFailures.internal,
    };
  }
}
