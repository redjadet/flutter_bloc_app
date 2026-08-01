import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';

TodoSyncDiagnosticsPort resolveTodoSyncDiagnostics({
  required final TodoRepository repository,
  final TodoSyncDiagnosticsPort? syncDiagnostics,
}) {
  if (syncDiagnostics != null) {
    return syncDiagnostics;
  }
  if (repository is TodoSyncDiagnosticsPort) {
    return repository as TodoSyncDiagnosticsPort;
  }
  return const NoPendingTodoSyncDiagnostics();
}
