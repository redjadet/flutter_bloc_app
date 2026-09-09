import 'package:flutter_bloc_app/features/notes_demo/data/note_dto.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/notes_repository.dart';
import 'package:hive/hive.dart';
import 'package:storage/storage.dart';

class HiveNotesRepository extends HiveRepositoryBase
    implements NotesRepository {
  new({required super.hiveService});

  static const String _boxName = 'notes_demo';
  static const String _keyNotes = 'notes';
  static const String _schemaNamespace = 'notes_demo:notes';

  @override
  String get boxName => _boxName;

  @override
  HiveBoxSchema get schema => HiveBoxSchema(
    boxName: _boxName,
    namespace: _schemaNamespace,
    fingerprint:
        hiveSchemaFingerprints[_schemaNamespace] ??
        (throw StateError(
          'Missing hive schema fingerprint for $_schemaNamespace. '
          'Run: dart run tool/generate_hive_schema_fingerprints.dart',
        )),
    migrate: (box, {required fromFingerprint}) async {},
  );

  @override
  Future<List<Note>> fetchAll() => StorageGuard.run<List<Note>>(
    logContext: 'HiveNotesRepository.fetchAll',
    action: () async {
      final Box<dynamic> box = await getBox();
      return _loadFromBox(box);
    },
    fallback: () async => const <Note>[],
  );

  @override
  Stream<List<Note>> watchAll() async* {
    final Box<dynamic> box = await getBox();
    yield _loadFromBox(box);
    await for (final BoxEvent event in box.watch()) {
      if (event.key == _keyNotes) {
        yield _loadFromBox(box);
      }
    }
  }

  @override
  Future<void> save(Note note) => StorageGuard.run<void>(
    logContext: 'HiveNotesRepository.save',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<Note> existing = _loadFromBox(box);
      final List<Note> updated = List<Note>.from(existing);
      final int index = updated.indexWhere((item) => item.id == note.id);
      if (index == -1) {
        updated.add(note);
      } else {
        updated[index] = note;
      }
      await _save(box, updated);
    },
  );

  @override
  Future<void> delete(String id) => StorageGuard.run<void>(
    logContext: 'HiveNotesRepository.delete',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<Note> existing = _loadFromBox(box);
      final List<Note> updated = existing
          .where((item) => item.id != id)
          .toList(growable: false);
      await _save(box, updated);
    },
  );

  List<Note> _loadFromBox(Box<dynamic> box) {
    final Object? raw = box.get(_keyNotes);
    if (raw is! Iterable) {
      return const <Note>[];
    }
    final List<Note> notes =
        raw
            .whereType<Map<dynamic, dynamic>>()
            .map((map) {
              try {
                return NoteDto.fromMap(map).toDomain();
              } on Exception {
                return null;
              }
            })
            .whereType<Note>()
            .toList(growable: true)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List<Note>.unmodifiable(notes);
  }

  Future<void> _save(Box<dynamic> box, List<Note> notes) async {
    if (notes.isEmpty) {
      await safeDeleteKey(box, _keyNotes);
      return;
    }
    final List<Map<String, dynamic>> serialized = notes
        .map(NoteDto.fromDomain)
        .map((dto) => dto.toMap())
        .toList(growable: false);
    await box.put(_keyNotes, serialized);
  }
}
