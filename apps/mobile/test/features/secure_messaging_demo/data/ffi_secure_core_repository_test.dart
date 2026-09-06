import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc_app/features/secure_messaging_demo/data/ffi_secure_core_repository.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_core_bridge/secure_core_bridge.dart';

final class _FakeNativeApi implements SecureCoreNativeApi {
  _FakeNativeApi({this.throwKind, this.decryptBytes});

  SecureCoreNativeFailureKind? throwKind;
  Uint8List? decryptBytes;
  Uint8List? encryptedInput;

  @override
  Uint8List encrypt(Uint8List plaintext) {
    if (throwKind != null) {
      throw SecureCoreNativeException(throwKind!);
    }
    encryptedInput = Uint8List.fromList(plaintext);
    return Uint8List.fromList(<int>[9, ...plaintext]);
  }

  @override
  Uint8List decrypt(Uint8List ciphertextEnvelope) {
    if (throwKind != null) {
      throw SecureCoreNativeException(throwKind!);
    }
    return decryptBytes ?? Uint8List.fromList(ciphertextEnvelope.sublist(1));
  }

  @override
  bool healthCheck() {
    if (throwKind != null) {
      throw SecureCoreNativeException(throwKind!);
    }
    return true;
  }

  @override
  String version() {
    if (throwKind != null) {
      throw SecureCoreNativeException(throwKind!);
    }
    return '0.1.0';
  }
}

void main() {
  test('round trip maps UTF-8 and base64', () async {
    final FfiSecureCoreRepository repo = FfiSecureCoreRepository(
      _FakeNativeApi(),
    );
    final EncryptedPayload payload = await repo.encrypt('merhaba');
    expect(payload.base64Envelope, isNotEmpty);
    final String recovered = await repo.decrypt(payload);
    expect(recovered, 'merhaba');
  });

  test('round trip preserves leading and trailing whitespace', () async {
    final _FakeNativeApi native = _FakeNativeApi();
    final FfiSecureCoreRepository repo = FfiSecureCoreRepository(native);
    const String original = '  merhaba secure core  ';

    final EncryptedPayload payload = await repo.encrypt(original);

    expect(utf8.decode(native.encryptedInput!), original);
    expect(await repo.decrypt(payload), original);
  });

  test('maps authentication failed', () async {
    final FfiSecureCoreRepository repo = FfiSecureCoreRepository(
      _FakeNativeApi(
        throwKind: SecureCoreNativeFailureKind.authenticationFailed,
      ),
    );
    expect(
      () => repo.decrypt(EncryptedPayload(base64Encode(utf8.encode('x')))),
      throwsA(isA<SecureCoreAuthenticationFailedFailure>()),
    );
  });

  test('rejects blank plaintext', () async {
    final FfiSecureCoreRepository repo = FfiSecureCoreRepository(
      _FakeNativeApi(),
    );
    expect(
      () => repo.encrypt('  '),
      throwsA(isA<SecureCoreInvalidInputFailure>()),
    );
  });

  test('maps every native failure into a domain failure', () async {
    final List<(SecureCoreNativeFailureKind, Type)>
    cases = <(SecureCoreNativeFailureKind, Type)>[
      (SecureCoreNativeFailureKind.invalidInput, SecureCoreInvalidInputFailure),
      (
        SecureCoreNativeFailureKind.malformedCiphertext,
        SecureCoreMalformedCiphertextFailure,
      ),
      (
        SecureCoreNativeFailureKind.authenticationFailed,
        SecureCoreAuthenticationFailedFailure,
      ),
      (
        SecureCoreNativeFailureKind.unsupportedVersion,
        SecureCoreUnsupportedVersionFailure,
      ),
      (SecureCoreNativeFailureKind.unavailable, SecureCoreUnavailableFailure),
      (SecureCoreNativeFailureKind.internal, SecureCoreInternalFailure),
    ];

    for (final (SecureCoreNativeFailureKind kind, Type expectedType) in cases) {
      final FfiSecureCoreRepository repo = FfiSecureCoreRepository(
        _FakeNativeApi(throwKind: kind),
      );
      await expectLater(
        repo.decrypt(const EncryptedPayload('eA==')),
        throwsA(predicate((Object error) => error.runtimeType == expectedType)),
        reason: kind.name,
      );
    }
  });

  test('maps malformed base64 to malformed ciphertext', () async {
    final FfiSecureCoreRepository repo = FfiSecureCoreRepository(
      _FakeNativeApi(),
    );

    await expectLater(
      repo.decrypt(const EncryptedPayload('not base64!')),
      throwsA(isA<SecureCoreMalformedCiphertextFailure>()),
    );
  });

  test('maps invalid decrypted UTF-8 to malformed ciphertext', () async {
    final FfiSecureCoreRepository repo = FfiSecureCoreRepository(
      _FakeNativeApi(decryptBytes: Uint8List.fromList(<int>[0xFF])),
    );

    await expectLater(
      repo.decrypt(const EncryptedPayload('eA==')),
      throwsA(isA<SecureCoreMalformedCiphertextFailure>()),
    );
  });
}
