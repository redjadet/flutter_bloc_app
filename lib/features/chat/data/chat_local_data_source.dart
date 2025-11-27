import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive/hive.dart';

/// Hive-backed implementation of [ChatHistoryRepository].
///
/// Persists conversations/messages locally so the chat UI can hydrate instantly
/// and queue pending sends while offline.
class ChatLocalDataSource extends HiveRepositoryBase
    implements ChatHistoryRepository {
  ChatLocalDataSource({required super.hiveService});

  static const String _boxName = 'chat_history';
  static const String _keyConversations = 'conversations';

  @override
  String get boxName => _boxName;

  @override
  Future<List<ChatConversation>> load() async =>
      StorageGuard.run<List<ChatConversation>>(
        logContext: 'ChatLocalDataSource.load',
        action: () async {
          final Box<dynamic> box = await getBox();
          final dynamic raw = box.get(_keyConversations);
          return _parseStored(raw);
        },
        fallback: () => const <ChatConversation>[],
      );

  @override
  Future<void> save(final List<ChatConversation> conversations) async =>
      StorageGuard.run<void>(
        logContext: 'ChatLocalDataSource.save',
        action: () async {
          final Box<dynamic> box = await getBox();
          if (conversations.isEmpty) {
            await safeDeleteKey(box, _keyConversations);
            return;
          }

          final List<Map<String, dynamic>> serialized = conversations
              .map((final ChatConversation c) => c.toJson())
              .toList(growable: false);
          await box.put(_keyConversations, serialized);
        },
      );

  List<ChatConversation> _parseStored(final dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(raw);
        return _parseStored(decoded);
      } on Exception {
        return const <ChatConversation>[];
      }
    }

    if (raw is Iterable<dynamic>) {
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(_mapToConversation)
          .toList(growable: false);
    }

    return const <ChatConversation>[];
  }

  ChatConversation _mapToConversation(final Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> normalized = raw.map(
      (final dynamic key, final dynamic value) =>
          MapEntry(key.toString(), value),
    );
    return ChatConversation.fromJson(normalized);
  }
}
