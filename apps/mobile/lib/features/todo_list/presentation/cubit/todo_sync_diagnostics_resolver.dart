import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';

TodoSyncDiagnosticsPort resolveTodoSyncDiagnostics({
  required TodoRepository repository,
  TodoSyncDiagnosticsPort? syncDiagnostics,
}) {
  if (syncDiagnostics != null) {
    return syncDiagnostics;
  }
  if (repository is TodoSyncDiagnosticsPort) {
    return repository as TodoSyncDiagnosticsPort;
  }
  return const NoPendingTodoSyncDiagnostics();
}
