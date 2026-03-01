import 'dart:io';

import 'package:flutter_bloc_app/features/chat/data/chat_local_data_source.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('ChatLocalDataSource', () {
    late Directory tempDir;
    late HiveService hiveService;
    late ChatLocalDataSource dataSource;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('chat_local_ds_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      dataSource = ChatLocalDataSource(hiveService: hiveService);
    });

    tearDown(() async {
      await hiveService.deleteBox('chat_history');
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('returns empty list when nothing stored', () async {
      final List<ChatConversation> conversations = await dataSource.load();
      expect(conversations, isEmpty);
    });

    test('persists and loads conversations round-trip', () async {
      final ChatConversation conversation = ChatConversation(
        id: 'c1',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 2),
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'Hello'),
          ChatMessage(author: ChatAuthor.assistant, text: 'Hi there'),
        ],
        pastUserInputs: const <String>['Hello'],
        generatedResponses: const <String>['Hi there'],
        model: 'gpt-test',
      );

      await dataSource.save(<ChatConversation>[conversation]);

      final List<ChatConversation> loaded = await dataSource.load();
      expect(loaded.length, 1);
      final ChatConversation restored = loaded.first;
      expect(restored.id, conversation.id);
      expect(restored.createdAt, conversation.createdAt);
      expect(restored.updatedAt, conversation.updatedAt);
      expect(restored.messages.length, 2);
      expect(restored.messages.first.text, 'Hello');
      expect(restored.generatedResponses, <String>['Hi there']);
      expect(restored.model, 'gpt-test');
    });

    test('clears storage when saving empty list', () async {
      final ChatConversation conversation = ChatConversation(
        id: 'c2',
        createdAt: DateTime.utc(2024, 2, 1),
        updatedAt: DateTime.utc(2024, 2, 1),
      );
      await dataSource.save(<ChatConversation>[conversation]);

      await dataSource.save(const <ChatConversation>[]);

      final List<ChatConversation> loaded = await dataSource.load();
      expect(loaded, isEmpty);
    });

    test(
      'returns empty list when stored iterable contains malformed item',
      () async {
        await dataSource.load();
        final Box<dynamic> box = await Hive.openBox('chat_history');
        await box.put('conversations', <Map<String, dynamic>>[
          <String, dynamic>{'messages': 123},
        ]);
        await box.close();

        final List<ChatConversation> loaded = await dataSource.load();
        expect(loaded, isEmpty);
      },
    );
  });
}
