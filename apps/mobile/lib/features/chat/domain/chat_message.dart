enum ChatAuthor { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.author,
    required this.text,
    this.clientMessageId,
    this.createdAt,
    this.synchronized = true,
    this.lastSyncedAt,
    this.terminalSyncFailureCode,
  });

  final ChatAuthor author;
  final String text;
  final String? clientMessageId;
  final DateTime? createdAt;
  final bool synchronized;
  final DateTime? lastSyncedAt;

  /// Set when a background sync dequeue fails with a non-retryable remote
  /// error (dead-letter). Value matches the remote failure `code` field for
  /// l10n mapping.
  final String? terminalSyncFailureCode;
}
