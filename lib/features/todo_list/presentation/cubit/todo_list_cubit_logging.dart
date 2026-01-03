part of 'todo_list_cubit.dart';

String _todoWatchErrorMessage(
  final Object error,
  final StackTrace stackTrace,
) {
  AppLogger.error('TodoListCubit.watchAll failed', error, stackTrace);
  return 'Failed to watch todos: $error';
}
