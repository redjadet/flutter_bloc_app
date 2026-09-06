import 'package:meta/meta.dart';

/// Opaque base64 envelope. Domain never sees pointers, nonces, or raw bytes.
@immutable
final class EncryptedPayload {
  const EncryptedPayload(this.base64Envelope);

  final String base64Envelope;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedPayload && other.base64Envelope == base64Envelope;

  @override
  int get hashCode => base64Envelope.hashCode;
}
