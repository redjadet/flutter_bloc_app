part of 'todo_list_cubit.dart';

AppError _todoWatchError(
  Object error,
  StackTrace stackTrace,
) {
  AppLogger.error('TodoListCubit.watchAll failed', error, stackTrace);
  return NetworkErrorMapper.getAppError(error);
}
