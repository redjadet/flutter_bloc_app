enum ChatAuthor { user, assistant, system }

class ChatMessage {
  const ChatMessage({required this.author, required this.text});

  factory ChatMessage.fromJson(final Map<String, dynamic> json) {
    final String authorValue = (json['author'] ?? '').toString();
    final ChatAuthor author = ChatAuthor.values.firstWhere(
      (final ChatAuthor value) => value.name == authorValue,
      orElse: () => ChatAuthor.system,
    );
    return ChatMessage(author: author, text: (json['text'] ?? '').toString());
  }

  final ChatAuthor author;
  final String text;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'author': author.name,
    'text': text,
  };
}
