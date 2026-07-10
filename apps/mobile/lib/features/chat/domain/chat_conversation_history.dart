import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';

/// Pure conversation-history list transforms (no emit / I/O).
int compareChatConversationsByUpdatedAtDesc(
  final ChatConversation a,
  final ChatConversation b,
) =>
    b.updatedAt.compareTo(a.updatedAt);

List<ChatConversation> sortChatConversationHistory(
  final List<ChatConversation> conversations, {
  final bool clone = true,
}) {
  final List<ChatConversation> target =
      (clone ? List<ChatConversation>.from(conversations) : conversations)
        ..sort(compareChatConversationsByUpdatedAtDesc);
  return target;
}

ChatConversation? chatConversationById(
  final List<ChatConversation> conversations,
  final String? id,
) {
  if (id == null) return null;
  for (final ChatConversation conversation in conversations) {
    if (conversation.id == id) {
      return conversation;
    }
  }
  return null;
}

/// Upsert [conversation] into history (or remove if empty / no content).
List<ChatConversation> replaceChatConversation(
  final ChatConversation conversation, {
  required final List<ChatConversation> history,
}) {
  final List<ChatConversation> updated = List<ChatConversation>.from(history);
  final int index = updated.indexWhere(
    (final c) => c.id == conversation.id,
  );

  if (index >= 0) {
    if (conversation.hasContent) {
      updated[index] = conversation;
    } else {
      updated.removeAt(index);
    }
  } else if (conversation.hasContent) {
    updated.add(conversation);
  }

  return sortChatConversationHistory(updated, clone: false);
}
