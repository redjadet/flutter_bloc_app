part of 'todo_list_cubit.dart';

mixin _TodoListCubitPendingSync on Cubit<TodoListState> {
  TodoSyncDiagnosticsPort get _syncDiagnostics;

  Future<void> refreshPendingSyncCount() async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        final int count = await _syncDiagnostics.pendingSyncOperationCount();
        if (isClosed) {
          return;
        }
        emit(state.copyWith(pendingSyncCount: count));
      },
      isAlive: () => !isClosed,
      onError: (_) {},
      logContext: 'TodoListCubit.refreshPendingSyncCount',
    );
  }
}
