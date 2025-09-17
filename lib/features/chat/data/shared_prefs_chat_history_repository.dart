import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsChatHistoryRepository implements ChatHistoryRepository {
  SharedPrefsChatHistoryRepository([SharedPreferences? instance])
    : _prefsInstance = instance;

  static const String _prefsKeyHistory = 'chat_history';

  final SharedPreferences? _prefsInstance;

  Future<SharedPreferences> _prefs() => _prefsInstance != null
      ? Future<SharedPreferences>.value(_prefsInstance)
      : SharedPreferences.getInstance();

  @override
  Future<List<ChatConversation>> load() async {
    try {
      final SharedPreferences prefs = await _prefs();
      final String? stored = prefs.getString(_prefsKeyHistory);
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
      AppLogger.error('SharedPrefsChatHistoryRepository.load failed', e, s);
    }
    return const <ChatConversation>[];
  }

  @override
  Future<void> save(List<ChatConversation> conversations) async {
    try {
      final SharedPreferences prefs = await _prefs();
      if (conversations.isEmpty) {
        await prefs.remove(_prefsKeyHistory);
        return;
      }
      final String json = jsonEncode(
        conversations.map((ChatConversation c) => c.toJson()).toList(),
      );
      await prefs.setString(_prefsKeyHistory, json);
    } catch (e, s) {
      AppLogger.error('SharedPrefsChatHistoryRepository.save failed', e, s);
    }
  }
}
