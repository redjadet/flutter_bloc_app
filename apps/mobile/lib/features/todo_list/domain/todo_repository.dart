import 'package:flutter_bloc_app/features/todo_list/domain/todo_data_source.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_sync_diagnostics_port.dart';

export 'todo_data_source.dart';
export 'todo_sync_diagnostics_port.dart';

/// Repository contract for todo items (domain-facing facade).
///
/// Leaf Hive/RTDB adapters implement [TodoDataSource]; pending-sync inspector
/// APIs live on [TodoSyncDiagnosticsPort].
abstract class TodoRepository implements TodoDataSource {}
