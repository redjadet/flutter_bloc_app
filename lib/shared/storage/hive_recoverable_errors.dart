/// Hive encryption / schema mismatch signals that warrant box recovery.
bool isRecoverableHiveFailure(final Object error) {
  final String message = error.toString().toLowerCase();
  return message.contains('corrupted pad block') ||
      message.contains('invalid or corrupted pad') ||
      message.contains('cipher failed') ||
      message.contains('unknown typeid') ||
      message.contains('did you forget to register an adapter');
}
