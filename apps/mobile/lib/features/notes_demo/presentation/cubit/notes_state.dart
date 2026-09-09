import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';

class const NotesState({
  final bool isLoading = true,
  final List<Note> notes = const <Note>[],
  final String? errorMessage,
}) {
  factory initial() => const NotesState();

  NotesState copyWith({
    bool? isLoading,
    List<Note>? notes,
    String? errorMessage,
    bool clearError = false,
  }) => NotesState(
    isLoading: isLoading ?? this.isLoading,
    notes: notes ?? this.notes,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
