import 'package:flutter_bloc_app/features/notes_demo/data/note_dto.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NoteDto round-trips domain notes', () {
    final Note note = Note(
      id: '1',
      title: 'Title',
      body: 'Body',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );
    final NoteDto dto = NoteDto.fromDomain(note);
    expect(dto.toMap()['id'], '1');
    expect(dto.toDomain().title, 'Title');
    expect(dto.toDomain().body, 'Body');
  });

  test('NoteDto.fromMap rejects invalid payloads', () {
    expect(
      () => NoteDto.fromMap(<String, dynamic>{'id': '', 'title': 'x'}),
      throwsA(isA<FormatException>()),
    );
  });

  test('Note.create and copyWith update fields', () {
    final Note created = Note.create(
      title: 'A',
      body: 'B',
      now: DateTime.utc(2026, 2, 1, 12),
    );
    expect(created.title, 'A');
    expect(created.body, 'B');
    final Note updated = created.copyWith(
      title: 'C',
      body: 'D',
      updatedAt: DateTime.utc(2026, 2, 2),
    );
    expect(updated.id, created.id);
    expect(updated.title, 'C');
    expect(updated.body, 'D');
    expect(updated.updatedAt, DateTime.utc(2026, 2, 2));
  });
}
