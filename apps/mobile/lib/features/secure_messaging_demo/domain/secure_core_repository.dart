import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';

abstract interface class SecureCoreRepository {
  Future<EncryptedPayload> encrypt(String plaintext);

  Future<String> decrypt(EncryptedPayload ciphertext);

  Future<bool> healthCheck();

  Future<String> version();
}
