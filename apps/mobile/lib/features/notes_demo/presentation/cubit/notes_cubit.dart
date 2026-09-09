import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/notes_repository.dart';
import 'package:flutter_bloc_app/features/notes_demo/presentation/cubit/notes_state.dart';

class NotesCubit({required final NotesRepository repository})
    extends Cubit<NotesState> {
  this : super(NotesState.initial());

  StreamSubscription<List<Note>>? _subscription;

  Future<void> start() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _subscription?.cancel();
    _subscription = repository.watchAll().listen(
      (notes) {
        if (isClosed) {
          return;
        }
        // Preserve validation errors until the next successful mutation stream.
        emit(state.copyWith(isLoading: false, notes: notes));
      },
      onError: (Object error) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
      },
    );
  }

  Future<void> saveNote({
    required String title,
    String body = '',
    Note? existing,
  }) async {
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(errorMessage: 'Title is required.'));
      return;
    }
    try {
      final Note note = existing == null
          ? Note.create(title: trimmed, body: body)
          : existing.copyWith(
              title: trimmed,
              body: body,
              updatedAt: DateTime.now(),
            );
      await repository.save(note);
      if (!isClosed) {
        emit(state.copyWith(clearError: true));
      }
    } on Object catch (error) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await repository.delete(id);
      if (!isClosed) {
        emit(state.copyWith(clearError: true));
      }
    } on Object catch (error) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
