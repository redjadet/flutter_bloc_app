class const Note({
  required final String id,
  required final String title,
  required final String body,
  required final DateTime createdAt,
  required final DateTime updatedAt,
}) {
  factory create({required String title, String body = '', DateTime? now}) {
    final DateTime stamped = now ?? DateTime.now();
    return Note(
      id: stamped.microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      createdAt: stamped,
      updatedAt: stamped,
    );
  }

  Note copyWith({String? title, String? body, DateTime? updatedAt}) => Note(
    id: id,
    title: title ?? this.title,
    body: body ?? this.body,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
