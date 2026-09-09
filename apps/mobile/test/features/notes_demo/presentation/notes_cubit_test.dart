import 'dart:async';

import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/notes_repository.dart';
import 'package:flutter_bloc_app/features/notes_demo/presentation/cubit/notes_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNotesRepository implements NotesRepository {
  final StreamController<List<Note>> _controller =
      StreamController<List<Note>>.broadcast();
  final List<Note> _notes = <Note>[];

  @override
  Future<List<Note>> fetchAll() async => List<Note>.from(_notes);

  @override
  Stream<List<Note>> watchAll() async* {
    yield List<Note>.from(_notes);
    yield* _controller.stream;
  }

  @override
  Future<void> save(Note note) async {
    final int index = _notes.indexWhere((Note item) => item.id == note.id);
    if (index == -1) {
      _notes.add(note);
    } else {
      _notes[index] = note;
    }
    _controller.add(List<Note>.from(_notes));
  }

  @override
  Future<void> delete(String id) async {
    _notes.removeWhere((Note note) => note.id == id);
    _controller.add(List<Note>.from(_notes));
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  test('start loads notes from watch stream', () async {
    final _FakeNotesRepository repository = _FakeNotesRepository();
    final NotesCubit cubit = NotesCubit(repository: repository);
    await cubit.start();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.notes, isEmpty);
    await cubit.saveNote(title: 'Hello', body: 'World');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.notes, hasLength(1));
    expect(cubit.state.notes.first.title, 'Hello');
    await cubit.close();
    await repository.dispose();
  });

  test('blank title sets error', () async {
    final _FakeNotesRepository repository = _FakeNotesRepository();
    final NotesCubit cubit = NotesCubit(repository: repository);
    await cubit.start();
    await Future<void>.delayed(Duration.zero);
    await cubit.saveNote(title: '  ');
    expect(cubit.state.errorMessage, isNotNull);
    await cubit.close();
    await repository.dispose();
  });

  test('save updates existing note and delete removes it', () async {
    final _FakeNotesRepository repository = _FakeNotesRepository();
    final NotesCubit cubit = NotesCubit(repository: repository);
    await cubit.start();
    await Future<void>.delayed(Duration.zero);
    await cubit.saveNote(title: 'One', body: 'a');
    await Future<void>.delayed(Duration.zero);
    final Note existing = cubit.state.notes.single;
    await cubit.saveNote(title: 'Two', body: 'b', existing: existing);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.notes.single.title, 'Two');
    await cubit.deleteNote(existing.id);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.notes, isEmpty);
    await cubit.close();
    await repository.dispose();
  });

  test('watch stream errors surface in state', () async {
    final _FakeNotesRepository repository = _FakeNotesRepository();
    final NotesCubit cubit = NotesCubit(repository: repository);
    await cubit.start();
    await Future<void>.delayed(Duration.zero);
    repository._controller.addError(StateError('boom'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.errorMessage, contains('boom'));
    await cubit.close();
    await repository.dispose();
  });
}
