import 'package:secure_core_bridge/src/native_api.dart';
import 'package:secure_core_bridge/src/secure_core_native_exception.dart';

import 'dart:typed_data';

SecureCoreNativeApi createPlatformSecureCoreNativeApi() =>
    const _UnavailableSecureCoreNativeApi();

final class _UnavailableSecureCoreNativeApi implements SecureCoreNativeApi {
  const _UnavailableSecureCoreNativeApi();

  Never _unavailable() {
    throw const SecureCoreNativeException(
      SecureCoreNativeFailureKind.unavailable,
    );
  }

  @override
  Uint8List encrypt(Uint8List plaintext) => _unavailable();

  @override
  Uint8List decrypt(Uint8List ciphertextEnvelope) => _unavailable();

  @override
  bool healthCheck() => _unavailable();

  @override
  String version() => _unavailable();
}
