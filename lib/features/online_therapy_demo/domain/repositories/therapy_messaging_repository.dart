import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

abstract interface class TherapyMessagingRepository {
  Future<List<Conversation>> listConversations();

  Future<List<Message>> listMessages({
    required String conversationId,
  });

  Future<Message> sendMessage({
    required String conversationId,
    required String body,
  });

  Future<Message> retryMessage({
    required String messageId,
  });
}
