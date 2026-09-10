import 'dart:async';
import 'dart:io';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/features/notes_demo/data/hive_notes_repository.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:storage/storage.dart';

void main() {
  group('HiveNotesRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late HiveNotesRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('notes_demo_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = HiveNotesRepository(hiveService: hiveService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('fetchAll returns empty list initially', () async {
      expect(await repository.fetchAll(), isEmpty);
    });

    test('save persists, updates, sorts by updatedAt desc', () async {
      final Note older = _note(
        id: 'a',
        title: 'Older',
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      final Note newer = _note(
        id: 'b',
        title: 'Newer',
        updatedAt: DateTime.utc(2024, 1, 2),
      );
      await repository.save(older);
      await repository.save(newer);
      final List<Note> listed = await repository.fetchAll();
      expect(listed.map((n) => n.id), <String>['b', 'a']);

      await repository.save(
        older.copyWith(title: 'Updated', updatedAt: DateTime.utc(2024, 1, 3)),
      );
      final List<Note> updated = await repository.fetchAll();
      expect(updated.first.id, 'a');
      expect(updated.first.title, 'Updated');
    });

    test('delete removes note and clears box when empty', () async {
      final Note note = _note(id: 'a', title: 'Gone');
      await repository.save(note);
      await repository.delete('a');
      expect(await repository.fetchAll(), isEmpty);
    });

    test('watchAll emits updates when notes change', () async {
      final StreamIterator<List<Note>> iterator = StreamIterator(
        repository.watchAll(),
      );
      addTearDown(iterator.cancel);

      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isEmpty);

      final Future<bool> hasUpdate = iterator.moveNext();
      await repository.save(_note(id: '1', title: 'Hello'));
      expect(await hasUpdate, isTrue);
      expect(iterator.current.single.title, 'Hello');
    });

    test('concurrent save and delete do not lose updates', () async {
      final Note keep = _note(id: 'keep', title: 'Keep');
      final Note remove = _note(id: 'remove', title: 'Remove');
      await repository.save(keep);
      await repository.save(remove);

      await Future.wait<void>(<Future<void>>[
        repository.save(keep.copyWith(title: 'Updated')),
        repository.delete('remove'),
      ]);

      final List<Note> notes = await repository.fetchAll();
      expect(notes, hasLength(1));
      expect(notes.single.id, 'keep');
      expect(notes.single.title, 'Updated');
    });

    test('ignores corrupt entries in box', () async {
      await hiveService.openBoxAndRun<void>(
        'notes_demo',
        action: (Box<dynamic> box) async {
          await box.put('notes', <Object?>[
            <String, dynamic>{'id': '', 'title': 'bad'},
            <String, dynamic>{
              'id': 'ok',
              'title': 'Good',
              'body': '',
              'createdAtMs': DateTime.utc(2024, 1, 1).millisecondsSinceEpoch,
              'updatedAtMs': DateTime.utc(2024, 1, 1).millisecondsSinceEpoch,
            },
          ]);
        },
      );
      final List<Note> notes = await repository.fetchAll();
      expect(notes, hasLength(1));
      expect(notes.single.title, 'Good');
    });
  });
}

Note _note({
  required String id,
  required String title,
  String body = '',
  DateTime? updatedAt,
}) {
  final DateTime stamp = updatedAt ?? DateTime.utc(2024, 1, 1);
  return Note(
    id: id,
    title: title,
    body: body,
    createdAt: stamp,
    updatedAt: stamp,
  );
}
