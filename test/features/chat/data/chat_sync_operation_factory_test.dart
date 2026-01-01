import 'package:flutter_bloc_app/features/chat/data/chat_sync_operation_factory.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatSyncOperationFactory', () {
    const String entityType = 'chat';
    late ChatSyncOperationFactory factory;

    setUp(() {
      factory = ChatSyncOperationFactory(entityType: entityType);
    });

    test('creates operation and reads payload round-trip', () {
      final DateTime createdAt = DateTime.utc(2024, 1, 1);
      final SyncOperation op = factory.createOperation(
        pastUserInputs: const <String>['Hi'],
        generatedResponses: const <String>['Hello'],
        prompt: 'How are you?',
        model: 'demo',
        conversationId: 'c1',
        clientMessageId: 'm1',
        createdAt: createdAt,
      );

      expect(op.entityType, entityType);
      expect(op.payload['prompt'], 'How are you?');

      final payload = factory.readPayload(op);
      expect(payload.conversationId, 'c1');
      expect(payload.clientMessageId, 'm1');
      expect(payload.pastUserInputs, const <String>['Hi']);
      expect(payload.generatedResponses, const <String>['Hello']);
      expect(payload.model, 'demo');
      expect(payload.createdAt, createdAt);
    });

    test('fills defaults when payload is missing fields', () {
      final SyncOperation op = SyncOperation.create(
        entityType: entityType,
        payload: <String, dynamic>{},
        idempotencyKey: 'k1',
      );

      final payload = factory.readPayload(op);
      expect(payload.conversationId, isNotEmpty);
      expect(payload.clientMessageId, isNotEmpty);
      expect(payload.pastUserInputs, isEmpty);
      expect(payload.generatedResponses, isEmpty);
      expect(payload.prompt, '');
    });
  });
}
