import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';

/// Stores chat history in encrypted platform storage.
class SecureChatHistoryRepository implements ChatHistoryRepository {
  SecureChatHistoryRepository({final SecretStorage? storage})
    : _storage = storage ?? FlutterSecureSecretStorage();

  static const String _storageKeyHistory = 'chat_history';

  final SecretStorage _storage;

  @override
  Future<List<ChatConversation>> load() async =>
      StorageGuard.run<List<ChatConversation>>(
        logContext: 'SecureChatHistoryRepository.load',
        action: () async {
          final String? stored = await _storage.read(_storageKeyHistory);
          if (stored == null || stored.isEmpty) {
            return const <ChatConversation>[];
          }
          try {
            final List<dynamic> decoded = await decodeJsonList(stored);
            return decoded
                .whereType<Map<String, dynamic>>()
                .map(ChatConversation.fromJson)
                .toList(growable: false);
          } on FormatException catch (error, stackTrace) {
            AppLogger.error(
              'SecureChatHistoryRepository.load invalid payload',
              error,
              stackTrace,
            );
            return const <ChatConversation>[];
          }
        },
        fallback: () => const <ChatConversation>[],
      );

  @override
  Future<void> save(final List<ChatConversation> conversations) async {
    await StorageGuard.run<void>(
      logContext: 'SecureChatHistoryRepository.save',
      action: () async {
        if (conversations.isEmpty) {
          await _storage.delete(_storageKeyHistory);
          return;
        }
        // check-ignore: small payload (<8KB) - chat history encoding for storage is handled via decodeJsonList on read
        final String json = jsonEncode(
          conversations
              .map((final ChatConversation c) => c.toJson())
              .toList(growable: false),
        );
        await _storage.write(_storageKeyHistory, json);
      },
    );
  }
}
