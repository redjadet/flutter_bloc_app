import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    this.messages = const <ChatMessage>[],
    this.pastUserInputs = const <String>[],
    this.generatedResponses = const <String>[],
    required this.createdAt,
    DateTime? updatedAt,
    this.model,
  }) : updatedAt = updatedAt ?? createdAt;

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final Iterable<dynamic> rawMessages =
        (json['messages'] as List<dynamic>? ?? const <dynamic>[]);
    return ChatConversation(
      id: (json['id'] ?? '').toString(),
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList(growable: false),
      pastUserInputs:
          (json['pastUserInputs'] as List<dynamic>? ?? const <dynamic>[])
              .map((dynamic e) => e.toString())
              .toList(growable: false),
      generatedResponses:
          (json['generatedResponses'] as List<dynamic>? ?? const <dynamic>[])
              .map((dynamic e) => e.toString())
              .toList(growable: false),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      model: _parseModel(json['model']),
    );
  }

  final String id;
  final List<ChatMessage> messages;
  final List<String> pastUserInputs;
  final List<String> generatedResponses;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? model;

  ChatConversation copyWith({
    List<ChatMessage>? messages,
    List<String>? pastUserInputs,
    List<String>? generatedResponses,
    DateTime? updatedAt,
    String? model,
  }) {
    return ChatConversation(
      id: id,
      messages: messages ?? this.messages,
      pastUserInputs: pastUserInputs ?? this.pastUserInputs,
      generatedResponses: generatedResponses ?? this.generatedResponses,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      model: model ?? this.model,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'messages': messages.map((ChatMessage e) => e.toJson()).toList(),
    'pastUserInputs': pastUserInputs,
    'generatedResponses': generatedResponses,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (model != null) 'model': model,
  };

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  static String? _parseModel(dynamic value) {
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
