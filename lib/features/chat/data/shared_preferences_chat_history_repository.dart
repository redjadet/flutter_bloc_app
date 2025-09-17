import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesChatHistoryRepository implements ChatHistoryRepository {
  SharedPreferencesChatHistoryRepository([SharedPreferences? instance])
    : _preferencesInstance = instance;

  static const String _preferencesKeyHistory = 'chat_history';

  final SharedPreferences? _preferencesInstance;

  Future<SharedPreferences> _preferences() => _preferencesInstance != null
      ? Future<SharedPreferences>.value(_preferencesInstance)
      : SharedPreferences.getInstance();

  @override
  Future<List<ChatConversation>> load() async {
    try {
      final SharedPreferences preferences = await _preferences();
      final String? stored = preferences.getString(_preferencesKeyHistory);
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
    } catch (e, s) {
      AppLogger.error(
        'SharedPreferencesChatHistoryRepository.load failed',
        e,
        s,
      );
    }
    return const <ChatConversation>[];
  }

  @override
  Future<void> save(List<ChatConversation> conversations) async {
    try {
      final SharedPreferences preferences = await _preferences();
      if (conversations.isEmpty) {
        await preferences.remove(_preferencesKeyHistory);
        return;
      }
      final String json = jsonEncode(
        conversations.map((ChatConversation c) => c.toJson()).toList(),
      );
      await preferences.setString(_preferencesKeyHistory, json);
    } catch (e, s) {
      AppLogger.error(
        'SharedPreferencesChatHistoryRepository.save failed',
        e,
        s,
      );
    }
  }
}
