enum ChatAuthor { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.author,
    required this.text,
    this.clientMessageId,
    this.createdAt,
    this.synchronized = true,
    this.lastSyncedAt,
  });

  factory ChatMessage.fromJson(final Map<String, dynamic> json) {
    final String authorValue = (json['author'] ?? '').toString();
    final ChatAuthor author = ChatAuthor.values.firstWhere(
      (final value) => value.name == authorValue,
      orElse: () => ChatAuthor.system,
    );
    final String text = (json['text'] ?? '').toString();
    final String? clientMessageId =
        (json['clientMessageId'] ?? json['client_message_id']) as String?;
    final String? createdAtString = json['createdAt'] as String?;
    final DateTime? createdAt = createdAtString != null
        ? DateTime.tryParse(createdAtString)
        : null;
    final bool synchronized =
        (json['synchronized'] as bool?) ?? json['isSynced'] as bool? ?? true;
    final String? lastSyncedString = json['lastSyncedAt'] as String?;
    final DateTime? lastSyncedAt = lastSyncedString != null
        ? DateTime.tryParse(lastSyncedString)
        : null;

    return ChatMessage(
      author: author,
      text: text,
      clientMessageId: clientMessageId,
      createdAt: createdAt,
      synchronized: synchronized,
      lastSyncedAt: lastSyncedAt,
    );
  }

  final ChatAuthor author;
  final String text;
  final String? clientMessageId;
  final DateTime? createdAt;
  final bool synchronized;
  final DateTime? lastSyncedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'author': author.name,
    'text': text,
    if (clientMessageId != null) 'clientMessageId': clientMessageId,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    'synchronized': synchronized,
    if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt!.toIso8601String(),
  };
}
