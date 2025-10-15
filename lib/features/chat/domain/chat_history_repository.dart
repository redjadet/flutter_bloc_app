import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';

abstract class ChatHistoryRepository {
  Future<List<ChatConversation>> load();
  Future<void> save(List<ChatConversation> conversations);
}
