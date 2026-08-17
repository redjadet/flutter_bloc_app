enum ChatAuthor { user, assistant, system }

class const ChatMessage({
  required final ChatAuthor author,
  required final String text,
  final String? clientMessageId,
  final DateTime? createdAt,
  final bool synchronized = true,
  final DateTime? lastSyncedAt,

  /// Set when a background sync dequeue fails with a non-retryable remote
  /// error (dead-letter). Value matches the remote failure `code` field for
  /// l10n mapping.
  final String? terminalSyncFailureCode,
});
