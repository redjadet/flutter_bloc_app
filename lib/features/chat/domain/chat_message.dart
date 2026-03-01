import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

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
        stringFromDynamic(json['clientMessageId']) ??
        stringFromDynamic(json['client_message_id']);
    final String? createdAtString = stringFromDynamic(json['createdAt']);
    final DateTime? createdAt = createdAtString != null
        ? DateTime.tryParse(createdAtString)
        : null;
    final bool synchronized = boolFromDynamic(
      json['synchronized'] ?? json['isSynced'],
      fallback: true,
    );
    final String? lastSyncedString = stringFromDynamic(json['lastSyncedAt']);
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
    if (createdAt case final timestamp?)
      'createdAt': timestamp.toIso8601String(),
    'synchronized': synchronized,
    if (lastSyncedAt case final syncedAt?)
      'lastSyncedAt': syncedAt.toIso8601String(),
  };
}
