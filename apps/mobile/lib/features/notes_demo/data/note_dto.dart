import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

class const NoteDto({
  required final String id,
  required final String title,
  required final String body,
  required final int createdAtMs,
  required final int updatedAtMs,
}) {
  new fromDomain(Note note)
    : this(
        id: note.id,
        title: note.title,
        body: note.body,
        createdAtMs: note.createdAt.millisecondsSinceEpoch,
        updatedAtMs: note.updatedAt.millisecondsSinceEpoch,
      );

  factory fromMap(Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> normalized = raw.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
    final String? id = stringFromDynamic(normalized['id']);
    final String? title = stringFromDynamic(normalized['title']);
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      throw const FormatException('Invalid Note payload');
    }
    final String body = stringFromDynamic(normalized['body']) ?? '';
    final int? createdAtMs = intFromDynamic(normalized['createdAtMs']);
    final int? updatedAtMs = intFromDynamic(normalized['updatedAtMs']);
    if (createdAtMs == null || updatedAtMs == null) {
      throw const FormatException('Invalid Note timestamps');
    }
    return NoteDto(
      id: id,
      title: title,
      body: body,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'createdAtMs': createdAtMs,
    'updatedAtMs': updatedAtMs,
  };

  Note toDomain() => Note(
    id: id,
    title: title,
    body: body,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
  );
}
