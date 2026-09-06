import 'dart:typed_data';

/// Byte-oriented native facade. Implementations live behind conditional imports.
abstract interface class SecureCoreNativeApi {
  Uint8List encrypt(Uint8List plaintext);

  Uint8List decrypt(Uint8List ciphertextEnvelope);

  bool healthCheck();

  String version();
}
