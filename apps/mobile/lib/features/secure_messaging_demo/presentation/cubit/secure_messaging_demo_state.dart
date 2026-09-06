import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_failure.dart';

sealed class SecureMessagingDemoState {
  const SecureMessagingDemoState();

  String? get version => switch (this) {
    SecureMessagingDemoReady(:final version) ||
    SecureMessagingDemoEncrypting(:final version) ||
    SecureMessagingDemoEncrypted(:final version) ||
    SecureMessagingDemoDecrypting(:final version) ||
    SecureMessagingDemoSuccess(:final version) => version,
    SecureMessagingDemoFailure(:final version) => version,
    _ => null,
  };

  String get plaintext => switch (this) {
    SecureMessagingDemoReady(:final plaintext) ||
    SecureMessagingDemoEncrypting(:final plaintext) ||
    SecureMessagingDemoEncrypted(:final plaintext) ||
    SecureMessagingDemoDecrypting(:final plaintext) ||
    SecureMessagingDemoSuccess(:final plaintext) ||
    SecureMessagingDemoFailure(:final plaintext) => plaintext,
    _ => '',
  };

  EncryptedPayload? get payload => switch (this) {
    SecureMessagingDemoEncrypted(:final payload) ||
    SecureMessagingDemoDecrypting(:final payload) ||
    SecureMessagingDemoSuccess(:final payload) => payload,
    SecureMessagingDemoFailure(:final payload) => payload,
    _ => null,
  };

  String? get recoveredPlaintext => switch (this) {
    SecureMessagingDemoSuccess(:final recoveredPlaintext) => recoveredPlaintext,
    _ => null,
  };

  bool get isProcessing =>
      this is SecureMessagingDemoEncrypting ||
      this is SecureMessagingDemoDecrypting ||
      this is SecureMessagingDemoCheckingHealth;

  bool get isUnavailable => this is SecureMessagingDemoUnavailable;
}

final class SecureMessagingDemoInitial extends SecureMessagingDemoState {
  const SecureMessagingDemoInitial();
}

final class SecureMessagingDemoCheckingHealth extends SecureMessagingDemoState {
  const SecureMessagingDemoCheckingHealth();
}

final class SecureMessagingDemoReady extends SecureMessagingDemoState {
  const SecureMessagingDemoReady({required this.version, this.plaintext = ''});

  @override
  final String version;
  @override
  final String plaintext;
}

final class SecureMessagingDemoEncrypting extends SecureMessagingDemoState {
  const SecureMessagingDemoEncrypting({
    required this.version,
    required this.plaintext,
  });

  @override
  final String version;
  @override
  final String plaintext;
}

final class SecureMessagingDemoEncrypted extends SecureMessagingDemoState {
  const SecureMessagingDemoEncrypted({
    required this.version,
    required this.plaintext,
    required this.payload,
  });

  @override
  final String version;
  @override
  final String plaintext;
  @override
  final EncryptedPayload payload;
}

final class SecureMessagingDemoDecrypting extends SecureMessagingDemoState {
  const SecureMessagingDemoDecrypting({
    required this.version,
    required this.plaintext,
    required this.payload,
  });

  @override
  final String version;
  @override
  final String plaintext;
  @override
  final EncryptedPayload payload;
}

final class SecureMessagingDemoSuccess extends SecureMessagingDemoState {
  const SecureMessagingDemoSuccess({
    required this.version,
    required this.plaintext,
    required this.payload,
    required this.recoveredPlaintext,
  });

  @override
  final String version;
  @override
  final String plaintext;
  @override
  final EncryptedPayload payload;
  @override
  final String recoveredPlaintext;
}

final class SecureMessagingDemoFailure extends SecureMessagingDemoState {
  const SecureMessagingDemoFailure({
    required this.failure,
    this.version,
    this.plaintext = '',
    this.payload,
  });

  final SecureCoreFailure failure;
  @override
  final String? version;
  @override
  final String plaintext;
  @override
  final EncryptedPayload? payload;
}

final class SecureMessagingDemoUnavailable extends SecureMessagingDemoState {
  const SecureMessagingDemoUnavailable();
}
