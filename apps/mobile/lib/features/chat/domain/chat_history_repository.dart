import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';

/// Repository contract for chat conversation history.
abstract class ChatHistoryRepository {
  /// Loads all stored conversations.
  Future<List<ChatConversation>> load();

  /// Persists the given [conversations], replacing existing history.
  Future<void> save(final List<ChatConversation> conversations);
}
