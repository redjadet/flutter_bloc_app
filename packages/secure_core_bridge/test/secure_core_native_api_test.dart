import 'dart:convert';
import 'dart:typed_data';

import 'package:secure_core_bridge/secure_core_bridge.dart';
import 'package:test/test.dart';

void main() {
  final SecureCoreNativeApi api = createSecureCoreNativeApi();

  test('health check and version', () {
    expect(api.healthCheck(), isTrue);
    expect(api.version(), isNotEmpty);
  });

  test('encrypt decrypt round trip preserves UTF-8', () {
    final Uint8List plaintext = Uint8List.fromList(
      utf8.encode('hello secure core 🔐'),
    );
    final Uint8List envelope = api.encrypt(plaintext);
    expect(envelope.length, greaterThan(plaintext.length));
    final Uint8List recovered = api.decrypt(envelope);
    expect(utf8.decode(recovered), 'hello secure core 🔐');
  });

  test('empty plaintext rejected', () {
    expect(
      () => api.encrypt(Uint8List(0)),
      throwsA(
        isA<SecureCoreNativeException>().having(
          (SecureCoreNativeException e) => e.kind,
          'kind',
          SecureCoreNativeFailureKind.invalidInput,
        ),
      ),
    );
  });

  test('oversized plaintext rejected before FFI', () {
    expect(
      () => api.encrypt(Uint8List(64 * 1024 + 1)),
      throwsA(
        isA<SecureCoreNativeException>().having(
          (SecureCoreNativeException e) => e.kind,
          'kind',
          SecureCoreNativeFailureKind.invalidInput,
        ),
      ),
    );
  });

  test('oversized envelope rejected before FFI', () {
    expect(
      () => api.decrypt(Uint8List(64 * 1024 + 1 + 12 + 16 + 1)),
      throwsA(
        isA<SecureCoreNativeException>().having(
          (SecureCoreNativeException e) => e.kind,
          'kind',
          SecureCoreNativeFailureKind.malformedCiphertext,
        ),
      ),
    );
  });

  test('bit-flipped envelope fails authentication', () {
    final Uint8List envelope = api.encrypt(
      Uint8List.fromList(utf8.encode('payload')),
    );
    final Uint8List corrupted = Uint8List.fromList(envelope);
    corrupted[corrupted.length - 1] ^= 0x01;
    expect(
      () => api.decrypt(corrupted),
      throwsA(
        isA<SecureCoreNativeException>().having(
          (SecureCoreNativeException e) => e.kind,
          'kind',
          SecureCoreNativeFailureKind.authenticationFailed,
        ),
      ),
    );
  });
}
