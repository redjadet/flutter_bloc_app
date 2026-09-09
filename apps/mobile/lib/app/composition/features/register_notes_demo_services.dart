import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/notes_demo/data/hive_notes_repository.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/notes_repository.dart';
import 'package:storage/storage.dart';

void registerNotesDemoServices() {
  registerLazySingletonIfAbsent<NotesRepository>(
    () => HiveNotesRepository(hiveService: getIt<HiveService>()),
  );
}
