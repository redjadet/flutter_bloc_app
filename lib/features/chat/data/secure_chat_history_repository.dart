import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Stores chat history in encrypted platform storage.
class SecureChatHistoryRepository implements ChatHistoryRepository {
  SecureChatHistoryRepository({SecretStorage? storage})
    : _storage = storage ?? FlutterSecureSecretStorage();

  static const String _storageKeyHistory = 'chat_history';

  final SecretStorage _storage;

  @override
  Future<List<ChatConversation>> load() async {
    try {
      final String? stored = await _storage.read(_storageKeyHistory);
      if (stored == null || stored.isEmpty) {
        return const <ChatConversation>[];
      }
      final dynamic decoded = jsonDecode(stored);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ChatConversation.fromJson)
            .toList(growable: false);
      }
      AppLogger.error(
        'SecureChatHistoryRepository.load invalid payload',
        decoded,
        StackTrace.current,
      );
    } on Exception catch (e, s) {
      AppLogger.error('SecureChatHistoryRepository.load failed', e, s);
    }
    return const <ChatConversation>[];
  }

  @override
  Future<void> save(List<ChatConversation> conversations) async {
    try {
      if (conversations.isEmpty) {
        await _storage.delete(_storageKeyHistory);
        return;
      }
      final String json = jsonEncode(
        conversations
            .map((ChatConversation c) => c.toJson())
            .toList(growable: false),
      );
      await _storage.write(_storageKeyHistory, json);
    } on Exception catch (e, s) {
      AppLogger.error('SecureChatHistoryRepository.save failed', e, s);
    }
  }
}

/// Backward-compatible alias for legacy imports.
@Deprecated('Use SecureChatHistoryRepository instead')
typedef SharedPreferencesChatHistoryRepository = SecureChatHistoryRepository;
