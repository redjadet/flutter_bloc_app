import 'package:flutter_bloc_app/features/chat/data/chat_message_dto.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

/// Wire DTO for [ChatConversation] persistence.
class ChatConversationDto {
  const ChatConversationDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const <ChatMessage>[],
    this.pastUserInputs = const <String>[],
    this.generatedResponses = const <String>[],
    this.model,
    this.lastSyncedAt,
    this.synchronized = true,
    this.changeId,
  });

  ChatConversationDto.fromDomain(final ChatConversation conversation)
    : id = conversation.id,
      createdAt = conversation.createdAt,
      updatedAt = conversation.updatedAt,
      messages = conversation.messages,
      pastUserInputs = conversation.pastUserInputs,
      generatedResponses = conversation.generatedResponses,
      model = conversation.model,
      lastSyncedAt = conversation.lastSyncedAt,
      synchronized = conversation.synchronized,
      changeId = conversation.changeId;

  factory ChatConversationDto.fromJson(final Map<String, dynamic> json) {
    final dynamic messagesRaw = json['messages'];
    final List<dynamic>? messagesList = listFromDynamic(messagesRaw);
    if (messagesRaw != null && messagesList == null) {
      throw const FormatException('messages must be a list');
    }
    final List<ChatMessage> messages = _messagesFromJson(messagesList);
    final List<String> pastInputs = _stringListFromJson(
      listFromDynamic(json['pastUserInputs']),
    );
    final List<String> generated = _stringListFromJson(
      listFromDynamic(json['generatedResponses']),
    );
    final DateTime createdAt = _parseDate(json['createdAt']);
    final DateTime updatedAt = _parseDate(
      json['updatedAt'],
      fallback: createdAt,
    );

    return ChatConversationDto(
      id: (json['id'] ?? '').toString(),
      messages: messages,
      pastUserInputs: pastInputs,
      generatedResponses: generated,
      createdAt: createdAt,
      updatedAt: updatedAt,
      model: _normalizeModel(json['model']),
      lastSyncedAt: _parseOptionalDate(json['lastSyncedAt']),
      synchronized: boolFromDynamic(json['synchronized'], fallback: true),
      changeId: _normalizeChangeId(json['changeId']),
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final List<String> pastUserInputs;
  final List<String> generatedResponses;
  final String? model;
  final DateTime? lastSyncedAt;
  final bool synchronized;
  final String? changeId;

  ChatConversation toDomain() => ChatConversation(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    messages: messages,
    pastUserInputs: pastUserInputs,
    generatedResponses: generatedResponses,
    model: model,
    lastSyncedAt: lastSyncedAt,
    synchronized: synchronized,
    changeId: changeId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'messages': messages
        .map((final m) => ChatMessageDto.fromDomain(m).toJson())
        .toList(),
    'pastUserInputs': pastUserInputs,
    'generatedResponses': generatedResponses,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (model != null) 'model': model,
    if (lastSyncedAt case final syncedAt?)
      'lastSyncedAt': syncedAt.toIso8601String(),
    'synchronized': synchronized,
    if (changeId?.isNotEmpty ?? false) 'changeId': changeId,
  };
}

List<ChatMessage> _messagesFromJson(final List<dynamic>? raw) {
  if (raw == null) return const <ChatMessage>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((final map) => ChatMessageDto.fromJson(map).toDomain())
      .toList(growable: false);
}

List<String> _stringListFromJson(final List<dynamic>? raw) {
  if (raw == null) return const <String>[];
  return raw
      .map((final dynamic value) => value.toString())
      .toList(growable: false);
}

DateTime _parseDate(final dynamic value, {final DateTime? fallback}) {
  if (value is String && value.isNotEmpty) {
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return fallback ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

String? _normalizeModel(final dynamic value) {
  if (value is! String) {
    return null;
  }
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _parseOptionalDate(final dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  return null;
}

String? _normalizeChangeId(final dynamic value) {
  if (value is! String) {
    return null;
  }
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
