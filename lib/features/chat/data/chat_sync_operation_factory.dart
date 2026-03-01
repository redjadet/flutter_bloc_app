import 'dart:math';

import 'package:flutter_bloc_app/features/chat/data/chat_sync_payload.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

class ChatSyncOperationFactory {
  ChatSyncOperationFactory({required final String entityType})
    : _entityType = entityType;

  final String _entityType;

  String generateConversationId() =>
      'conversation_${DateTime.now().microsecondsSinceEpoch}';

  String generateChangeId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
      Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');

  SyncOperation createOperation({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    required final String conversationId,
    required final String clientMessageId,
    required final DateTime createdAt,
    final String? model,
  }) => SyncOperation.create(
    entityType: _entityType,
    payload: <String, dynamic>{
      'conversationId': conversationId,
      'prompt': prompt,
      'pastUserInputs': pastUserInputs,
      'generatedResponses': generatedResponses,
      'model': model,
      'clientMessageId': clientMessageId,
      'createdAt': createdAt.toIso8601String(),
    },
    idempotencyKey: clientMessageId,
  );

  ChatSyncPayload readPayload(final SyncOperation operation) {
    final Map<String, dynamic> payload = operation.payload;
    final String conversationId =
        (payload['conversationId'] ?? generateConversationId()).toString();
    final String prompt = (payload['prompt'] ?? '').toString();
    final List<String> pastUserInputs = _readStringList(
      payload['pastUserInputs'],
    );
    final List<String> generatedResponses = _readStringList(
      payload['generatedResponses'],
    );
    final String? model = stringFromDynamic(payload['model']);
    final String clientMessageId =
        (payload['clientMessageId'] ?? generateChangeId()).toString();
    final DateTime createdAt =
        DateTime.tryParse((payload['createdAt'] ?? '').toString()) ??
        DateTime.now().toUtc();

    return ChatSyncPayload(
      conversationId: conversationId,
      prompt: prompt,
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      model: model,
      clientMessageId: clientMessageId,
      createdAt: createdAt,
    );
  }

  List<String> _readStringList(final dynamic raw) {
    if (raw is List) {
      return raw.map((final dynamic item) => item.toString()).toList();
    }
    return const <String>[];
  }
}
