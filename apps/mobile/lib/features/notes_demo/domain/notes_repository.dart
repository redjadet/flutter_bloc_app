import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';

abstract class NotesRepository {
  Future<List<Note>> fetchAll();

  Stream<List<Note>> watchAll();

  Future<void> save(Note note);

  Future<void> delete(String id);
}
