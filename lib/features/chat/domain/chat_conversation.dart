import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';

@freezed
abstract class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required final String id,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    @Default(<ChatMessage>[]) final List<ChatMessage> messages,
    @Default(<String>[]) final List<String> pastUserInputs,
    @Default(<String>[]) final List<String> generatedResponses,
    final String? model,
  }) = _ChatConversation;
  const ChatConversation._();

  factory ChatConversation.fromJson(final Map<String, dynamic> json) {
    final List<ChatMessage> messages = _messagesFromJson(
      json['messages'] as List<dynamic>?,
    );
    final List<String> pastInputs = _stringListFromJson(
      json['pastUserInputs'] as List<dynamic>?,
    );
    final List<String> generated = _stringListFromJson(
      json['generatedResponses'] as List<dynamic>?,
    );
    final DateTime createdAt = _parseDate(json['createdAt']);
    final DateTime updatedAt = _parseDate(
      json['updatedAt'],
      fallback: createdAt,
    );

    return ChatConversation(
      id: (json['id'] ?? '').toString(),
      messages: messages,
      pastUserInputs: pastInputs,
      generatedResponses: generated,
      createdAt: createdAt,
      updatedAt: updatedAt,
      model: _normalizeModel(json['model']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'messages': messages.map((final ChatMessage m) => m.toJson()).toList(),
    'pastUserInputs': pastUserInputs,
    'generatedResponses': generatedResponses,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (model != null) 'model': model,
  };

  bool get hasContent =>
      messages.isNotEmpty ||
      pastUserInputs.isNotEmpty ||
      generatedResponses.isNotEmpty;
}

List<ChatMessage> _messagesFromJson(final List<dynamic>? raw) {
  if (raw == null) return const <ChatMessage>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(ChatMessage.fromJson)
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
