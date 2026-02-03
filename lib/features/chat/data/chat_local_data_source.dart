import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
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
              .map((final c) => c.toJson())
              .toList(growable: false);
          await box.put(_keyConversations, serialized);
        },
      );

  Future<List<ChatConversation>> _parseStored(final dynamic raw) async {
    if (raw is String && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = await decodeJsonList(raw);
        return _parseIterable(decoded);
      } on Exception {
        return const <ChatConversation>[];
      }
    }

    if (raw is Iterable<dynamic>) {
      return _parseIterable(raw);
    }

    return const <ChatConversation>[];
  }

  List<ChatConversation> _parseIterable(final Iterable<dynamic> raw) => raw
      .whereType<Map<dynamic, dynamic>>()
      .map(_mapToConversation)
      .toList(growable: false);

  ChatConversation _mapToConversation(final Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> normalized = raw.map(
      (final dynamic key, final dynamic value) =>
          MapEntry(key.toString(), value),
    );
    return ChatConversation.fromJson(normalized);
  }
}
