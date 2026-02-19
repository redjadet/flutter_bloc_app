import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';

/// Registers all todo list-related services and repositories.
void registerTodoServices() {
  registerLazySingletonIfAbsent<TodoRepository>(
    createTodoRepository, // Use factory instead of direct instantiation
    dispose: (final repo) async {
      if (repo is OfflineFirstTodoRepository) {
        await repo.dispose();
      }
    },
  );
}
