import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/chat/data/secure_chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

void main() {
  group('SecureChatHistoryRepository.load', () {
    test(
      'returns decoded conversations when storage contains valid payload',
      () async {
        final ChatConversation conversation = ChatConversation(
          id: '42',
          messages: const <ChatMessage>[
            ChatMessage(author: ChatAuthor.user, text: 'hello'),
            ChatMessage(author: ChatAuthor.assistant, text: 'world'),
          ],
          pastUserInputs: const <String>['hello'],
          generatedResponses: const <String>['world'],
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
          model: 'awesome-model',
        );
        final String stored = jsonEncode(<Map<String, dynamic>>[
          conversation.toJson(),
        ]);

        final _RecordingSecretStorage storage = _RecordingSecretStorage(
          readValues: <String, String>{'chat_history': stored},
        );
        final SecureChatHistoryRepository repository =
            SecureChatHistoryRepository(storage: storage);

        await AppLogger.silenceAsync(() async {
          final List<ChatConversation> result = await repository.load();

          expect(result, hasLength(1));
          expect(result.first.id, '42');
          expect(result.first.messages.first.text, 'hello');
          expect(result.first.model, 'awesome-model');
        });
      },
    );

    test('returns empty list when payload is not a list', () async {
      final _RecordingSecretStorage storage = _RecordingSecretStorage(
        readValues: <String, String>{
          'chat_history': jsonEncode(<String, dynamic>{'unexpected': true}),
        },
      );
      final SecureChatHistoryRepository repository =
          SecureChatHistoryRepository(storage: storage);

      await AppLogger.silenceAsync(() async {
        final List<ChatConversation> result = await repository.load();

        expect(result, isEmpty);
      });
    });

    test('returns empty list when decoding throws', () async {
      final _RecordingSecretStorage storage = _RecordingSecretStorage(
        readValues: <String, String>{'chat_history': '{invalid-json'},
      );
      final SecureChatHistoryRepository repository =
          SecureChatHistoryRepository(storage: storage);

      await AppLogger.silenceAsync(() async {
        final List<ChatConversation> result = await repository.load();

        expect(result, isEmpty);
      });
    });
  });

  group('SecureChatHistoryRepository.save', () {
    test('deletes storage entry when conversations are empty', () async {
      final _RecordingSecretStorage storage = _RecordingSecretStorage();
      final SecureChatHistoryRepository repository =
          SecureChatHistoryRepository(storage: storage);

      await AppLogger.silenceAsync(() async {
        await repository.save(const <ChatConversation>[]);

        expect(storage.deleteCalls, contains('chat_history'));
        expect(storage.writeCalls, isEmpty);
      });
    });

    test('persists serialized conversations', () async {
      final _RecordingSecretStorage storage = _RecordingSecretStorage();
      final SecureChatHistoryRepository repository =
          SecureChatHistoryRepository(storage: storage);
      final ChatConversation conversation = ChatConversation(
        id: '1',
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'ping'),
        ],
        pastUserInputs: const <String>['ping'],
        generatedResponses: const <String>['pong'],
        createdAt: DateTime.utc(2024, 6, 1),
        updatedAt: DateTime.utc(2024, 6, 1),
      );

      await AppLogger.silenceAsync(() async {
        await repository.save(<ChatConversation>[conversation]);
        await pumpEventQueue();
      });

      expect(storage.writeCalls.containsKey('chat_history'), isTrue);
      final String stored = storage.writeCalls['chat_history']!;
      final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
      expect(decoded, hasLength(1));
      expect(decoded.first['id'], '1');
    });
  });
}

class _RecordingSecretStorage implements SecretStorage {
  _RecordingSecretStorage({Map<String, String>? readValues})
    : _readValues = Map<String, String>.from(readValues ?? <String, String>{});

  final Map<String, String> _readValues;
  final Map<String, String> writeCalls = <String, String>{};
  final List<String> deleteCalls = <String>[];

  @override
  Future<String?> read(String key) async => _readValues[key];

  @override
  Future<void> write(String key, String value) async {
    writeCalls[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    deleteCalls.add(key);
  }

  @override
  T withoutLogs<T>(T Function() action) => action();

  @override
  Future<T> withoutLogsAsync<T>(Future<T> Function() action) => action();
}
