import 'package:approval_tests/approval_tests.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_conversation_dto.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/approval_test_options.dart';

void main() {
  group('ChatConversationDto.toJson', () {
    test('serializes nested messages and sync metadata', () {
      final DateTime createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);
      final DateTime updatedAt = DateTime.utc(2026, 1, 3, 4, 5, 6);
      final DateTime messageAt = DateTime.utc(2026, 1, 2, 3, 5, 0);
      final DateTime syncedAt = DateTime.utc(2026, 1, 3, 4, 0, 0);

      final ChatConversationDto dto = ChatConversationDto(
        id: 'conv-1',
        createdAt: createdAt,
        updatedAt: updatedAt,
        messages: <ChatMessage>[
          ChatMessage(
            author: ChatAuthor.user,
            text: 'hello',
            clientMessageId: 'client-1',
            createdAt: messageAt,
            synchronized: false,
          ),
          ChatMessage(
            author: ChatAuthor.assistant,
            text: 'hi there',
            createdAt: messageAt.add(const Duration(seconds: 1)),
            synchronized: true,
            lastSyncedAt: syncedAt,
          ),
        ],
        pastUserInputs: const <String>['hello'],
        generatedResponses: const <String>['hi there'],
        model: 'demo-model',
        lastSyncedAt: syncedAt,
        synchronized: false,
        changeId: 'change-9',
      );

      Approvals.verifyAsJson(dto.toJson(), options: approvalTestOptions());
    });
  });
}
